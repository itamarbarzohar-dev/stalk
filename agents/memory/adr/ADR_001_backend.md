# ADR-001: Backend Architecture Decision

**Status:** Accepted
**Date:** 2026-06-09
**Author:** Maya (CTO, STALK)
**Decider:** Itamar Bar Zohar (CEO)

---

## Context

STALK v1 ships as a local-first iOS app. All data (positions, settings, streak, ATH) lives in `UserDefaults`. The social feed and leaderboard are currently static mock data. We need to decide: introduce a backend now, or ship v1 without one?

---

## What Actually Requires a Backend

| Feature | Backend Required? | Notes |
|---|---|---|
| Portfolio storage | No — UserDefaults works for v1 | A backend unlocks multi-device sync; not a v1 blocker |
| Real quote data | No — Yahoo Finance API is free and unauthenticated | Already implemented in `QuoteService.swift` |
| Push notifications (price alerts) | No — BGAppRefreshTask + UNUserNotificationCenter already implemented | Local notifications cover v1 |
| Push notifications (APNS server push) | Yes | Required only if we want server-initiated pushes (e.g., "NVDA just crossed $200") |
| Real social feed | Yes — real user posts, follows, likes | Currently all hardcoded in `Models.swift` |
| Leaderboard (real) | Yes | Currently mock `WORLD_GAINERS` data |
| Auth (user accounts) | Yes | Required before any real social feature |
| AI chat | No — BYOK architecture removes this dependency | See ADR-002 |
| StoreKit receipt validation (server-side) | Optional | Apple's StoreKit 2 client-side verification is sufficient for v1 |

**v1 verdict on social:** The `Feed` tab and `For You` leaderboard are currently fully mocked. This is acceptable for v1 launch — they demonstrate the product vision to early users and investors without requiring a backend.

---

## Options Evaluated

### Option A: Firebase
- Firestore for posts/follows/likes (real-time listener support)
- Firebase Auth (Google/Apple Sign-In)
- Cloud Messaging (FCM) for server-side push
- Firebase binary adds ~5MB to the IPA
- Vendor lock-in to Google; Firestore's document model is awkward for relational data (e.g., querying "all posts by users I follow, sorted by time")
- Free tier: 1GB Firestore storage, 50K reads/day — adequate for early growth

### Option B: Supabase
- Postgres: relational schema is a natural fit for users/posts/follows/likes
- PostgREST + realtime subscriptions over WebSocket
- Supabase Auth supports Apple Sign-In natively
- Open source — self-hostable if we ever want to avoid vendor costs
- Binary impact is a lightweight REST client, not an SDK; we write our own thin `URLSession` wrapper (~0 binary cost)
- Free tier: 500MB database, 2GB bandwidth — adequate for v1
- Row-level security (RLS) policies replace Firebase security rules with standard SQL

### Option C: Nothing for v1 (local only)
- Ship fastest
- No backend maintenance
- Social features remain mock forever — blocks the core value prop (comparing your portfolio performance against real people)

---

## Decision

**Ship v1 with no backend. Wire Supabase in v1.1 (post-launch).**

### Rationale

v1 will launch on the App Store with the following scope:
- Portfolio tracking: fully functional (local)
- AI chat: fully functional (BYOK, see ADR-002)
- Price alerts: fully functional (local push)
- Social/Feed/Leaderboard: UI-complete with curated mock data

This is not a shortcut — it is the correct sequencing. Introducing auth + a backend before App Store submission adds 3–4 weeks of development time, App Review risk (Apple scrutinizes new social apps), and infrastructure cost with zero paying users to validate it.

When we do introduce a backend (v1.1, targeting 30 days post-launch), **we will use Supabase**, not Firebase. Here is why:

1. **Schema fit.** Our data model (`users`, `positions`, `posts`, `follows`, `likes`) is inherently relational. Postgres handles "show me all posts by users I follow, newest first" in a single SQL query. Firestore requires client-side fan-out or expensive Cloud Functions.

2. **Zero binary cost.** No SDK. All Supabase interaction goes through `URLSession` hitting the PostgREST endpoint. The app binary stays small.

3. **Apple Sign-In is first-class.** Supabase Auth supports Sign in with Apple natively. We need Apple Sign-In to comply with App Store guidelines (required when we offer any social login).

4. **Open source / no lock-in.** If Supabase pricing becomes a problem at scale, we can migrate to self-hosted Supabase on a VPS. Firebase offers no such exit path.

5. **RLS over Firestore rules.** Postgres Row Level Security is SQL — every iOS developer on the team can reason about it. Firebase security rules are a proprietary DSL.

Firebase's real-time listeners are its strongest differentiator, but Supabase's WebSocket realtime is sufficient for our feed refresh cadence (pull-to-refresh + 30s polling for v1 social is acceptable).

---

## v1.1 Backend Plan (Post-Launch)

When we wire Supabase:

1. **Auth:** Supabase Auth with Apple Sign-In. No email/password.
2. **Schema:**
   - `users(id, apple_sub, display_name, username, bio, avatar_url, is_pro, created_at)`
   - `positions(id, user_id, ticker, shares, avg_cost, created_at)` — optional sync; primary source remains on-device
   - `posts(id, user_id, text, tickers[], created_at)`
   - `follows(follower_id, followee_id, created_at)`
   - `likes(user_id, post_id, created_at)`
3. **Client layer:** A single `SupabaseClient.swift` wrapping `URLSession` with the `apikey` and `Authorization` headers. No third-party SDK.
4. **Realtime:** Supabase WebSocket channel on `posts` table for the feed. Fallback: 30s polling if WebSocket fails.

---

## What Does NOT Change for v1

- `UserDefaults` remains the source of truth for positions and settings
- `QuoteService.swift` continues hitting Yahoo Finance directly
- `NotificationService.swift` local push architecture is unchanged
- StoreKit 2 client-side receipt validation is sufficient — no server-side validation for v1
