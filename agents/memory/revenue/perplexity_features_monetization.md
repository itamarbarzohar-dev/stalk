# Rex (CRO) — Perplexity Finance Features: Monetization Playbook

**Date:** 2026-06-09
**Author:** Rex, CRO

---

## The Competitive Situation

Perplexity Finance is free. It has an established brand in AI search, massive distribution through the Perplexity app, and zero marginal cost to add finance features to an existing subscription. STALK is a standalone app, pre-launch, no users, charging $6.99/mo.

This is a hard fight on price. The only way to win is not to compete on price but on context. Perplexity Finance knows what "the market" is doing. STALK knows what *your* portfolio is doing. That's the wedge. Everything below is built on that wedge.

---

## Feature-by-Feature Monetization Decision

### 1. Sector Heat Map

**Decision: Free (limited) / Pro (interactive)**

**Free tier:** Static sector performance snapshot. 11 sectors, color-coded by today's performance. Refreshes every 15 minutes. Read-only.

**Pro tier:** Interactive — tap a sector to see which of your portfolio holdings are in it, how much sector exposure you have, whether you're overweight or underweight vs. S&P 500 sector weights, and AI commentary on why the sector is moving today.

**Conversion trigger moment:** Free user taps the Technology sector on a day NVDA is up 4%. They see the sector is green. They want to know: "How much of my portfolio is in this sector? Am I overexposed?" That question is blocked by a Pro gate. The upgrade prompt is: "See your personal sector exposure — Pro."

**Revenue impact:** Medium. Sector heat map is a nice-to-have, not a daily trigger. It does not drive conversion independently but reinforces Pro value once a user is already considering upgrading. Do not count on this as a standalone conversion driver.

---

### 2. AI Market Context Card

**Decision: Free (1 per day) / Pro (unlimited, real-time)**

**Free tier:** One AI market context card per day, generated at 9:30 AM. Answers "Why is the market moving today?" in 3–4 sentences. Refreshes once daily.

**Pro tier:** Real-time context updates throughout the day, plus per-ticker AI context ("What's happening with NVDA specifically?"), plus portfolio-level AI synthesis ("Given what's happening in the market today, here's what it means for your portfolio").

**Conversion trigger moment:** Market goes volatile at 2 PM. Free user opens the app, sees the morning context card (stale), wants to know what's happening right now. The real-time update is blocked. Upgrade prompt: "Markets are moving fast. Get real-time AI context — Pro." Urgency is built in by market volatility itself — we don't have to manufacture it.

**Revenue impact:** High. This is a daily-use feature on volatile days, which are the days users are most emotionally engaged and most likely to make impulsive upgrade decisions. This is one of the top two conversion drivers in the product.

---

### 3. Portfolio Health Score

**Decision: Free (score only) / Pro (full breakdown + history)**

**Free tier:** A single number — your portfolio health score (0–100). Updated daily. No explanation of components.

**Pro tier:** Full breakdown of what drives the score: diversification grade, volatility risk, sector concentration, earnings risk exposure, correlation between holdings, and a 30-day history chart of score changes. Plus AI recommendations: "Your portfolio is 68% tech. Consider diversifying."

**Conversion trigger moment:** Free user sees their score dropped from 74 to 61 over the past week. They have no idea why. The breakdown is Pro-gated. Upgrade prompt: "Your score dropped 13 points. Find out why — Pro." Anxiety is the trigger. Users who see their score decline are highly motivated to understand it.

**Revenue impact:** High. This feature creates recurring upgrade intent — every score change that isn't explained is a micro-conversion opportunity. Over a 30-day period, most users will experience at least one score change that puzzles them. Stack this with a notification ("Your portfolio health score changed") and it becomes a significant conversion funnel.

---

### 4. Earnings Calendar

**Decision: Free (calendar view) / Pro (AI predictions + portfolio linkage)**

**Free tier:** Full earnings calendar — all earnings dates for stocks in your watchlist and portfolio. Date, time (pre/post market), EPS consensus estimate. This is a utility feature that many competing apps give away free, so we must match it.

**Pro tier:** AI earnings prediction ("Based on options pricing and analyst revision trends, AAPL has a higher-than-consensus probability of beating estimates"), historical earnings reaction data ("AAPL has beaten 7 of the last 8 quarters; average next-day move is +3.2%"), and portfolio impact modeling ("If AAPL beats and moves +3%, your portfolio gains $287").

**Conversion trigger moment:** The night before a major earnings report on a stock the user holds. They open the calendar, see AAPL reports tomorrow. They want to know: "Should I be worried? What's the market expecting?" The AI prediction and historical data are behind a Pro gate. Upgrade prompt fires at the highest possible emotional intensity — the night before earnings.

**Revenue impact:** Very high. Earnings events are the most emotionally charged moments in investing. Users are anxious, engaged, and checking their phones repeatedly. Conversion on earnings eve is the highest-intent upgrade moment in the entire app. This feature should be highlighted in onboarding and in any paywall screen.

---

### 5. Trending Tickers

**Decision: Free**

**Rationale:** Trending tickers is a discovery feature. It brings users into stocks they might add to their watchlist or portfolio. Every stock they add to their portfolio increases investment in STALK and reduces churn. Paywalling this would reduce portfolio depth, which hurts retention more than it helps revenue. Free. Always.

**Monetization angle:** Within trending ticker views, surface Pro features (AI context, options flow, analyst ratings) as Pro-gated modules. The trending feed is free; the depth behind each ticker is Pro.

**Revenue impact:** Indirect. This feature increases portfolio size and watchlist depth, both of which increase investment (Hook Model stage 4) and therefore reduce churn among Pro subscribers.

---

### 6. Analyst Ratings

**Decision: Free (current rating) / Pro (history + alerts)**

**Free tier:** Current consensus analyst rating (Buy/Hold/Sell) and average price target for stocks in portfolio and watchlist.

**Pro tier:** Full analyst rating history (see how ratings have changed over time), individual analyst ratings broken out by firm, price target change alerts ("Goldman Sachs raised NVDA target from $900 to $1,050"), and AI synthesis ("3 analysts upgraded this week after earnings beat; consensus target implies 18% upside").

**Conversion trigger moment:** User sees their stock has a "Buy" consensus with a price target 25% above current price. They want to know: "Which analysts said this? When did the target change? Is the upgrade recent or stale?" That depth is Pro-gated. The static rating creates curiosity; the history and firm-level breakdown satisfy it — behind a paywall.

**Revenue impact:** Medium. Analyst ratings upgrades/downgrades are high-frequency events that happen daily across the market. If we send a notification when a held stock gets an analyst action, and the detail is Pro-gated, this creates a reliable daily upgrade trigger for engaged free users.

---

### 7. Options Flow (Whale Alerts)

**Decision: Pro only**

**Free tier:** None. This feature should not appear in the free tier at all, or appear only as a teaser ("3 unusual options trades detected today — unlock with Pro").

**Pro tier:** Unusual options activity feed, filterable by user's portfolio holdings or any ticker. Includes trade size, strike, expiration, put/call, and a plain-English summary ("Someone bought $2.1M of NVDA calls expiring in 3 weeks — this is 4x the normal volume at this strike").

**Rationale for hard Pro gate:** Options flow is the single most powerful "insider-feeling" feature in the product. Users who trade or invest feel like they're seeing what the smart money is doing. This is the feature that converts sophisticated investors — exactly the users who are willing to pay $6.99/mo. Giving this away free would destroy the perceived value of the Pro tier.

**Conversion trigger moment:** The teaser card on the free tier shows "Unusual activity detected on a stock you hold" without detail. Tapping it hits the Pro gate. This is the highest-converting paywall moment in the product because it triggers both FOMO and the feeling of information asymmetry ("someone knows something about my stock and I don't").

**Revenue impact:** Very high as a conversion driver for the engaged/sophisticated segment. Will not resonate with casual investors who don't know what options flow is — but that's fine, because those users are converted by other features (Portfolio Health Score, Earnings Calendar).

---

### 8. Economic Calendar

**Decision: Free**

**Rationale:** The economic calendar (Fed meetings, CPI, jobs report, etc.) is widely available for free across Bloomberg, investing.com, and every major financial app. Paywalling it would make STALK feel cheap relative to competitors. Give it away free and let it drive daily opens.

**Monetization angle:** When a major economic event fires (Fed rate decision), surface an in-app notification: "Fed decision in 2 hours — see how rising rates affect your portfolio — Pro." The event is free; the portfolio-impact AI analysis is Pro.

**Revenue impact:** Indirect — drives engagement and creates upgrade moments during macro events.

---

## The "Why Pay $6.99/mo When Perplexity Finance Is Free?" Answer

This is the hardest question in STALK's go-to-market. Here is the only genuinely compelling answer — do not use the generic version ("we offer more features").

**The genuine answer:**

Perplexity Finance tells you what is happening in the market. STALK tells you what is happening to your money.

These are completely different products. Perplexity Finance is a research tool for reading about markets. STALK is a personal financial mirror — it reflects your specific situation, your holdings, your dollars gained and lost, your risk exposure, your earnings schedule, the whale activity on stocks you actually own.

When NVDA moves 4%, Perplexity Finance tells you why NVDA moved. STALK tells you that your $3,200 position gained $134, that your portfolio health score changed, that the earnings in 3 days have historically caused a +/-5% move, and that an analyst just raised their price target. Perplexity Finance gives you market journalism. STALK gives you a CFO for your personal portfolio.

**The $6.99/mo justification framed as a value calculation:**

If STALK helps you make even one better trade per year — or avoid one bad one — it pays for itself in the first week. For someone with a $5,000 portfolio, avoiding a 3% loss ($150) covers the entire annual subscription ($84) with $66 left over. This is not a "features" argument. It is a financial ROI argument, and it works because it is true.

**The "why not just use a free app" reframe:**

Free apps (Robinhood, Yahoo Finance, Perplexity Finance) make money by selling your attention to advertisers, or by routing your trades through market makers who profit on your order flow. STALK makes money directly from you. That alignment is the product. When STALK's revenue depends on you finding the app valuable enough to keep paying, every product decision is oriented toward making your portfolio management better — not toward maximizing the time you spend watching ads or the number of trades you make.

---

## Paywall Architecture Recommendation

Based on the above analysis, the correct paywall structure is:

**Free tier gives:** Portfolio tracking (unlimited stocks), live prices, basic portfolio P&L, earnings calendar dates, sector heat map (static), economic calendar, trending tickers, analyst consensus (current only), portfolio health score (number only), personalized morning push notification (this must be free — see CPO PRD).

**Pro tier ($6.99/mo or $59.99/yr) gives:** AI market context (real-time + per-ticker), portfolio health score breakdown + history, options flow / whale alerts, analyst rating history + firm breakdown + alerts, AI earnings predictions + portfolio impact modeling, sector exposure analysis vs. your portfolio, "what if" scenario modeling, interactive sector heat map with portfolio overlay.

**The conversion strategy:** Do not show a paywall wall. Show Pro feature modules inline on free screens with a single-tap upgrade prompt. The user should encounter 3–5 natural Pro gates per week of normal use. Each gate should fire at a moment of high intent (earnings approaching, score drops, unusual options activity on a held stock). The upgrade prompt should show the specific value they would have gotten if they were Pro at that moment — not a generic feature list.

**Example:** User holds NVDA. NVDA has unusual options activity today. Free tier shows: "Unusual options activity detected on NVDA — $1.8M in calls bought today. Unlock details with Pro." The prompt is specific, timely, and directly tied to a stock they care about. This converts 3–5x better than a generic "unlock all features" prompt.
