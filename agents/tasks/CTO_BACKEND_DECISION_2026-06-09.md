# Task: Final Backend Architecture Decision
**Assigned to:** Maya (CTO)
**Priority:** HIGH
**Due:** 2026-06-09
**From:** CEO Alex
**Status:** OPEN

## Context

STALK is 100% local-only today. No backend, no user auth, no server. This is intentional for v1, but the decision of which backend to use (and when to add it) is now blocking product roadmap decisions. Itamar needs a clear recommendation before he can decide on the Apple Developer Account, bundle ID, or any infrastructure spend.

The team has been circling Firebase vs. Supabase vs. "nothing for v1" without a decision. This task makes that decision official.

Current state of features requiring backend (from `COMPANY_STATE.md`):
- Backend/API: Not started
- User auth: Not started
- Social features (real): Not started
- Real StoreKit purchases require App Store Connect (no server needed, but Apple infra required)

## What I need

### Decision Framework

Evaluate the following four options. For each, provide:

**Option 1: No backend for v1 (launch local-only)**
- What features are permanently impossible without a backend?
- What features can be faked or deferred?
- How long can STALK realistically stay local-only before users expect more?
- What does migration look like when we eventually add a backend?
- Risk: if we launch local-only, can we add real social features in v2 without breaking existing users' data?

**Option 2: Firebase (Firestore + Auth + FCM)**
- Setup time estimate (hours to first working auth + data sync)
- Monthly cost at 1k users / 10k users / 100k users (model the Spark/Blaze tiers)
- Vendor lock-in risk: what does migrating off Firebase look like in 18 months?
- Firebase + SwiftUI: is there a clean native SDK, or are we fighting it?
- FCM for push: worth using over Apple's direct APNS?
- Anonymous auth: can users use the app without creating an account (just a device ID)?

**Option 3: Supabase (Postgres + Auth + Realtime)**
- Setup time estimate vs. Firebase
- Monthly cost at same tiers
- Supabase + SwiftUI: is there an official Swift client? (Check current state — there is a community one)
- Realtime subscriptions: how does this compare to Firestore's onSnapshot?
- Self-hostable: does this matter for STALK?
- Row-level security: relevant for STALK's social feed (users only see their own data + public posts)?

**Option 4: Minimal custom backend (Vapor or Hono on Cloudflare Workers)**
- Scope: just auth + user profile sync, use existing local storage for everything else
- Time to implement vs. BaaS options
- Cost: Cloudflare Workers free tier is generous — model the numbers
- Is this overkill for 0→100 users?

### Required Analysis

**1. Social feed requirements**
The social feed is currently a static UI. For it to be real, we need:
- User profiles stored somewhere
- Posts/comments stored somewhere
- Follow graph stored somewhere
- Real-time or near-real-time updates

Which backend option handles this most cleanly for a small team (1 iOS dev)?

**2. Data ownership and privacy**
STALK's current privacy policy says: "zero data collection, all data stored locally on device."

If we add a backend:
- What data would move server-side?
- Does this require a new privacy policy? (Yes — but what specifically needs to change?)
- GDPR/CCPA implications: is STALK's target market (Israel first, then global) subject to these?
- What's the minimum viable backend that still lets us say "we don't sell your data"?

**3. Migration path**
If we launch v1 as local-only and add backend in v2:
- User's existing positions are in `UserDefaults` / local JSON
- How do we migrate local data to cloud on first sign-in without losing it?
- Write the migration strategy (even if 1 paragraph)

**4. Cost model**
For your recommended option, build a cost model:
- Month 1 (100 users): $X/mo
- Month 6 (1,000 users): $X/mo
- Month 12 (10,000 users): $X/mo
- At what user count does the cost become a real concern (>$100/mo)?

### Final Deliverable

Make a recommendation. Not "it depends" — make a call.

Format:
```
RECOMMENDATION: [Option X]
RATIONALE: [2-3 sentences]
WHEN TO START: [e.g., "After first 100 users" or "Before App Store launch"]
FIRST STEPS: [Numbered list of first 3 actions]
DEFERRED: [What we explicitly decide NOT to do now, and when to revisit]
```

Then: a second-place option with brief explanation of when it would become the right choice instead.

## Why it matters

Every week we delay this decision, Jordan is writing iOS code that may need significant refactoring when a backend is added. Features like "real social feed," "cross-device sync," and "web companion" are blocked until this is decided. Itamar can't commit $99 to Apple Developer without knowing the full infrastructure picture. This decision cascades into every other product decision this quarter.

## Definition of Done

- All four options evaluated with cost models
- Social feed requirements analyzed for each option
- Data/privacy implications addressed
- Migration path from local-only to cloud written
- A single, definitive recommendation made (not hedged)
- Output written to `agents/memory/engineering/backend_decision_2026-06-09.md`
- Status updated in this task file with recommendation summary (3 sentences max)
- Flag any blockers that require Itamar's input (e.g., budget approval, legal questions)
