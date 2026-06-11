# STALK — Strategy & Roadmap
> Last updated: June 2026

---

## What is STALK

STALK is a native iOS portfolio tracking app for retail investors who want to feel the emotional pulse of their money — not just stare at a spreadsheet. It combines live portfolio P&L, AI-powered market context that is personalized to your specific holdings, gamified engagement mechanics (Portfolio Health Score, streaks, ATH alerts), and a social feed showing what other investors are watching. The target user is the engaged retail investor who checks their portfolio multiple times a day and wants more than a free broker app provides, but doesn't want to pay $200/yr for TradingView when they're not a day trader. STALK is priced at $6.99/mo — less than one bad trade.

---

## The Opportunity

The retail investing market exploded after 2020 and has not contracted back. There are 60+ million brokerage accounts in the US alone. Robinhood has 24M funded accounts. The free tools available to retail investors — Robinhood's built-in tracker, Yahoo Finance, Webull — are all designed around brokerage conversion or advertising revenue, not around helping users understand and manage their portfolios. The result is a massive gap: engaged retail investors with real money and no premium tool built for them.

**Why now:** Two trends converge in 2026. First, LLM APIs are cheap enough that a solo founder can ship genuine AI personalization at consumer price points. Second, Perplexity Finance has demonstrated that retail investors will use AI-powered finance tools — but Perplexity doesn't know what you hold. STALK does. That's the wedge.

**What incumbents miss:** Yahoo Finance serves 85M+ users with display ads. TradingView serves professional traders at $300+/yr. Robinhood makes money on order flow and margin, not portfolio intelligence. None of these are building for the investor who has $15K spread across 8 stocks, checks their portfolio at lunch, and wants to know what this week's NVDA earnings means for their specific position.

---

## Product Vision

At 100K users, STALK is the app that serious retail investors recommend to their friends. It is the first thing you check in the morning — before Twitter, before CNBC. The personalized morning push tells you what your largest mover did overnight, in dollars, before you've made coffee. The Portfolio Health Score gives you a number to improve. The Earnings Calendar tells you which of your holdings reports this week and what the AI thinks the market expects. The social feed is full of real people who hold similar stocks. The For You tab surfaces Whale Alert teasers that make you feel like you're seeing what the smart money is doing.

The product strategy is the Hook Model applied to personal finance: external triggers (personalized push notifications) pull users back, variable rewards (market moves, whale alerts, earnings surprises) keep them engaged, and investment mechanics (portfolio history, health score trends, notes) make switching costly. Every feature on the roadmap must serve one of those three stages or it does not get built.

---

## Current State (June 2026)

**What is built and running:**
- SwiftUI app running clean in iOS Simulator (iPhone 17, iOS 26.5 SDK)
- Portfolio tracking with live quotes via Yahoo Finance (no backend required)
- Daily Brief, For You tab, Market view with indices
- Social feed and leaderboard (UI-complete, currently mock data — acceptable for v1)
- Freemium paywall via StoreKit 2 — product code complete, not yet live in App Store
- Onboarding (4-screen flow with spring transitions, push notification prompt)
- Local push notifications (BGAppRefreshTask, price threshold alerts, market open)
- BYOK Claude AI (real Anthropic API via Keychain, streaming SSE, `claude-haiku-4-5`)
- Dark mode (tab bar bug fixed)
- Price alert threshold UI (per-stock above/below with bell badge)
- Sector Heat Map (11 S&P sectors, color-coded, in MarketView)
- Portfolio Health Score (0-100 gamified arc card with real-time computation)
- AI Market Context Card (auto-advancing insights, indigo gradient border)
- Earnings Calendar Card (user stocks highlighted, EPS vs. estimate)
- Trending Tickers Feed (6 tickers, mention count, reason pills)
- Animated components system (stagger entrance, numeric transitions, ATH pulse)

**What is blocked (not yet buildable):**
- App Store listing — requires Apple Developer Program enrollment ($99/yr, Itamar action)
- Real StoreKit purchases — requires App Store Connect product IDs (after Dev account)
- Backend / user auth / real social features — deferred to v1.1 (Supabase, 30 days post-launch)
- Personalized server-push notifications — requires backend (v1.1)
- Bundle ID still `ITAMARAZI.STALK` — needs change to `com.itamar.stalk` before submission

**Revenue: $0. Users: 0. Stage: Pre-launch, founder review mode.**

---

## Business Model

Seven revenue models were evaluated. The decision is: **freemium subscription as primary, broker affiliate as supplemental. Everything else is deferred.**

### Primary: Freemium Subscription — $6.99/mo or $59.99/yr
- Free tier: portfolio tracking (unlimited stocks), live prices, basic P&L, earnings calendar dates, sector heat map (static), economic calendar, trending tickers, analyst consensus (current), portfolio health score (number only), personalized morning push (free — this is the hook, not the product)
- Pro tier: AI market context (real-time + per-ticker), health score breakdown + history, options flow / whale alerts, analyst rating history + firm breakdown + alerts, AI earnings predictions + portfolio impact modeling, sector exposure vs. your portfolio, "what if" scenario modeling
- Net ARPU (post-Apple cut): $58.72/yr per monthly subscriber in Year 1, $71.30/yr in Year 2+
- Annual plan net: $34.99 Year 1, $42.49 Year 2+

### Supplemental: Broker Affiliate
- CTA during onboarding and in Settings: "Don't have a brokerage? Get started with Interactive Brokers"
- Bounty: $200/funded account (IBKR), $50-100/funded account (Webull)
- No Apple cut — 100% retained by STALK
- No backend required — client-side deep link

### Deferred Revenue Streams (with trigger conditions)
| Model | When to revisit |
|-------|-----------------|
| Data licensing | 25K+ MAU with real portfolio data + backend live |
| Premium market data add-on | $5K+ MRR, can absorb fixed data API costs ($1K-5K/mo) |
| B2B / White-label | Proven PMF + inbound enterprise interest |
| In-app advertising | Only if a direct brand deal emerges (e.g., broker sponsors Daily Brief) |
| Transaction-based (brokerage) | Year 3+, 500K+ users, regulatory infrastructure viable |

**The single most important metric: Month-3 subscription churn rate.** If churn >8%/month, the product has a retention problem — fix before scaling acquisition. If churn <4%/month, pour fuel on it.

---

## Monetization by Stage

### Day 1 (App Store launch)
- Freemium subscription live: StoreKit paywall gated on Pro features
- Broker affiliate CTA: one placement in onboarding, one in Settings
- Revenue target: $0–$200 (first trial conversions)

### Month 3
- Target: $376–$1,580/mo (conservative to optimistic)
- Conservative: 1,200 MAU, 36 paid subscribers at 3% conversion, $176 net MRR + ~$200 affiliate
- Optimistic: 4,000 MAU, 200 paid subscribers at 5% conversion, $980 net MRR + ~$600 affiliate
- Key action: analyze which Pro features drive the most upgrade intent; A/B test paywall timing

### Month 6
- Conservative target: ~$2K/mo (8K MAU, 240 paid, $1,176 MRR + $800 affiliate)
- Optimistic target: ~$8K/mo (25K MAU, 1,250 paid, $6,125 MRR + $2,000 affiliate)
- Unlock: if at $3K+ MRR, evaluate a real-time data add-on (Polygon.io partnership)

### Month 12
- If on conservative trajectory: evaluate data licensing pipeline (need backend + 25K+ MAU)
- If on optimistic trajectory: evaluate paid acquisition (Apple Search Ads, Instagram) — CAC for fintech iOS is $5-25/install
- Social features (real) should be live via Supabase v1.1

### Year 2
- Data licensing becomes viable at 50K+ MAU
- Premium data tier ($12.99/mo) viable if monthly churn is proven stable
- Referral program active ("give 1 month, get 1 month")
- iPad / macOS app expands TAM for power users

---

## The Path to $5K MRR (Ramen Profitable)

$5K MRR requires approximately:
- **Conservative path:** 15,000–17,000 MAU at 3% conversion = ~500 paid subscribers at $6.99/mo blended net (~$9.80/mo blended after annual plan mix) = ~$4,900 MRR
- **Optimistic path:** 10,000 MAU at 5% conversion = 500 paid subscribers = same

What needs to happen to get there:

1. **Launch on App Store** — requires Apple Developer enrollment (Itamar action, unblocks everything)
2. **Generate first 1,000 MAU** — Product Hunt launch, r/stocks, r/investing, r/StockMarket posts, personal investor network (10-20 contacts), organic ASO
3. **Measure and fix churn at Day 30** — if >10%/month, the free tier is not forming habits before users hit the paywall; fix by improving morning push personalization and Daily Brief content quality
4. **Activate affiliate revenue** — one IBKR affiliate link added pre-launch, generates $100-300/mo supplemental at 1K MAU
5. **Paywall optimization at Month 2** — analyze which Pro gates convert best; the top performers based on the product analysis are: Whale Alerts tease (highest intent for sophisticated users), AI earnings prediction (night before earnings = highest emotional moment), Portfolio Health Score breakdown (score drops = anxiety = conversion)
6. **Referral program at Month 4** — "give a friend 1 month free, get 1 month free" drives word-of-mouth without discounting the brand

At $5K MRR: STALK is ramen profitable for a solo founder in Israel. This validates PMF and unlocks the decision to invest in backend infrastructure, paid acquisition, and social features.

---

## Product Roadmap

### P0 — Complete (Launch Ready)
All core features are done: portfolio tracking, live prices, Daily Brief, For You tab, market view, FOMO mechanics, onboarding, paywall (code), push notifications, dark mode, BYOK AI, price alerts.

One remaining P0 item: **bundle ID change** (`ITAMARAZI.STALK` → `com.itamar.stalk`) — requires Itamar to confirm the new ID before Jordan makes the change.

### P1 — Addictiveness Layer (In Progress / Next Sprint)

| # | Feature | Why | Status |
|---|---------|-----|--------|
| 13 | Sector Heat Map | Visual daily ritual, color = emotion | Done |
| 14 | Portfolio Health Score | Gamified loop, anxiety = opens | Done |
| 15 | AI Market Context Card | Hyper-personalized = sticky | Done |
| 16 | Earnings Calendar | Urgency drives daily opens | Done |
| 17 | Trending Tickers Feed | Social proof + FOMO | Done |
| 18 | News feed per stock | Top 3 articles per holding | Planned |
| 19 | Analyst ratings + price targets | "Goldman upgraded" = daily check | Planned |
| 20 | 52-week high/low indicator | Quick visual dopamine | Planned |
| 21 | Portfolio performance chart (1D/1W/1M/1Y) | Core emotional feedback loop | Planned |
| 22 | Individual stock chart | Expected by every user | Planned |
| 23 | Watchlist | Aspiration + buy intent | Planned |
| 24 | Pre/post-market prices | Power user daily ritual | Planned |
| 25 | Economic calendar | Macro-aware users check before any news | Planned |
| 26 | AI portfolio deep dive | Emotional investment in AI | Planned |
| 27 | Custom % move / volume spike alerts | Safety net feature = retention | Planned |
| 28 | Home screen widget | Portfolio P&L without opening app | Planned |

### P2 — Social + Monetization Depth
Broker affiliate integration, portfolio import (CSV/Plaid), real social feed (Supabase v1.1), follow system, AI trade ideas, options flow / dark pool data, short interest, dividend tracker, tax lot tracking, iPad/macOS app, referral program.

**Do not start P2 features before P1 is complete and App Store is live.** Every hour spent on social infrastructure before launch is an hour not acquiring the first 1,000 users that validate whether the product is worth building social for.

---

## Key Metrics to Watch

| Metric | Target | Why |
|--------|--------|-----|
| D7 retention | >35% | Industry baseline for finance apps is 20-25%; must beat it |
| D7 retention (push-receiving users) | >45% | Personalized push should 2x baseline retention |
| Month-3 subscription churn | <6%/month | Above 8% = leaky bucket, fix product before scaling |
| Free → Pro conversion rate | 3-5% of MAU | 2% is floor; 5-8% achievable with strong paywall triggers |
| Push notification tap-through | >30% | Industry average for finance is 8-12%; personalized should be 2.5-3x |
| Push opt-in rate (onboarding) | >70% | Value framing at notification prompt is critical |
| Daily opens per paying user | 2+ | Below 1 = churn risk within 60 days |
| Avg session after earnings notification | >10 min | This is the highest-engagement session type |
| Net MRR (Month 3) | $376-$1,580 | Conservative to optimistic range |
| Affiliate conversions (Month 3) | 2-5 funded accounts | $200-500 supplemental at 1,200-4,000 MAU |

---

## Decisions Made

### Backend Architecture (ADR-001)
**Decision:** No backend for v1. Supabase for v1.1, 30 days post-launch.

Rationale: Introducing auth + backend before App Store submission adds 3-4 weeks of development time with zero paying users to validate the need. Social feed ships as curated mock data for v1 — this demonstrates the product vision without requiring infrastructure. When backend is introduced, it will be Supabase (Postgres) not Firebase (Firestore) because the data model is inherently relational (`users`, `posts`, `follows`, `likes`), Supabase has zero binary impact (URLSession wrapper, no SDK), supports Apple Sign-In natively, and is open source / self-hostable.

### AI Architecture (ADR-002)
**Decision:** BYOK (Bring Your Own Key) via iOS Keychain. No backend AI proxy.

Rationale: User provides their own Anthropic API key, stored in Keychain (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`). This eliminates backend infrastructure for AI entirely, keeps marginal cost per user at zero, and removes the risk of STALK's API costs scaling faster than revenue. Model is `claude-haiku-4-5` — 5-10x cheaper than Sonnet, sufficient capability for portfolio Q&A. API key stored in Keychain (not UserDefaults) because UserDefaults is readable in unencrypted iCloud backups.

### Monetization (CRO + CPO)
**Decision:** Freemium subscription ($6.99/mo / $59.99/yr) + broker affiliate supplemental. Ads explicitly rejected.

Rationale: Subscription is the only model that can generate revenue within 6 months of launch, has no additional technical requirements (StoreKit 2 is already built), scales with user growth through compounding MRR, and aligns incentives correctly — STALK makes money by delivering value, not by selling attention or order flow.

**Pricing:** $6.99/mo or $59.99/yr with 7-day free trial. Do not change this. The price is intentionally below the "do I need to think about this?" threshold while being above commodity apps.

**Paywall philosophy:** Never gate on session 1-2. Optimal trigger window is day 7-14 when habit is forming. Best trigger moments (in conversion order): Whale Alert tease on a stock you hold, AI earnings prediction night before earnings, Portfolio Health Score breakdown after score drops, AI real-time context during volatile market hours.

### Social Features
**Decision:** Ship v1 with curated mock data. Real social requires Supabase (v1.1).

The Feed tab and For You leaderboard are fully UI-complete and demonstrate the product vision. Early users understand what the app will become. This is not a deception — it's the correct sequencing for a pre-launch product.

### Pricing
$6.99/mo or $59.99/yr confirmed. The $59.99 annual plan at 30% Apple cut year 1 = $41.93 net per subscriber. At $6.99/mo with 30% cut = $4.89/mo net year 1. After year 1, Apple's cut drops to 15%: $5.94/mo net. Annual plan converts 30% of subscribers at ~6x lower churn than monthly.

---

## What Itamar Needs to Do

These are ordered by urgency. Items 1 and 2 are hard blockers — nothing ships until they are done.

1. **Enroll in Apple Developer Program.** Go to developer.apple.com, pay $99/yr. This is the single action that unblocks App Store submission, StoreKit live purchases, TestFlight external testing, and push notification entitlements. No agent can do this for you.

2. **Create StoreKit products in App Store Connect.** After enrolling, create two subscription products: `com.itamar.stalk.pro.monthly` at $6.99 with a 7-day free trial, and `com.itamar.stalk.pro.annual` at $59.99 with a 7-day free trial. Jordan's paywall code is already wired to these exact product IDs.

3. **Confirm the bundle ID change: `ITAMARAZI.STALK` → `com.itamar.stalk`.** This affects App Store listing, push notification entitlements, StoreKit product IDs, and Keychain service identifiers. Confirm the new ID before Jordan makes the change — it cannot be reversed after App Store submission.

4. **Sign up for Interactive Brokers affiliate program.** Go to interactivebrokers.com/affiliates. Takes 1-3 business days. Pays $200 per funded account. This is the fastest path to supplemental revenue and requires zero engineering once you have the link. Do this before App Store launch so the affiliate CTA is live on day one.

5. **Review ADR-001 (backend decision).** Maya has decided: no backend for v1, Supabase for v1.1. If you disagree with Supabase as the v1.1 choice, say so now — the data schema and auth architecture will be built around this decision post-launch.

6. **Commission an app icon.** The current icon is a programmatic placeholder (indigo square + white "S"). It will pass App Store review technically but will hurt conversion on the App Store listing page. Options: hire a designer ($200-500 on Fiverr/Dribbble), use Figma yourself, or proceed with the placeholder and replace it in v1.1. Make the call.

7. **Plan the launch.** Before submitting to App Store: draft your Product Hunt post, identify 3-4 relevant subreddits (r/stocks, r/investing, r/StockMarket, r/personalfinance), write your Reddit launch post (first-person founder story performs best), and identify 10-20 personal contacts who actively invest. The first 200 users come from your network, not the App Store algorithm.

8. **Decide on target market: Israel first or global?** Most broker affiliate programs (IBKR, Webull) require US residents for referral bounties. If you launch globally first, affiliate conversion rates drop. If you launch Israel-first, consider Israeli broker partnerships (e.g., Interactive Brokers Israel, eToro). This affects both the affiliate strategy and your initial ASO keyword targeting.
