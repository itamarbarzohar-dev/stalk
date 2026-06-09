# Business Model: CPO Take
**Author:** Sam (CPO)
**Date:** 2026-06-09
**Audience:** Itamar + leadership team

---

## TL;DR

The right model for STALK is a **freemium subscription with a hard habit loop before the gate**. Free must be so good users form a daily ritual with it. Pro must feel like a superpower on top of that ritual — not a ransom note blocking the core experience.

$6.99/mo or $49.99/yr is the right price. Don't touch it.

---

## 1. Which Business Model Fits the Product Vision

**The vision is addiction.** The most addictive apps in the world — Duolingo, Robinhood, Strava, BeReal — share one architecture: a free tier that actually delivers the core dopamine hit, then a paid tier that amplifies it.

STALK's core dopamine hit is **seeing your portfolio move**. That must be free, forever. Charging for the portfolio view destroys the habit loop before it forms.

The right model is:

> **Freemium subscription (SaaS)**
> Free = full portfolio tracking, basic market view, Daily Brief, 3 AI messages
> Pro = AI chat unlimited, Whale Alerts, Short Squeeze Radar, premium themes, advanced price alerts, leaderboard full access

Why not alternatives:

| Model | Why it fails for STALK |
|---|---|
| Fully free + ads | Ads destroy the premium feel. Finance users have high intent and high LTV — don't trade LTV for CPM. |
| Pay-once IAP | No recurring revenue. No incentive to keep shipping features. Kills LTV math. |
| BYOK-only (user brings API key) | Severely narrows TAM. Casual investors won't go get an OpenAI key. |
| Brokerage integration rev-share | No brokerage relationships, no FINRA license. Not v1. |
| Data licensing | Zero user base. Not relevant until 100k+ users. |

**Freemium subscription wins** because it lets every user form a habit (free), then converts the most engaged users (pro) after they're already dependent.

---

## 2. Free vs Pro Feature Split

### The principle: Free gets the hook, Pro gets the power

Every user needs to form a **daily open habit** before they ever see a paywall. The paywall should feel like "of course I need this" not "wait, why am I being charged for this."

**Free tier — must have these:**
- Full portfolio tracking (add unlimited positions, see P&L)
- Daily Brief (daily trigger, biggest retention driver)
- Market View (price context)
- For You feed (social proof, FOMO)
- 3 AI messages per lifetime (enough to get hooked, not enough to be satisfied)
- Basic push notifications (market open, 5% move alert)
- 6 themes (indigo, rose, emerald, ocean, amber, pink)

**Pro tier — must be behind the gate:**
- Unlimited AI chat (most compelling single upgrade driver)
- Whale Alerts (options flow) — the fantasy feature every retail investor wants
- Short Squeeze Radar — same psychology
- Gold + Midnight themes (identity signal, "I have Pro")
- Unlimited price alert thresholds (currently capped implicitly)
- Full leaderboard + Friends comparison without anonymization
- Export portfolio (CSV, PDF) — power user need
- Advanced chart ranges (custom date ranges, not just 1mo/1yr)

**The key design principle:** Never put a lock on something the user is already doing. Lock only the *next* thing they want to do. The moment a user thinks "I want to see where the big money is flowing" — that's when Whale Alerts shows the lock. Not before.

---

## 3. The Ideal Paywall Trigger Moment

**Most apps get this completely wrong.** They show the paywall on app launch, after a time delay, or when the user taps a navigation item. These all feel like ads, not features.

The ideal paywall trigger is an **emotional moment tied to the user's specific portfolio**.

### The Trigger Architecture (Hook Model)

**External trigger:** Push notification — "NVDA up 4.1% today — your position gained $340"
**Internal trigger:** User opens app with anticipation/anxiety about their portfolio
**Action:** They check portfolio, see gains, feel good
**Variable reward:** See that a "whale" bought $2M of the same stock they hold
**Investment:** They want to understand if they should buy more

At the moment they tap "Whale Alerts" on a stock they already own — **that is the paywall moment.**

The lock icon on Whale Alerts should not just show a paywall. It should say: *"A whale just moved $2M in [THEIR STOCK]. Unlock to see the full trade."* That is a personalized, emotionally charged, FOMO-driven trigger. Open rate and conversion rate will be 3-5x higher than a generic paywall.

### Specific trigger moments ranked by conversion power:

1. **"A whale moved in [ticker you own]" locked card** — highest conversion, most personalized
2. **3rd AI message used** — "1 question left" creates artificial scarcity mid-conversation
3. **Short Squeeze Radar on a stock the user holds** — fear of missing a short squeeze on something they own
4. **After first positive day (portfolio +$X)** — user is in a good mood, most likely to pay
5. **Onboarding Screen 5** — weakest moment but captures early excitement

Never trigger the paywall on first open, after X days, or at arbitrary time intervals. Always tie it to a real portfolio event.

---

## 4. Competitor Analysis — Copy vs Avoid

### Robinhood
**What they do:** Primarily brokerage (order flow revenue, Robinhood Gold subscription). Gold is $5/mo and unlocks margin, bigger instant deposits, better interest rates, and research.
**Copy:** The "Gold" naming and status feel. Robinhood users feel elite with Gold. STALK Pro should carry the same social weight — a badge, a theme, a vibe.
**Avoid:** Their main revenue model (PFOF) is not available to STALK. Don't try to be a brokerage. Also avoid their notoriously confusing options interface — STALK is for portfolio tracking, not trading.

### Public
**What they do:** Subscription tiers (Public Premium at $10/mo) unlocking deeper analytics, AI-powered insights, extended hours data. They killed PFOF deliberately as a brand move.
**Copy:** Their AI insights positioning — "AI explains what's happening in your portfolio" is a premium hook that maps directly to STALK's AI chat gate. Public proved users will pay for AI that explains their specific holdings.
**Avoid:** Their social-first approach has diluted their product focus. STALK's social features should stay supplementary, not the hero.

### Webull
**What they do:** Commission-free brokerage, revenue from margin lending and premium data subscriptions ($1.99-$7.99/mo for Level 2 data).
**Copy:** Level 2 data and options flow as a premium tier — this maps to STALK's Whale Alerts concept. Power users demonstrably pay for raw data access.
**Avoid:** Their UI is overwhelming. STALK's competitive advantage is clarity and emotional design. Webull's complexity is a ceiling, not a floor.

### Yahoo Finance
**What they do:** Yahoo Finance Plus at $34.99/mo or $349/yr (!) — advanced charting, premium data, earnings estimates. Heavy on desktop. Ad-supported free tier.
**Copy:** The "Plus" tier positioning — they successfully sell research and data access at premium price points to serious investors. STALK can charge less than $35/mo and feel like more value.
**Avoid:** Ad-supported free experience. Their homepage is an ad delivery vehicle. STALK should be a clean, ad-free product at every tier — it signals quality.

### TradingView
**What they do:** Most sophisticated freemium in the space. Free tier is genuinely powerful. Pro ($14.95/mo), Pro+ ($29.95/mo), Premium ($59.95/mo). They gate number of indicators, chart layouts, and alerts. Subscription revenue is their primary model.
**Copy:** Their free tier generosity — TradingView free is legitimately useful. This is why their conversion is high. Users who get value for months convert. This validates STALK's approach of making free genuinely good.
**Copy:** Alert limits as a pro feature. TradingView caps alerts per tier. STALK can do the same with price alert thresholds.
**Avoid:** Overwhelming complexity for casual users. TradingView is for active traders. STALK is for investors who want to understand their portfolio, not build trading systems.

---

## 5. The One Insight That Overrides Everything

**Conversion happens after habit formation, not before.**

The single biggest mistake in fintech freemium apps is trying to convert before the user has experienced the core value loop 5+ times. Most apps gate too early (session 1-2). The optimal conversion window for a finance app is **day 7-14**, after the user has seen their portfolio move on at least 5 separate days and checked the app both when they were up and when they were down.

Build the habit first. Convert the habit second. That's the STALK product strategy.
