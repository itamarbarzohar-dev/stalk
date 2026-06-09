# CTO Decisions & Technical Debt Register

**Maintainer:** Maya (CTO)
**Last updated:** 2026-06-09

---

## Architecture Decision Records

| ADR | Title | Status |
|---|---|---|
| ADR-001 | Backend Architecture | Accepted — No backend for v1. Supabase for v1.1. |
| ADR-002 | BYOK AI Architecture | Accepted — Keychain + URLSession direct to Anthropic API. |

---

## Top 3 Technical Debt Items

These are the three highest-severity issues in the codebase as of the v1 code audit (2026-06-09). Each one has a concrete remediation path. None are blocking v1 ship, but items #1 and #2 must be resolved before v1.1 (the Supabase / social launch).

---

### DEBT-001: `extension String: @retroactive Identifiable` in `ContentView.swift`

**Severity:** High — will cause build breakage in a future Swift/SwiftUI release
**File:** `STALK/ContentView.swift`

**What it is:**

```swift
extension String: @retroactive Identifiable {
    public var id: String { self }
}
```

This adds an `Identifiable` conformance to `String`, which is a type defined in the Swift standard library — not in STALK. This is a retroactive conformance. The `@retroactive` attribute suppresses the current compiler warning, but the underlying problem remains: if Apple adds `Identifiable` to `String` in a future Swift version (likely, given SwiftUI's trajectory), this conformance will silently conflict and may cause undefined behavior or a compile error that is hard to diagnose.

**Remediation:** Wherever this is used (in `ForEach` or `List` over `[String]`), replace with an explicit `.id(\.self)` modifier:

```swift
// Before
ForEach(items) { item in ... }

// After
ForEach(items, id: \.self) { item in ... }
```

Then delete the `extension String: @retroactive Identifiable` block entirely.

**Effort:** 30 minutes. Find every `ForEach` over `[String]` in the codebase and add `id: \.self`.

---

### DEBT-002: `settings.isPro` and `settings.aiMessagesUsed` stored in `UserDefaults`

**Severity:** Critical for monetization — bypassable pro gate
**File:** `STALK/AppState.swift` (`STALKSettings` struct)

**What it is:**

```swift
var isPro: Bool = false
var aiMessagesUsed: Int = 0
```

Both fields live inside `STALKSettings`, which is serialized to `UserDefaults` under the key `"stalk_settings"`. Any user with access to a jailbroken device — or who uses a `UserDefaults` editor app available on the App Store — can set `isPro = true` and `aiMessagesUsed = 0` without purchasing a subscription. This is not theoretical: it is a known trivial bypass for apps using `UserDefaults` as a paywall gate.

**Remediation (two-phase):**

Phase 1 (v1, before App Store submission): Move `isPro` gate out of `UserDefaults` and into a runtime check against `Transaction.currentEntitlements`. The `restorePurchases()` function in `AppState.swift` already does this correctly on explicit user action — extend it to run at every app launch (`.task {}` in `STALKApp.swift`). This closes the UserDefaults manipulation vector without requiring a backend.

Phase 2 (v1.1, with Supabase): Server-side entitlement validation. Supabase `users` table stores `is_pro`. StoreKit receipt is validated server-side. Client-side `settings.isPro` becomes a display cache only.

For `aiMessagesUsed`: in v1.1, move the free message counter to Supabase (per-user, server-side). Until then, accept that the 3-message free tier is easily bypassed and focus on conversion rather than enforcement.

**Effort for Phase 1:** 1 hour. Wire `Transaction.currentEntitlements` check to app launch.

---

### DEBT-003: No caching or error propagation in `QuoteService.swift`

**Severity:** Medium — will cause throttling and silent data failures at scale
**File:** `STALK/Services/QuoteService.swift` (and callers in `AppState.swift`)

**What it is:**

Every call to `refreshPortfolio()` or `refreshMarket()` fetches all quotes from scratch from Yahoo Finance's unofficial API. There is no TTL cache. There is no rate limiting. There is no error propagation — `fetchManyQuotes` uses `try?` internally, so failed fetches return `nil` silently and the UI shows stale or zero data with no indication to the user.

Specific issues:

1. **No TTL cache.** `refreshMarket()` fetches 30+ tickers (sectors + indices + trending) on every call. `refreshPortfolio()` fetches every position ticker on every BGAppRefreshTask execution. Yahoo Finance will throttle IPs that make too many requests. There is currently nothing to prevent this.

2. **Silent `try?` error swallowing.** In `fetchManyQuotes`, failed individual ticker fetches return `nil` and are silently dropped. The portfolio view will show the last known price (or zero) with no error state. The user has no idea a fetch failed.

3. **Yahoo Finance is unofficial and undocumented.** The URL `query1.finance.yahoo.com/v8/finance/chart/` is not a published API. It has no SLA. It has broken before. We have no fallback.

**Remediation:**

For v1: Add a simple TTL cache (60 seconds minimum) in `QuoteService.swift`. Any call within the TTL window returns the cached value. This is ~20 lines of code.

```swift
// In QuoteService.swift
private static var cache: [String: (quote: Quote, fetchedAt: Date)] = [:]
private static let cacheTTL: TimeInterval = 60

static func shouldRefetch(_ ticker: String) -> Bool {
    guard let entry = cache[ticker] else { return true }
    return Date().timeIntervalSince(entry.fetchedAt) > cacheTTL
}
```

For error propagation: change `fetchManyQuotes` to return a `Result` type or throw, and surface fetch errors in the portfolio view (a non-blocking banner "Some prices couldn't be updated" is sufficient).

For Yahoo Finance dependency risk: acceptable for v1. For v1.1, evaluate Polygon.io (free tier: 5 API calls/minute, real-time for US stocks) as a more stable alternative. Keep Yahoo Finance as fallback.

**Effort:** 2 hours for TTL cache + basic error surface in UI.

---

## Decisions Log

| Date | Decision | Rationale |
|---|---|---|
| 2026-06-09 | No backend for v1. Supabase for v1.1. | See ADR-001. Social features are mock in v1; introducing auth + backend before launch adds 3–4 weeks for zero user value. |
| 2026-06-09 | BYOK AI via Keychain + URLSession. No backend proxy. | See ADR-002. Zero server cost, zero data liability. User's API key never leaves device. Swift has no official Anthropic SDK — raw URLSession is the correct approach. |
| 2026-06-09 | `claude-haiku-4-5` as the BYOK model. | Cost-optimized for in-app chat. Users pay per token; Haiku is ~5–10x cheaper than Sonnet for equivalent portfolio Q&A quality. |
| 2026-06-09 | Firebase rejected in favor of Supabase (v1.1). | Firestore document model is a poor fit for relational social data (users, posts, follows, likes). Supabase PostgREST + Postgres handles feed queries natively. Zero binary cost (no SDK). |
