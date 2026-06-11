# STALK — Prioritized Feature Backlog
> Maintained by: CEO Alex
> Last updated: 2026-06-09 (Session 2)
> Purpose: Single source of truth for what gets built, in what order, and why.

---

## Prioritization Framework

- **P0** — Must have for launch. App is embarrassing or broken without this.
- **P1** — High-leverage addictiveness driver. Brings users back daily.
- **P2** — Nice to have. Deepens engagement but not blocking.

- **S** — Small (1–2 days), **M** — Medium (3–5 days), **L** — Large (1–2 weeks), **XL** — Very large (2+ weeks)

---

## P0 — Launch Blockers / Core App

| # | Feature | Why It Matters | Effort | Status |
|---|---------|---------------|--------|--------|
| 1 | Portfolio tracking (add/remove stocks, track cost basis) | Core utility — no app without this | M | ✅ Done |
| 2 | Live price quotes | Without live prices, STALK is a spreadsheet | M | ✅ Done |
| 3 | Daily Brief | "What happened while I slept" — drives morning opens | M | ✅ Done |
| 4 | For You tab | Personalized feed — the algorithmic hook | M | ✅ Done |
| 5 | Market view (indices overview) | SPY, NDX, BTC at a glance — users check this 5x/day | S | ✅ Done |
| 6 | FOMO features (ATH tracker, streak) | Makes gains feel celebratory and losses feel urgent | M | ✅ Done |
| 7 | Onboarding flow | Users who don't understand the app in 60s leave forever | M | ✅ Done |
| 8 | Freemium paywall (StoreKit) | Can't monetize without it | M | ✅ Done |
| 9 | Push notifications (local) | Re-engagement engine — without it app dies in 3 days | M | ✅ Done |
| 10 | Dark mode | iOS users expect it. Broken UI = uninstall | S | ✅ Done |
| 11 | BYOK Claude AI (Keychain) | AI differentiation — mocked AI kills credibility | M | ✅ Done |
| 12 | Price alert UI | Users set thresholds, get notified — key retention hook | M | ✅ Done |

---

## P1 — Addictiveness & Perplexity Finance Parity

| # | Feature | Why It's Addictive | Effort | Status |
|---|---------|-------------------|--------|--------|
| 13 | **Sector Heat Map** | Visual daily ritual — "what's hot, what's not" in one glance. Color = emotion = engagement. | M | 🔨 In Progress |
| 14 | **Portfolio Health Score** | Gamified 0-100 score based on diversification, volatility, P&L. Users obsess over improving it. Creates a game loop. | M | 🔨 In Progress |
| 15 | **AI Market Context card** | AI explains what's moving the market today and how it affects YOUR portfolio specifically. Hyper-personalized = sticky. | M | 🔨 In Progress |
| 16 | **Earnings Calendar** | "AAPL reports in 3 days" — urgency + anticipation drives daily opens all week. | M | 🔨 In Progress |
| 17 | **Trending Tickers feed** | What are other investors watching? Social proof + FOMO combo. | M | 🔨 In Progress |
| 18 | **News feed per stock** | Top 3 news articles per holding. Users read, form opinions, come back to trade. | M | Planned |
| 19 | **Price target & analyst ratings** | "Goldman upgraded NVDA to $1,200" — drives action and daily checks. | M | Planned |
| 20 | **52-week high/low indicator** | Users love knowing where they stand vs. the year range. Quick visual dopamine. | S | Planned |
| 21 | **Gain/Loss visualization (chart)** | Portfolio performance chart over time (1D, 1W, 1M, 1Y). Core emotional feedback loop. | L | Planned |
| 22 | **Individual stock chart** | Tap a holding → see its price chart. Expected by every user. | L | Planned |
| 23 | **Watchlist** | Track stocks you don't own yet. Creates aspiration and eventual buy intent. | S | Planned |
| 24 | **Pre/Post-market prices** | Power users check futures before market open and after-hours earnings. Daily ritual. | S | Planned |
| 25 | **Economic calendar (macro events)** | Fed meetings, CPI, jobs report — macro-aware users check STALK before any news drops. | M | Planned |
| 26 | **AI portfolio analysis (deep dive)** | "Alex, why is my portfolio underperforming?" — triggers emotional investment in AI. | M | Planned |
| 27 | **Custom alerts (price % move, volume spike)** | "Alert me if TSLA drops 5% in a day" — proactive feature that makes STALK a safety net. | M | Planned |
| 28 | **Widget (home screen)** | Portfolio P&L visible without opening app = passive engagement + open trigger. | M | Planned |

---

## P2 — Depth, Social, and Monetization Levers

| # | Feature | Why It Matters | Effort | Status |
|---|---------|---------------|--------|--------|
| 29 | **Broker affiliate integration** | Core business model lever — "Open account on Robinhood/IBKR" CTA with referral link. | L | Planned |
| 30 | **Import portfolio from broker** | Reduces friction to onboard real portfolios. Plaid / CSV / manual. | XL | Planned |
| 31 | **Social feed (real users)** | See what other investors are buying/selling. Network effects = moat. | XL | Planned |
| 32 | **Follow other investors** | Creator economy for investing. STALK becomes a social graph. | XL | Planned |
| 33 | **AI-powered trade ideas** | "Based on your portfolio, here's what to watch this week." Subscription driver. | L | Planned |
| 34 | **Options flow / dark pool data** | Power user feature. Premium only. Drives Pro upgrades. | XL | Planned |
| 35 | **Short interest & borrow rate** | Institutional-quality data for retail users. Premium differentiator. | L | Planned |
| 36 | **Dividend tracker & calendar** | Passive income investors check this obsessively. "Your next dividend: $42 from SCHD in 8 days." | M | Planned |
| 37 | **Tax lot tracking (FIFO/LIFO)** | Serious investors need this. Reduces churn at tax season. | L | Planned |
| 38 | **iPad & macOS app** | Expands TAM. Power users run STALK on desktop alongside trading terminal. | L | Planned |
| 39 | **App icon (designed)** | Current placeholder is embarrassing. Needed for App Store credibility. | S | Planned |
| 40 | **App Store listing** | Cannot launch without it. Blocked on Apple Dev account. | S | Blocked |
| 41 | **Backend / user auth** | Needed for real social features, portfolio sync across devices. | XL | Planned |
| 42 | **Onboarding A/B testing** | Once we have users, conversion optimization. | M | Planned |
| 43 | **Referral program** | "Invite a friend, both get 1 month Pro free" — growth loop. | M | Planned |

---

## Addictiveness Design Principles (Why Users Come Back)

These are the psychological patterns STALK must exploit to create daily habit:

1. **Variable reward schedule** — Market moves are unpredictable. We surface them constantly (price alerts, trending, news) to trigger the check-reflex.
2. **Progress & score** — Portfolio Health Score + streaks give users a number to improve. Improvement requires opening the app.
3. **Loss aversion** — Price alerts, "your stock dropped 3%" notifications make NOT checking feel risky.
4. **Social proof** — Trending tickers + social feed make users feel like they're missing out on what "smart money" is doing.
5. **Anticipation loops** — Earnings calendar creates urgency across multiple days leading up to an event.
6. **Morning ritual anchoring** — Daily Brief at market open is designed to be the first thing users check, before news apps.
7. **AI as a companion** — Personalized AI commentary makes STALK feel like a partner, not a tool. Emotional attachment = retention.

---

## Perplexity Finance Feature Mapping

Features from Perplexity Finance that STALK should match or exceed:

| Perplexity Finance Feature | STALK Equivalent | Status |
|---------------------------|-----------------|--------|
| AI-generated market summary | Daily Brief + AI Market Context card | ✅ / 🔨 |
| Stock news aggregation | News feed per stock | Planned |
| Price charts | Individual stock chart | Planned |
| Analyst ratings & targets | Price target & analyst ratings | Planned |
| Trending stocks | Trending Tickers feed | 🔨 |
| Sector performance | Sector Heat Map | 🔨 |
| Earnings dates | Earnings Calendar | 🔨 |
| Economic events | Economic calendar (macro events) | Planned |
| Portfolio tracking | Portfolio tracking | ✅ |
| Watchlist | Watchlist | Planned |
| Pre/post-market data | Pre/Post-market prices | Planned |

**STALK's unfair advantages over Perplexity Finance:**
- Portfolio-aware AI (Perplexity doesn't know your holdings)
- Gamification (Health Score, streaks, FOMO cards)
- Mobile-first native iOS experience (Perplexity is web-first)
- Freemium business model designed for retention
- Broker affiliate monetization layer

---

_Next review: after Session 2 sprint delivers features #13-17._
