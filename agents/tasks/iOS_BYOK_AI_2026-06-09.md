# Task: BYOK Claude API — Wire Real AI Calls in AI Chat
**Assigned to:** Jordan (iOS Dev)
**Priority:** HIGH
**Due:** 2026-06-09
**From:** CEO Alex
**Status:** OPEN

## Context

`AIFullChatView.swift` currently has a mock AI that returns fake responses. The model exists, the UI exists, the paywall gate exists. What's missing: real Claude API calls using a user-provided API key stored in Keychain.

BYOK (Bring Your Own Key) means: the user enters their Anthropic API key in Settings → it's stored in iOS Keychain → every AI message hits the real Claude API.

This is the cleanest path to real AI without a backend: zero server cost, zero data liability, API key never leaves the device.

## What I need

### Step 1: Keychain Wrapper

Create `STALK/Services/KeychainService.swift`:

```swift
import Foundation
import Security

struct KeychainService {
    static let anthropicKeyAccount = "anthropic_api_key"
    static let service = Bundle.main.bundleIdentifier ?? "com.itamar.stalk"
    
    // Save key
    static func saveAPIKey(_ key: String) throws {
        let data = Data(key.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: anthropicKeyAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary) // delete existing first
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    // Read key
    static func getAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: anthropicKeyAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else { return nil }
        return key
    }
    
    // Delete key
    static func deleteAPIKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: anthropicKeyAccount
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    enum KeychainError: Error {
        case saveFailed(OSStatus)
    }
}
```

### Step 2: Claude API Service

Create `STALK/Services/ClaudeService.swift`:

```swift
import Foundation

struct ClaudeService {
    // API endpoint — claude-3-5-haiku-20241022 for cost efficiency
    // Switch to claude-opus-4-5 for Pro users if Itamar decides to
    static let model = "claude-3-5-haiku-20241022"
    static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    static let maxTokens = 1024
    
    struct Message: Codable {
        let role: String
        let content: String
    }
    
    struct RequestBody: Codable {
        let model: String
        let max_tokens: Int
        let system: String
        let messages: [Message]
    }
    
    struct ResponseBody: Codable {
        struct Content: Codable {
            let type: String
            let text: String
        }
        let content: [Content]
    }
    
    // System prompt — STALK's AI persona
    static let systemPrompt = """
    You are STALK AI, a sharp, data-driven financial analyst assistant built into the STALK portfolio app. \
    You help users understand their portfolio, analyze stocks, and make sense of market movements. \
    Be concise and direct — this is a mobile app, not a research report. \
    Lead with the key insight. Use numbers when they matter. \
    Never give personalized investment advice that constitutes fiduciary guidance. \
    Always remind users to do their own research for major decisions. \
    Format responses for mobile: short paragraphs, bullet points when listing, no markdown headers.
    """
    
    static func sendMessage(
        apiKey: String,
        conversationHistory: [Message],
        newMessage: String
    ) async throws -> String {
        var messages = conversationHistory
        messages.append(Message(role: "user", content: newMessage))
        
        let body = RequestBody(
            model: model,
            max_tokens: maxTokens,
            system: systemPrompt,
            messages: messages
        )
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 30
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            // Parse error message from Anthropic if available
            if let errorBody = try? JSONDecoder().decode(AnthropicError.self, from: data) {
                throw ClaudeError.apiError(errorBody.error.message)
            }
            throw ClaudeError.httpError(httpResponse.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        return decoded.content.first?.text ?? ""
    }
    
    struct AnthropicError: Codable {
        struct ErrorDetail: Codable { let message: String }
        let error: ErrorDetail
    }
    
    enum ClaudeError: LocalizedError {
        case invalidResponse
        case httpError(Int)
        case apiError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "Invalid response from AI service"
            case .httpError(let code): return "AI service error (code \(code))"
            case .apiError(let msg): return msg
            }
        }
    }
}
```

### Step 3: API Key Settings UI

In `SettingsView.swift`, add a new section `aiSection()` before or after the `aboutSection`. Add it to the main body's section list.

```swift
// In SettingsView body, add:
aiSection()

// New section:
private func aiSection() -> some View {
    Section {
        HStack {
            Image(systemName: "key.fill")
                .foregroundStyle(Theme.accent)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text("Anthropic API Key")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.text1)
                Text(apiKeyStored ? "Key saved — AI chat is active" : "Add key to enable AI chat")
                    .font(.system(size: 11))
                    .foregroundStyle(apiKeyStored ? Theme.gain : Theme.text3)
            }
            Spacer()
            Button(apiKeyStored ? "Update" : "Add") {
                showAPIKeyInput = true
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Theme.accent)
        }
        .padding(.vertical, 10)
        
        if apiKeyStored {
            Button(role: .destructive) {
                KeychainService.deleteAPIKey()
                apiKeyStored = false
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .frame(width: 32)
                    Text("Remove API Key")
                        .font(.system(size: 14))
                }
            }
        }
    } header: {
        Text("AI")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Theme.text3)
    } footer: {
        Text("Your API key is stored in iOS Keychain on this device only — never sent to STALK servers. Get a key at console.anthropic.com. Usage is billed to your Anthropic account.")
            .font(.system(size: 11))
            .foregroundStyle(Theme.text3)
    }
}
```

Add state vars to `SettingsView`:
```swift
@State private var showAPIKeyInput = false
@State private var apiKeyStored = KeychainService.getAPIKey() != nil
@State private var apiKeyInput = ""
@State private var apiKeySaving = false
```

Add sheet modifier:
```swift
.sheet(isPresented: $showAPIKeyInput) {
    APIKeyInputSheet(isStored: $apiKeyStored)
}
```

### Step 4: API Key Input Sheet

Create `STALK/Views/APIKeyInputSheet.swift`:

The sheet should:
- Show a `SecureField` for key entry (paste-friendly, not a keyboard nightmare)
- Show a "Paste from clipboard" button for convenience
- Validate format: Anthropic keys start with `sk-ant-` — show inline error if format is wrong
- On save: call `KeychainService.saveAPIKey()`, dismiss, update `isStored` binding
- Include a "Get your key at console.anthropic.com" link using `Link` + `URL`
- Show loading state while saving (Keychain write is fast, but UX matters)

### Step 5: Wire Real Calls in AIFullChatView

Update `AIFullChatView.swift` `sendMessage()` function:

```swift
func sendMessage(_ text: String) {
    let trimmed = text.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty, !isThinking else { return }
    
    // Existing pro gate (3 free messages)
    if !appState.settings.isPro {
        if appState.settings.aiMessagesUsed >= 3 {
            showPaywall = true
            return
        }
        appState.settings.aiMessagesUsed += 1
        appState.saveSettings()
    }
    
    messages.append(.init(role: .user, text: trimmed))
    input = ""
    isThinking = true
    
    // Convert chat history to ClaudeService.Message format
    let history = messages.dropLast().map {
        ClaudeService.Message(role: $0.role == .user ? "user" : "assistant", content: $0.text)
    }
    
    Task {
        defer { isThinking = false }
        
        guard let apiKey = KeychainService.getAPIKey() else {
            // No API key — show setup prompt
            messages.append(.init(role: .assistant, text: "To use AI chat, add your Anthropic API key in Settings → AI. Your key is stored privately on this device."))
            return
        }
        
        do {
            let response = try await ClaudeService.sendMessage(
                apiKey: apiKey,
                conversationHistory: Array(history),
                newMessage: trimmed
            )
            messages.append(.init(role: .assistant, text: response))
        } catch {
            messages.append(.init(role: .assistant, text: "Error: \(error.localizedDescription). Check your API key in Settings."))
        }
    }
}
```

### Step 6: Context Injection (Portfolio-Aware AI)

The AI is much more valuable if it knows what's in the user's portfolio. Add portfolio context to the first message in a new conversation:

In `AIFullChatView.swift`, when the view appears and `messages.isEmpty`, inject a hidden system context as the first user message (or use `ClaudeService.systemPrompt` extension):

```swift
.onAppear {
    if messages.isEmpty {
        // Build portfolio context string
        let portfolioSummary = buildPortfolioContext()
        // Store it — will be prepended to first real message's conversation history
        portfolioContext = portfolioSummary
    }
}

func buildPortfolioContext() -> String {
    guard !appState.positions.isEmpty else { return "" }
    let positions = appState.positions.map { p in
        "\(p.ticker): \(p.shares) shares @ avg $\(String(format: "%.2f", p.averagePrice))"
    }.joined(separator: ", ")
    return "User's portfolio: \(positions). Total value: $\(String(format: "%.2f", appState.totalValue))."
}
```

Prepend `portfolioContext` to the system prompt when making the first API call, so Claude knows the user's holdings from the first message.

## Why it matters

The AI chat is the most differentiated feature in STALK. A mock AI that returns hardcoded responses is an embarrassment — it'll get called out in every App Store review. Real Claude API calls make STALK feel like a personal financial analyst in your pocket. BYOK is the fastest path: no backend, no data liability, $0 server cost for STALK.

## Definition of Done

- [ ] `KeychainService.swift` created and working (save, read, delete)
- [ ] `ClaudeService.swift` created with correct Anthropic API headers and request format
- [ ] API key input UI in Settings → AI section (with format validation and clipboard paste)
- [ ] `APIKeyInputSheet.swift` built and dismisses correctly
- [ ] `AIFullChatView.sendMessage()` calls real Claude API when key is present
- [ ] Falls back gracefully (helpful message pointing to Settings) when no key is set
- [ ] Portfolio context injected into AI system prompt
- [ ] Error states handled: bad key (401), rate limit (429), network offline
- [ ] Build compiles and tested manually in simulator with a real API key
- [ ] Create PR from `feature/byok-ai` to main
- [ ] Log completion in `agents/memory/ios_dev_log.md`

## Notes

- Use `claude-3-5-haiku-20241022` as default (fast, cheap for users)
- Do NOT hardcode any API keys — Keychain only
- Do NOT log API keys to console even in debug
- If Luna delivers a design spec for the AI chat before this is done, apply her specs

---

## CTO Addendum (Maya — 2026-06-09)

Jordan, two corrections before you start:

### 1. Wrong model ID in this spec — use `claude-haiku-4-5`

The model ID `claude-3-5-haiku-20241022` in the CEO spec above is incorrect for our codebase. The correct model string is:

```swift
static let model = "claude-haiku-4-5"
```

This is the current Haiku model per the Anthropic API as of June 2026. Do not append date suffixes. Do not use `claude-3-5-haiku-20241022`.

### 2. Use streaming, not single-shot `URLSession.data(for:)`

The CEO spec uses `URLSession.data(for:)` which returns the full response only after the model finishes generating. On a slow connection or a long answer this gives the user a blank screen for 5–10 seconds, then text appears all at once. That feels broken.

Use `URLSession.bytes(for:)` with SSE parsing. Set `"stream": true` in the request body. Append each delta token to the streaming message bubble in real time.

Reference implementation: see `agents/memory/adr/ADR_002_byok_ai.md` → "URLSession streaming implementation" section for the exact SSE parsing loop.

### 3. `SecItemCopyMatching` typo in CEO spec

The CEO spec calls `SecCopyMatching(...)` — this function does not exist. The correct call is `SecItemCopyMatching(...)`. Use the `KeychainService` implementation in ADR-002 which is correct.

### 4. Keychain accessibility

Use `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` (not `kSecAttrAccessibleWhenUnlocked`). The `ThisDeviceOnly` suffix prevents the key from migrating via iCloud Keychain to other devices. Users should re-enter their API key on each device. This is intentional.

### 5. Required headers (exact values, no variation)

```
x-api-key: <key>
anthropic-version: 2023-06-01
content-type: application/json
```

Do not use `Authorization: Bearer`. Anthropic does not use Bearer tokens. `x-api-key` is the only authentication header.
