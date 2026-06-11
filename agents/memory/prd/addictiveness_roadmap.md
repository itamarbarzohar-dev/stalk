# Sam (CPO) — Addictiveness Audit & PRD

**Date:** 2026-06-09
**Author:** Sam, CPO

---

## The Hook Model Applied to STALK

The Hook Model (Nir Eyal) has four stages: Trigger → Action → Variable Reward → Investment. Every feature we build should consciously serve one or more of these stages. Below is the full audit.

---

## Feature → Hook Model Mapping

### Trigger (what pulls the user back)

Triggers are either external (notifications, badges) or internal (habit, emotion, boredom). STALK's best trigger real estate is the lock screen and the home screen badge.

| Feature | Trigger Type | Trigger Mechanism |
|---|---|---|
| Personalized Morning Push | External | "NVDA is up 4.2% — your $3,200 gained $134" fires at 8:30 AM |
| Price Alert Notification | External | User-set threshold crossed fires a push |
| Earnings Tonight Alert | External | "AAPL reports in 3 hours" fires at market open on earnings day |
| Market Open Summary | External | 9:30 AM push: "Market opens up. Your portfolio is +$240" |
| Market Close Summary | External | 4:00 PM push: "Day recap ready. You finished +$87" |
| App Icon Badge | External | Live P&L badge on home screen creates passive pull |
| Social Sentiment Spike | External | "Reddit is talking about your stock" push fires on volume anomaly |

**Assessment:** STALK currently has no notification infrastructure shipping at launch. This is the single highest-risk gap for retention. Without external triggers, we rely entirely on internal triggers (habit), which takes 6–8 weeks of repeated use to form. External triggers must ship at v1.

---

### Action (minimum viable tap to get value)

The action must be frictionless. One tap from notification to value. If the user has to navigate more than one screen to see why they were notified, we lose them.

| Feature | Action Quality | Notes |
|---|---|---|
| Personalized Morning Push | Excellent — deep link to portfolio summary | User taps → lands on daily brief card showing exact position change |
| Price Alert | Good — deep links to stock detail | Must land on the correct ticker, not the home screen |
| Sector Heat Map | Poor as a trigger entry point | Good as in-app discovery, not as a notification-driven action |
| AI Market Context Card | Good — one-screen value | "Why is the market moving?" answered in 3 sentences above the fold |
| Portfolio Health Score | Good — single number with drill-down | Score visible on home screen without tapping |
| Trending Tickers | Medium | Requires active exploration; not a notification action |

**Assessment:** Deep linking from every notification type to the exact relevant in-app screen is non-negotiable. Generic "open app" pushes have 40% lower tap-through rates than deep-linked ones.

---

### Variable Reward (the dopamine mechanism)

This is the most psychologically powerful stage. Markets are naturally variable. We must surface that variability in ways that feel rewarding even when the outcome is negative (loss aversion creates engagement too).

| Feature | Reward Type | Variable? | Intensity |
|---|---|---|---|
| Portfolio P&L (live) | Financial outcome | Yes — changes every second | Very high |
| AI Market Context Card | Information reward | Yes — always different | High |
| Options Flow / Whale Alerts | Social proof + insider-feeling | Yes — unpredictable | Very high |
| Earnings Calendar + AI Prediction | Anticipation + resolution | Yes — pre/post earnings tension | High |
| Analyst Ratings Changes | Authority signal | Yes — surprise upgrades/downgrades | High |
| Sector Heat Map | Pattern recognition | Moderate — slow-moving | Medium |
| Social Sentiment Tracking | Social validation | Yes — spikes are unpredictable | High |
| "What If" Scenario Modeling | Intellectual curiosity | No — deterministic output | Low (but sticky) |
| Portfolio Health Score | Self-assessment | Moderate — changes with market | Medium |

**Assessment:** Options Flow and Earnings are the two highest-variable-reward features we can add. Both create the "slot machine" dynamic — the user doesn't know what they'll find. These should be surfaced prominently as discovery features, not buried in menus.

---

### Investment (making the app more valuable over time)

Investment features make switching costly. The more a user puts into STALK, the less they want to leave.

| Feature | Investment Type | Switching Cost Created |
|---|---|---|
| Adding stocks to portfolio | Data investment | High — rebuild portfolio elsewhere = effort |
| Setting price alerts | Configuration investment | Medium — alerts are STALK-specific |
| Portfolio Health Score over time | Historical data investment | High — loses history if they leave |
| Watchlist curation | Preference investment | Medium |
| AI personalization (learns preferences) | Behavioral investment | Very high — AI gets better the longer they use it |
| Earnings notes / trade journal | Content investment | Very high — irreplaceable personal data |

**Assessment:** We have no trade journal or notes feature planned. This is a significant gap. A simple "add a note to this trade" feature dramatically increases switching cost and daily check-in frequency (users return to update their notes).

---

## Priority Matrix

| Feature | Retention Impact | Build Effort | Priority |
|---|---|---|---|
| Personalized Morning Push | Very High | Medium | P0 |
| Deep-linked notifications | Very High | Low | P0 |
| Earnings Calendar + Alert | High | Medium | P1 |
| AI Market Context Card | High | High | P1 |
| Options Flow / Whale Alerts | Very High | High | P1 |
| Portfolio Health Score (historical) | High | Medium | P1 |
| Market Open/Close Summaries | High | Low | P1 |
| Trade Journal / Notes | High | Low | P2 |
| Sector Heat Map | Medium | Medium | P2 |
| Social Sentiment | Medium | High | P3 |

---

---

# PRD: Personalized Morning Market Push

**Status:** Draft
**Priority:** P0 for retention
**Hook Model Stage:** Trigger (external)
**Owner:** Sam (CPO)
**Last Updated:** 2026-06-09

---

## Problem

New users open STALK once, add their portfolio, and do not return the next morning. They have no internal trigger (habit) yet, and STALK sends no external trigger. Without a daily pull, 60–70% of users churn in the first week before the habit forms.

Generic "market is up today" notifications exist everywhere — Bloomberg, CNBC, Yahoo Finance all send them. Users ignore them because they are not personalized to their money. What users actually care about is not "the market" — it is "my $3,200 in NVDA."

---

## Solution

A single, personalized push notification delivered at 8:30 AM market-days only (Mon–Fri, excluding market holidays). The notification is generated per-user, references their actual portfolio holdings and actual dollar amounts, and answers the one question every investor asks every morning: "What happened to my money overnight, and what should I know before the market opens?"

The notification is composed of:

1. **The headline** — the single most relevant move in the user's portfolio, in dollars, not percent alone. "NVDA is up 4.2% pre-market — your $3,200 position gained $134 since yesterday's close."

2. **The context line** — one sentence explaining why, sourced from AI market analysis. "Nvidia beat earnings estimates after hours; analysts upgraded price targets."

3. **The call to action** — implicit. The user taps to see their full portfolio brief for the day.

The notification deep links to the Daily Brief screen (already in PRD: top_retention_feature.md), which expands this into a full morning summary.

---

## User Stories

**US-1: Morning wake-up trigger**
As a user who added NVDA to my portfolio, when I wake up and pick up my phone, I want to see a lock-screen notification that tells me exactly what my NVDA position did overnight, so that I feel informed before the market opens without having to open any app.

**US-2: Personalized to my holdings**
As a user with 6 stocks in my portfolio, I want the notification to surface the single most significant mover in my portfolio (not just "the market"), so that the notification always feels relevant to me specifically.

**US-3: Dollar-value framing**
As a user, I want to see my gain or loss in dollars — not just percentage — because percentages require mental math and dollars feel real.

**US-4: One-tap to full context**
As a user who tapped the notification, I want to land on a screen that expands the summary into my full portfolio status, today's key events (earnings, economic data), and the AI market context card, so that my morning research is done in one place.

**US-5: Control over timing**
As a user, I want to be able to change the notification time (default 8:30 AM, options from 7:00 AM to 9:15 AM) so that the notification fits my morning routine, not the other way around.

**US-6: Market holiday awareness**
As a user, I do not want to receive a morning brief on weekends or market holidays, because it would feel broken and erode trust in the product.

---

## Success Metrics

**Primary:**
- D7 retention of users who receive at least one personalized push: target 45% (vs. estimated 20% baseline with no push)
- Push notification tap-through rate: target >30% (industry average for finance apps is 8–12%; personalized finance should be 2.5–3x higher)

**Secondary:**
- Session length after push tap: target >90 seconds (validates that the Daily Brief screen delivers enough value to hold attention)
- Push opt-in rate at onboarding: target >70% (if framing is "we'll tell you when your stocks move," not "allow notifications")
- D30 retention of push-receiving cohort vs. non-push cohort: target 2x lift

**Guardrails:**
- Push opt-out rate after first week: must stay below 15% (if too high, notification is perceived as spam, not value)
- If tap-through falls below 20%, content quality or personalization is failing — trigger content audit

---

## Technical Requirements

**Data pipeline:**
- Pre-market price data feed required by 8:00 AM ET (30 minutes before send window). Must cover extended hours / overnight moves, not just prior close.
- User portfolio data must be accessible server-side at notification generation time. Currently portfolio data may be local-only — this requires a backend sync layer.
- Market holiday calendar must be maintained (or consumed from a financial data API).

**Notification generation:**
- One notification payload generated per active user with a portfolio containing at least 1 stock.
- Logic: find the portfolio holding with the largest absolute pre-market dollar change. Use that as the headline stock.
- Dollar gain/loss: calculate as (pre-market price - prior close) × user's share count (or dollar value / prior close price × share count if only dollar value is stored).
- AI context line: query market context API for the headline stock to get a one-sentence explanation of the move. Cache responses by ticker for 15 minutes to reduce API cost.
- Fallback: if pre-market data unavailable for a stock, use prior day's close change. If portfolio is all flat, send a market-level summary ("S&P 500 futures are up 0.3% ahead of today's open").

**Notification delivery:**
- APNs (Apple Push Notification Service) integration required.
- Respect system-level notification permissions — prompt for permission during onboarding with explicit value framing.
- Time-zone aware delivery: 8:30 AM in the user's local time zone, not server time.
- User-configurable send time stored in user preferences.
- Delivery window: Mon–Fri only, skip federal market holidays.

**Deep link:**
- Notification taps must deep link to Daily Brief screen with the current date's brief pre-loaded.
- If Daily Brief is not yet generated (data not ready), show a loading state rather than an empty screen.

**Privacy:**
- Notification payload must not contain sensitive financial data in the notification body if device is shared or MDM-managed. Current iOS behavior shows notification content on lock screen — this is expected and acceptable for a finance app; document in privacy policy.
- No notification content should be stored or logged server-side beyond delivery confirmation.

---

## Paywall? Free or Pro?

**Decision: Free, always.**

Rationale: The personalized morning push is the primary retention mechanism for the entire product. Paywalling it would mean free users churn before they experience the core value of STALK, which eliminates conversion opportunity entirely.

The push notification is the hook, not the product. The product (AI analysis, earnings detail, options flow) is what sits behind it and justifies Pro. Removing the hook from free users kills the funnel.

The correct model: the morning push is free and personalized, but the in-app experience it deep-links into has Pro-gated depth. The notification fires for free users. When they tap in and want to read the AI analysis behind why NVDA moved, that's the Pro conversion moment.

---

## Open Questions

1. Do we store user portfolio data server-side at v1, or is a v1.5 backend sync required before this feature can ship? (Blocks this PRD entirely if portfolios are local-only.)
2. What pre-market data provider are we using? Does it cover extended hours moves before 8 AM ET?
3. What is the AI context line data source — do we call an LLM with market news context, or use a structured financial data API with pre-generated summaries?
4. What is the onboarding notification permission prompt copy? This significantly affects opt-in rate and must be tested.
