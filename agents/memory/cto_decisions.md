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
| 2026-06-24 | Earnings Calendar: recommend Finnhub ($9–99/mo tier) for v1 launch. | Real-time earnings data, API stability > Alpha Vantage, broader global coverage > IEX Cloud (US-only), lower cost variability than IEX. Free tier insufficient (5 calls/min, no earnings endpoint). Finnhub Pro ($49/mo) unlocks earnings calendar + company news. Acceptable for v1 pilot phase. Revisit cost at scale (v1.1+). |
| 2026-06-24 | Backend confirmed: no server for v1. Local + mock social. Migrate to Supabase v1.1 post-launch. | Blocking auth + real-time feed adds 3–4 weeks with zero user value at this stage. Jordan: code mock social feeds (static posts, fake follows) with `@Observable` state. Real data sync can be added post-launch via Supabase migration path. |

## Technical Risks Flagged
- **Earnings data freshness:** Finnhub API has ~2-hour latency on earnings announcements. Acceptable for v1 (daily app opens). Consider real-time IEX Cloud upgrade if earnings alerts become core retention driver.
- **API key management:** BYOK + Finnhub key both require Keychain. Document in onboarding. No server = no key rotation; flag for security audit before public launch.
- **Mock social feed stale on reinstall:** Local state only. Warn Itamar: social features are non-persistent until backend added. UX implication: "Your follows reset on app reinstall" — acceptable for v1 beta.

## Action Items for Jordan
1. **Earnings Calendar integration:** Wire Finnhub API into `EarningsCalendarView`. Endpoint: `/calendar/earnings?from=YYYY-MM-DD&to=YYYY-MM-DD`. Parse response, filter to user's portfolio tickers, display in "Upcoming" card on For You tab. Effort: 4 hours (API + UI). Finnhub key stored in Keychain alongside Claude key.
2. **Mock social feeds:** Update `SocialFeedView` to use `@Observable` state instead of Firebase calls. Static posts + likes, fake user profiles. Replace with Supabase queries in v1.1. Effort: 3 hours.
3. **Quote cache implementation:** Apply TTL cache in `QuoteService.swift` as outlined above. Add error banner in portfolio view. Effort: 2 hours.
