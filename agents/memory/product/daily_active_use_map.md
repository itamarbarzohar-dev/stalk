# Daily Active Use Map — STALK Ideal User Day

**Date:** 2026-06-09
**Authors:** Sam (CPO) + Rex (CRO)

This document maps the ideal daily interaction a STALK user has with the product. It is the source of truth for notification strategy, in-app content cadence, and feature prioritization. Every feature we build should fit somewhere on this timeline or it should not be built.

---

## The Ideal Day

### 7:30 AM — Morning Pull (Lock Screen)

**What fires:** Personalized Morning Push notification. Not a generic "market is up" — a single sentence tied to the user's largest overnight mover.

*Example: "NVDA pre-market +4.1% — your position is up $134 before the open."*

**User action:** Sees notification on lock screen. May not tap. The value is delivered on the lock screen itself. This is intentional — we want to be the first financial signal they see in the morning, even without an open.

**If they tap:** Deep links to Daily Brief screen. The user lands on a single-scroll view showing:
- Today's pre-market portfolio P&L
- Top mover with AI context ("Why is NVDA up? Earnings beat + analyst upgrades after close")
- Earnings events for stocks they hold in the next 7 days
- Key economic events today (Fed speak, CPI, etc.)

**Time spent:** 2–4 minutes. This is a reading session, not an action session. Goal is informed, not activated.

**Sam's note:** This session defines STALK's brand. If this is good every morning, we become the thing people check before they check Twitter. That's the habit we are building. If the content is stale or generic even once, the habit breaks.

**Rex's note:** This session is the top of the conversion funnel. Users who engage with the Daily Brief 3+ times in their first week convert to Pro at 4x the rate of users who don't. Free tier must be genuinely good here.

---

### 9:30 AM — Market Open (Active Trigger)

**What fires:** Market Open notification. Fires only on weekdays when the user has a portfolio. Brief, urgent.

*Example: "Market open. Your portfolio is starting the day at +$287. NVDA leading."*

**User action:** Most users will not open the app at 9:30 AM — they're commuting, in meetings, starting work. The notification serves as a passive context anchor. They know where they stand.

**If they tap:** Deep links to live portfolio screen with real-time prices streaming. The screen shows:
- Live P&L for today (updating in real-time)
- Each holding's day change in dollars and percent
- Sector heat map (which sectors are leading at open)
- Any analyst actions or news headlines that dropped overnight for held stocks

**Time spent if opened:** 3–5 minutes. Users who open at market open are the most engaged segment — they are active investors, not passive holders. These are the users who will pay for Pro.

**Sam's note:** The market open screen is the highest-engagement content window of the day. This is when the AI Market Context Card should be freshest and most prominent. If we have options flow (Pro), unusual pre-open activity should surface here.

**Rex's note:** This is the highest-converting paywall moment for the Options Flow feature. If a held stock has unusual pre-market options activity, surface the teaser here: "Unusual options activity detected on NVDA this morning." The urgency of market open makes this feel time-sensitive.

---

### 12:00 PM — Lunch Passive Check (In-App Browse)

**What fires:** No push notification for lunch. We do not send a midday push — it trains users to expect too many notifications and increases opt-out rate.

**What brings users back:** Internal trigger. The user thinks about their portfolio during lunch. They open the app out of curiosity / habit. This is the session we are trying to build toward through the morning push habit. It takes 2–4 weeks of consistent morning engagement to generate reliable midday organic opens.

**What they see when they open:**
- Live portfolio P&L (updating in real-time — this is the core)
- Mid-day market context card refreshed since morning: "Markets gave back gains mid-morning on rate concerns. S&P 500 is now flat."
- Trending tickers: what stocks are moving most today and why
- If any held stock has a news headline from the last 3 hours, surface it above the fold with the AI summary

**Time spent:** 1–3 minutes. This is a passive scan, not research. Design should reward a quick glance — key numbers visible in under 3 seconds.

**Sam's note:** The lunch session is the design test for the home screen. If a user has to hunt for their portfolio value, we've failed. The number should be the largest thing on the screen. Everything below it is context for that number.

**Rex's note:** Trending tickers is the discovery mechanism for watchlist growth at lunch. Users browsing trending tickers add stocks to their watchlist, which increases their investment in STALK and reduces churn. This is a retention mechanic disguised as content.

---

### 3:45 PM — Pre-Close Alert (High Intent Window)

**What fires:** Conditional push, not daily. Fires only if one of the following is true:
1. A stock in the user's portfolio has moved more than 3% today
2. A stock in the user's portfolio has earnings after-hours today
3. The user's total portfolio is up or down more than 1.5% on the day

*Example: "AAPL reports earnings in 15 minutes. Your $2,100 position could move significantly."*

**User action:** High-intent open. The user who opens at 3:45 PM is engaged and emotionally activated. They care about what happens at close.

**What they see:**
- Pre-close portfolio snapshot: where they'll finish if prices hold
- Earnings countdown for any after-hours reports on held stocks (with AI prediction if Pro)
- Option to set a price alert for a specific stock before close (one-tap)
- "What if" preview: "If AAPL misses estimates and drops 5%, your portfolio closes at -$347 today"

**Time spent:** 3–6 minutes. This is an anxiety + anticipation session. Design should be calm and informative, not alarming. Show the math clearly.

**Sam's note:** The 3:45 PM session is the single highest-engagement window for the Earnings Calendar feature. This is where we show the AI earnings prediction (Pro gate) and the historical reaction data. Users who open here are in a decision-making frame — should I hold through earnings? Should I trim? The AI analysis answers that question.

**Rex's note:** The "What If" scenario preview is a Pro conversion trigger here. Free users see one scenario. Pro users can run custom scenarios ("What if AAPL beats by 5%?"). The conversion prompt: "Model any earnings scenario — Pro."

---

### 4:15 PM — Market Close Summary (Closing the Loop)

**What fires:** Daily close push. This one fires every trading day, no conditions.

*Example: "Markets closed. Your portfolio finished at +$213 today. Strong day."*

The close push completes the narrative loop that opened at 7:30 AM. The user who got the morning push and saw they were up $134 pre-market now sees they closed up $213. The story has a resolution. This is the "variable reward delivery" moment in the Hook Model — the outcome of the day's market action is revealed.

**User action:** Many users will not open the app. The notification itself delivers the resolution. This is by design. Not every session needs to be an app open. The goal of the close push is:
1. Deliver the reward (or loss) to the user in a single line
2. Create a trigger for the evening session if there's unresolved narrative ("AAPL report tonight")
3. Reinforce the habit: STALK tells you how your day ended, every day

**If they tap:** Deep links to Day Summary screen:
- Final P&L for the day, with sparkline of intraday movement
- Top gainer and top loser in portfolio
- AI summary of what drove today's moves
- Preview of tomorrow: earnings before market open, economic events
- "Your portfolio health score is unchanged at 74" (or flagged if it moved)

**Time spent if opened:** 2–5 minutes. Reflective session. Not action-oriented.

**Sam's note:** The close push is the most deletable notification we send if it becomes routine and boring. The copy must vary. "Strong day." "Rough session — here's what happened." "Flat day, but watch for MSFT earnings tonight." The tone must feel like a message from a person who knows your portfolio, not a bot.

**Rex's note:** The Day Summary screen is where the Portfolio Health Score change surfaces most naturally. If the score dropped today because volatility spiked or sector concentration increased, the close session is when users are most receptive to understanding it — and most likely to upgrade to see the breakdown.

---

### 7:00 PM — Evening Re-Engagement (Earnings + Research)

**What fires:** Conditional push, high value. Fires only if:
1. A held stock reports earnings after-hours tonight (fires at 4:05 PM actually, right after close)
2. A watched stock (not held) reports tonight and user has shown interest in it
3. Unusual options activity was detected during the day on a held stock (Pro users only)

*Example: "NVDA is reporting now. Early estimates show EPS beat. Your position: $3,200."*

**User action:** This is the highest-engagement notification type in the product. Earnings are the Super Bowl of stock ownership. Users who hold a stock through earnings check the results compulsively.

**What they see:**
- Live earnings results as they're reported (EPS actual vs. estimate, revenue actual vs. estimate)
- After-hours price movement in real-time
- AI earnings summary: "NVDA beat EPS by 8%, guided higher on data center demand. Stock is up 6.2% after hours."
- Portfolio impact: "Your position is currently worth $3,397 after hours — up $197 from today's close"
- Historical context: "This is NVDA's 5th consecutive EPS beat"

**Time spent:** 10–20 minutes. This is the longest session type and the highest emotional engagement. Users will check the app multiple times during earnings night.

**Sam's note:** The earnings night experience is the feature that will generate word-of-mouth. "STALK showed me my exact dollar gain the moment NVDA beat earnings" is a story people tell. This experience must be flawless — real-time data, no lag, no errors. If we ship this badly, it will hurt us. If we ship it well, it will define us.

**Rex's note:** The evening earnings session is the highest-converting Pro upgrade window in the product calendar. A free user watching earnings in real-time, seeing "AI earnings analysis available with Pro" as a gate, while emotionally activated about their position, converts at rates we will not see in any other context. This is the moment to make the Pro ask.

---

## Summary: Notification Cadence

| Time | Trigger | Condition | Destination |
|---|---|---|---|
| 7:30–8:30 AM | Morning Brief (personalized) | Every market day | Daily Brief screen |
| 9:30 AM | Market Open | Every market day | Live portfolio screen |
| ~3:45 PM | Pre-Close Alert | Conditional (big mover or earnings tonight) | Pre-close summary |
| ~4:15 PM | Market Close Summary | Every market day | Day Summary screen |
| ~4:05 PM + evening | Earnings Alert | Only if user holds reporting stock | Live earnings screen |

**Maximum pushes per day:** 4 (morning + open + pre-close + close). On non-earnings days with no big movers: 3 (skip pre-close conditional). Never more than 4 pushes in a single day — beyond that, users opt out.

**Minimum pushes per day:** 2 (morning brief + close summary). These are the two non-negotiable notifications. If we send only these two every day, the habit forms.

---

## Anti-Patterns to Avoid

**Do not send notifications about stocks the user does not hold or watch.** "TSLA is up 8% today!" means nothing to a user who does not own TSLA. Generic market notifications are noise. They erode the trust that personalized notifications build.

**Do not send notifications on weekends or market holidays.** Even if you have something to say (M&A news on Saturday), a market-hours-only cadence sets expectations correctly and protects the morning brief habit from being associated with off-hours noise.

**Do not send more than 4 pushes in a day.** Every unnecessary push is a vote toward "Mute this app." The value of each notification is inversely proportional to how many we send.

**Do not repeat the same P&L number across multiple notifications.** If the morning brief said +$134 and the close summary says +$213, that's fine — it's a narrative arc. If the morning brief and the market open notification both say +$134, it feels like a copy-paste error and destroys trust in the data freshness.
