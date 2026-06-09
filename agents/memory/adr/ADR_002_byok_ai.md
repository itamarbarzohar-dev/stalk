# ADR-002: BYOK AI Architecture (Bring Your Own Key)

**Status:** Accepted
**Date:** 2026-06-09
**Author:** Maya (CTO, STALK)
**Decider:** Itamar Bar Zohar (CEO)

---

## Context

`AIFullChatView.swift` currently contains a completely fake AI implementation. `generateReply()` is hardcoded keyword matching with `Task.sleep(Double.random(in: 1.2...2.5))` for fake latency. There is no real API call anywhere in the codebase.

We need to ship real AI. The model: user provides their own Anthropic API key (BYOK). This avoids us holding API keys server-side, eliminates backend infrastructure for AI, and keeps the marginal cost per user at zero. Users who want AI pay Anthropic directly.

---

## Decision

**Direct URLSession → Anthropic API. No SDK. No backend proxy.**

Swift has no official Anthropic SDK. We do not introduce a third-party dependency for a single API integration. We write a thin `AnthropicClient.swift` using `URLSession` with streaming SSE.

---

## API Key Storage

**Storage: iOS Keychain via `Security` framework. NOT `UserDefaults`.**

`UserDefaults` is readable by anyone with filesystem access to the device backup. An Anthropic API key in `UserDefaults` is effectively plaintext in iCloud backups if the user has not encrypted their backup. Keychain items are encrypted at rest by the Secure Enclave and excluded from unencrypted backups by default.

### Keychain access pattern

```swift
import Security

enum KeychainService {
    private static let service = "com.itamar.stalk"
    private static let account = "anthropic_api_key"

    static func saveAPIKey(_ key: String) throws {
        let data = Data(key.utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary) // delete existing before insert
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    static func loadAPIKey() throws -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            if status == errSecItemNotFound { return nil }
            throw KeychainError.loadFailed(status)
        }
        return String(data: data, encoding: .utf8)
    }

    static func deleteAPIKey() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
}
```

**Accessibility: `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`**
- Key is accessible only when device is unlocked
- `ThisDeviceOnly` — never migrates to other devices via iCloud Keychain
- Appropriate for a per-user API key that is device-bound

---

## API Call Structure

**Endpoint:** `POST https://api.anthropic.com/v1/messages`
**Model:** `claude-haiku-4-5`
**Streaming:** Yes — `"stream": true` in request body, returns SSE events

### Why `claude-haiku-4-5`

Haiku is the correct choice for in-app conversational AI. Users are paying per token. Haiku's cost is $1.00/1M input, $5.00/1M output — roughly 5–10x cheaper than Sonnet. For portfolio Q&A ("should I sell NVDA?", "what's my biggest loser today?"), Haiku has sufficient capability. We do not use Opus or Sonnet for user-facing chat — that would drain the user's API credit too fast and result in negative reviews.

### Required headers

| Header | Value |
|---|---|
| `x-api-key` | User's API key from Keychain |
| `anthropic-version` | `2023-06-01` |
| `content-type` | `application/json` |

Do not add `Authorization: Bearer` — Anthropic uses `x-api-key`, not Bearer tokens.

### Request body shape

```json
{
  "model": "claude-haiku-4-5",
  "max_tokens": 1024,
  "stream": true,
  "system": "<system prompt — see below>",
  "messages": [
    {"role": "user", "content": "..."},
    {"role": "assistant", "content": "..."},
    {"role": "user", "content": "<current message>"}
  ]
}
```

### URLSession streaming implementation

```swift
func streamMessage(
    apiKey: String,
    systemPrompt: String,
    messages: [[String: String]],
    onToken: @escaping (String) -> Void,
    onComplete: @escaping () -> Void,
    onError: @escaping (AnthropicError) -> Void
) async {
    guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { return }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
    request.setValue("application/json", forHTTPHeaderField: "content-type")

    let body: [String: Any] = [
        "model": "claude-haiku-4-5",
        "max_tokens": 1024,
        "stream": true,
        "system": systemPrompt,
        "messages": messages
    ]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)

    do {
        let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            onError(.networkError("Invalid response")); return
        }

        // Non-2xx: read body and map to error
        guard (200...299).contains(httpResponse.statusCode) else {
            onError(mapHTTPError(httpResponse.statusCode)); return
        }

        // SSE parsing
        for try await line in asyncBytes.lines {
            guard line.hasPrefix("data: ") else { continue }
            let jsonStr = String(line.dropFirst(6))
            if jsonStr == "[DONE]" { break }
            if let data = jsonStr.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let delta = (json["delta"] as? [String: Any])?["text"] as? String {
                onToken(delta)
            }
        }
        onComplete()
    } catch {
        onError(.networkError(error.localizedDescription))
    }
}
```

---

## System Prompt Strategy

The system prompt runs every conversation. It injects the user's live portfolio context so Claude can answer questions like "how am I doing today?" without the user having to repeat themselves.

### System prompt template

```
You are STALK AI, a personal finance assistant embedded in the STALK portfolio tracking app.
You speak concisely — no filler, no disclaimers, no "As an AI language model". Answer like a sharp analyst talking to a friend.

PORTFOLIO SNAPSHOT (live as of this conversation):
- Total value: $<totalValue>
- Total cost basis: $<totalCost>
- Unrealized P&L: $<totalPnl> (<totalPnlPct>%)
- Today's P&L: $<todayPnl> (<todayPnlPct>%)

HOLDINGS:
<for each position>
- <ticker>: <shares> shares @ $<avgCost> avg cost | current $<currentPrice> | P&L $<positionPnl> (<pnlPct>%)
</for>

MARKET CONTEXT:
- Date: <today>
- Market status: <open/closed>

The user is asking about their portfolio. Be direct. Use numbers. Do not hallucinate prices — use only the data above.
```

### Building the system prompt in Swift

```swift
func buildSystemPrompt(appState: AppState) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"

    func fmt(_ v: Double) -> String {
        formatter.string(from: NSNumber(value: v)) ?? "$\(v)"
    }

    var lines = [
        "You are STALK AI, a personal finance assistant embedded in the STALK portfolio tracking app.",
        "You speak concisely — no filler, no disclaimers. Answer like a sharp analyst talking to a friend.",
        "",
        "PORTFOLIO SNAPSHOT:",
        "- Total value: \(fmt(appState.totalValue))",
        "- Total cost basis: \(fmt(appState.totalCost))",
        "- Unrealized P&L: \(fmt(appState.totalPnl)) (\(String(format: "%.2f", appState.totalPnlPct))%)",
        "- Today's P&L: \(fmt(appState.todayPnl)) (\(String(format: "%.2f", appState.todayPnlPct))%)",
        "",
        "HOLDINGS:"
    ]

    for position in appState.positions {
        let price = appState.quotes[position.ticker]?.price ?? position.avgCost
        let value = price * position.shares
        let pnl = value - position.avgCost * position.shares
        let pnlPct = position.avgCost > 0 ? (pnl / (position.avgCost * position.shares)) * 100 : 0
        lines.append("- \(position.ticker): \(position.shares) shares @ \(fmt(position.avgCost)) avg | current \(fmt(price)) | P&L \(fmt(pnl)) (\(String(format: "%.1f", pnlPct))%)")
    }

    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeZone = MarketCalendar.eastern
    lines += ["", "DATE: \(df.string(from: Date()))"]
    lines += ["Do not hallucinate prices — use only the data above."]

    return lines.joined(separator: "\n")
}
```

---

## Error Handling

### Error taxonomy

```swift
enum AnthropicError: Error, LocalizedError {
    case invalidAPIKey           // HTTP 401
    case rateLimited             // HTTP 429
    case serverError(Int)        // HTTP 5xx
    case networkError(String)    // URLSession/connectivity failure
    case noAPIKey                // Key not in Keychain

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Your API key is invalid. Check your Anthropic API key in Settings."
        case .rateLimited:
            return "You've hit Anthropic's rate limit. Wait a moment and try again."
        case .serverError(let code):
            return "Anthropic server error (\(code)). Try again in a few seconds."
        case .networkError(let msg):
            return "Network error: \(msg)"
        case .noAPIKey:
            return "No API key set. Add your Anthropic API key in Settings."
        }
    }
}

func mapHTTPError(_ statusCode: Int) -> AnthropicError {
    switch statusCode {
    case 401: return .invalidAPIKey
    case 429: return .rateLimited
    case 500...599: return .serverError(statusCode)
    default: return .serverError(statusCode)
    }
}
```

### Error display in UI

- `.invalidAPIKey` — show inline alert with a "Go to Settings" button that deep-links to the API key entry screen
- `.rateLimited` — show inline error "Rate limited — try again in a few seconds" with a retry button
- `.networkError` — show "No connection" error, retry button
- `.noAPIKey` — show onboarding prompt to enter API key, NOT an error message

---

## Pro Gate

The current pro gate (`settings.aiMessagesUsed` in `UserDefaults`) is bypassable via direct `UserDefaults` manipulation. This is a known issue tracked in `cto_decisions.md`.

For v1, the gate stays in `UserDefaults`. For v1.1, it moves to server-side entitlement check (Supabase, per ADR-001).

**Free tier:** 3 messages lifetime (current behavior). Pro users: unlimited.

---

## Files to Create/Modify

| File | Action |
|---|---|
| `STALK/Services/KeychainService.swift` | **Create** — Keychain read/write/delete |
| `STALK/Services/AnthropicClient.swift` | **Create** — URLSession streaming client |
| `STALK/AIFullChatView.swift` | **Replace** `generateReply()` with real streaming call |
| `STALK/Settings/APIKeySettingsView.swift` | **Create** — UI to enter/delete API key |

---

## What Does NOT Change

- `AppState.swift` — no changes needed; portfolio context is read directly
- `Models.swift` — no changes
- The conversation history format stays as an array of `ChatMessage` structs in `AIFullChatView`
- The pro gate UI stays in `AIFullChatView` — only the underlying check moves to Keychain-backed storage eventually
