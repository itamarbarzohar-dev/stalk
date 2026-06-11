# STALK: Every Possible Revenue Stream
**Date:** 2026-06-09
**Author:** Rex (CRO)
**Audience:** Itamar (Founder)
**Purpose:** Exhaustive revenue strategy map — every stream we could ever pursue, scored and timed

---

## Context

This document goes beyond the 7 models in the business_model_analysis.md. Everything is on the table. Some streams are obvious, some are creative, some are speculative. The goal is to make sure no revenue opportunity goes unexamined, so Itamar can make deliberate choices rather than stumble into them.

Current state at time of writing: pre-launch, iOS-only, no backend, no broker integration, 0 MAU.

---

## Stream 1: Freemium Subscription (Core)
**Category:** Direct
**When to pursue:** Now
**Effort:** Low (already built)
**ARPU potential:** $58–71 per paying user per year (net of Apple cut)
**Apple cut:** Yes (IAP) — 30% year 1, 15% year 2+
**Risk:** Low
**What needs to be true first:** Apple Developer account enrollment, App Store Connect product IDs

The foundational revenue layer. STALK Pro at $6.99/mo or $49.99/yr unlocks Whale Alerts, AI Analysis, Short Squeeze Radar, unlimited price alerts, and premium themes. StoreKit 2 and the paywall UI are already fully built. The 7-day free trial lowers the activation barrier at the top of the funnel.

At 3% free-to-paid conversion and 6% monthly churn, 10,000 MAU yields ~$1,470/mo net MRR. This is the only model that generates revenue within weeks of App Store approval and requires zero additional engineering today.

**Real example:** Copilot Money — subscription-only personal finance app, ~$13/mo, reached profitability on under 100K users via word-of-mouth alone.

---

## Stream 2: Broker Affiliate / Referral CPA
**Category:** Partnership
**When to pursue:** Now
**Effort:** Low (deep link + one disclosure line)
**ARPU potential:** $100–200 per referred funded account (one-time, no Apple cut)
**Apple cut:** No (external referral link)
**Risk:** Low
**What needs to be true first:** Sign up for Interactive Brokers and/or Webull affiliate programs (1–3 days to approve)

STALK surfaces a referral CTA during onboarding ("Don't have a brokerage yet?") and in Settings. Users who open a funded account through the STALK affiliate link earn STALK $100–$200 per conversion. No engineering beyond a deep link. No Apple tax. Interactive Brokers pays $200/funded account; Webull pays $50–$75 plus share rewards.

This is not a primary revenue engine — it is a zero-cost supplement that can generate $500–$2,000/mo at 5,000–10,000 MAU if placement is thoughtful. The strategic bonus: users who open a brokerage through STALK are more committed to using the app long-term.

**Real example:** NerdWallet, Bankrate — both generate hundreds of millions per year from brokerage affiliate links embedded in editorial content.

---

## Stream 3: Premium Themes (One-Time IAP)
**Category:** Direct
**When to pursue:** Now
**Effort:** Low (partially built)
**ARPU potential:** $1.99–4.99 per purchase; estimated $3–8/yr per engaged user who buys themes
**Apple cut:** Yes (IAP) — 30%
**Risk:** Low
**What needs to be true first:** Theme packs designed and implemented; IAP product IDs configured

Cosmetic one-time purchases for users who want to personalize the STALK interface without committing to a subscription. The psychological hook: themes signal identity ("I'm a serious investor, my app reflects that"). Dark mode is free; curated seasonal or branded themes are $1.99–$4.99 each.

This is a low-ARPU stream but has near-zero churn (one-time purchase) and catches users who want to support the app without a recurring commitment. Think of it as an upgrade funnel gateway — theme buyers are 2–3x more likely to later convert to Pro subscription.

**Real example:** Fantastical (calendar app) — sold cosmetic themes as add-ons before switching to full subscription; generated meaningful revenue from users who rejected subscription pricing.

---

## Stream 4: Analyst Upgrade/Downgrade Alert Tier
**Category:** Direct
**When to pursue:** 3–6 months
**Effort:** Medium (requires analyst ratings data API)
**ARPU potential:** $15–25 incremental per Pro user per year if bundled; $2.99/mo as standalone add-on
**Apple cut:** Yes (IAP)
**Risk:** Medium
**What needs to be true first:** Reliable analyst ratings data feed (Benzinga, Refinitiv, or Alpha Vantage), backend to push notifications

Real-time alerts when an analyst at a major bank upgrades or downgrades a stock in the user's portfolio. "Goldman Sachs just upgraded NVDA from Neutral to Buy, price target raised to $850." This is the kind of information institutional investors get in real-time and retail investors pay for through platforms like Bloomberg Terminal.

Bundled into Pro, this is a strong paywall trigger for active traders who already hold positions. As a standalone add-on tier ($2.99/mo on top of Pro), it segments the power-trader user who wants institutional-grade signals. Data cost is approximately $50–$150/mo for a mid-tier API that covers major analyst ratings.

**Real example:** Seeking Alpha Premium — analyst ratings alerts are one of their most-cited reasons for upgrading to paid, generating $240/yr ARPU on their paying base.

---

## Stream 5: Earnings Whisper / Pre-Earnings AI Analysis
**Category:** Direct
**When to pursue:** 3–6 months
**Effort:** Medium (requires earnings data + AI inference pipeline)
**ARPU potential:** $18–30 incremental per Pro user per year; potential $3.99/mo standalone
**Apple cut:** Yes (IAP)
**Risk:** Medium
**What needs to be true first:** Earnings calendar data, options implied move data, historical earnings reaction database, backend for scheduled notifications

The night before an earnings report on a stock the user holds, STALK sends a push notification and in-app briefing: AI analysis of what the options market is pricing in, the stock's last 8 quarter beat/miss history, average post-earnings move, analyst consensus vs "whisper number," and a plain-English risk summary ("AAPL reports tomorrow. Options imply a ±4.2% move. It has beaten estimates 7 of the last 8 quarters. Your position size means a 4% drop costs you $340.").

This is the single highest emotional-intensity monetization moment in the entire app. Users are most anxious and most engaged the evening before an earnings report on a stock they hold. Conversion events triggered at peak emotional engagement consistently outperform baseline paywall conversion by 3–5x.

**Real example:** Earnings Whispers (earningswhispers.com) — sells earnings prediction data at $29.99/mo to active retail traders. EarningsEdge Pro sells similar data at $49/mo and has a profitable subscriber base of retail traders.

---

## Stream 6: Economic Calendar Pro Tier
**Category:** Direct
**When to pursue:** 3–6 months
**Effort:** Medium
**ARPU potential:** $10–15 incremental per Pro user per year
**Apple cut:** Yes (IAP)
**Risk:** Low
**What needs to be true first:** Macro data API (FRED, Quandl, or Trading Economics), push notification infrastructure

Personalized macro alerts timed to the user's portfolio. When the Fed publishes minutes, when CPI prints, when jobs report drops — STALK sends not just the data but the AI interpretation tied to the user's specific holdings. "CPI came in hot at 3.4%. Your portfolio is 40% in rate-sensitive financials. Here's what historically happens to your holdings in a high-CPI environment."

Differentiated from generic macro apps (Bloomberg, Investing.com) by the portfolio-linkage layer — the insight is always anchored to what the user actually owns. This is a retention feature as much as a monetization feature: users who receive personalized macro context open the app more often and churn less.

**Real example:** Trading Economics Pro ($75/mo) and ForexFactory (free but shows the model works) — macro data products consistently monetize active traders who understand macro-portfolio linkage.

---

## Stream 7: Custom Watchlist Alerts (Unlimited Real-Time)
**Category:** Direct
**When to pursue:** Now / 3 months
**Effort:** Low (already partially gated)
**ARPU potential:** Built into Pro subscription; strong paywall trigger
**Apple cut:** Yes (IAP)
**Risk:** Low
**What needs to be true first:** Push notification entitlements, rate limiting on free tier (5 alerts max)

Free users get 3–5 price alerts. Pro users get unlimited real-time alerts with sub-minute latency, percentage-based alerts ("alert me when TSLA moves more than 3% in a day"), and portfolio-level alerts ("alert me if my portfolio drops more than 2% intraday"). The scarcity mechanic on the free tier is the conversion trigger — users who hit the limit and have active positions are highly motivated to upgrade immediately.

This is a conversion optimization lever more than an independent revenue stream. It should be treated as one of the top three paywall gates alongside AI Analysis and Whale Alerts. The unlimited alerts message needs to be front-and-center in the Pro paywall screen.

**Real example:** TradingView — price alerts are their single most-cited reason for upgrading from free to Pro ($14.95/mo). Their conversion rate on users who hit the free alert limit is reportedly 8–12%.

---

## Stream 8: Portfolio Export / Tax Report
**Category:** Direct
**When to pursue:** 3–6 months (Q4 2026 — tax season timing matters)
**Effort:** Medium
**ARPU potential:** $4.99–9.99 one-time per user per tax year; OR bundled as Pro-only feature
**Apple cut:** Yes (if IAP) / No (if web-delivered PDF)
**Risk:** Low
**What needs to be true first:** Portfolio data persistence (backend or iCloud sync), cost basis tracking, realized gains/losses calculation engine

Tax season is the highest-intent monetization moment for any financial app. Users who have been tracking their portfolio in STALK all year want a clean export: realized gains/losses, cost basis per position, dividend income, and a CPA-ready PDF. TurboTax-compatible CSV format adds a direct integration hook.

Offered as a $4.99 one-time in-app purchase each tax season, or bundled as a Pro-exclusive feature (makes Pro feel essential in February–April). The tax angle also makes Pro subscription renewal sticky — users who generated tax reports with STALK won't want to lose their history by canceling.

**Real example:** Sharesight ($29.99–$79/yr) — portfolio tracking tool used primarily for tax reporting in Australia and the UK. Their highest retention rates correlate with users who have completed at least one annual tax report.

---

## Stream 9: Options Flow / Whale Alerts (Pro-Only)
**Category:** Direct
**When to pursue:** Now (already referenced in Pro features) / 3 months for real data
**Effort:** Medium (requires unusual options activity data feed)
**ARPU potential:** Core to Pro subscription value prop; estimated $20–30/yr of Pro ARPU attributable to this feature
**Apple cut:** Yes (IAP)
**Risk:** Medium (data cost is $50–200/mo for quality unusual options activity)
**What needs to be true first:** Options flow data API (Unusual Whales, Market Chameleon, or Barchart), display UI in app

Institutional-grade unusual options activity, filtered to stocks in the user's portfolio and watchlist. When a whale buys 10,000 OTM call contracts on a stock the user holds, STALK surfaces it: "Unusual options activity on TSLA: 10,000 Jan $300 calls bought for $2.1M. This is 8x average daily options volume. Historically, unusual call buying of this magnitude precedes a 15%+ move within 30 days in 62% of cases."

This is the most explicit "edge" STALK gives retail investors — the feeling that they have access to information that was previously reserved for institutional players. The narrative appeal is enormous. This is already referenced as a Pro feature in the StoreKit configuration; execution requires connecting a real data source.

**Real example:** Unusual Whales — subscription service at $50/mo purely for unusual options data. FlowAlgo charges $99/mo. The market exists and is willingly paying.

---

## Stream 10: Creator Monetization — Top Trader Tipping
**Category:** Platform
**When to pursue:** 6–12 months
**Effort:** High
**ARPU potential:** STALK takes 20% of creator revenue; at 100 creators earning avg $200/mo = $4,000/mo platform rake
**Apple cut:** Yes (IAP) — this goes through Apple's in-app tipping system, 30% cut on creator payments
**Risk:** High (regulatory, Apple policy, community management complexity)
**What needs to be true first:** Social features (feed, profiles, follower graph), creator leaderboard, 10,000+ MAU, legal review on whether tipping for investment content constitutes investment advice

Top performers on STALK's leaderboard — users with auditable long-term returns — can enable "supporter tipping." Their followers pay $2.99–$4.99/mo directly to the creator. STALK takes 20% of the revenue. The creator gets exposure and income; the follower gets to watch a successful portfolio in real-time; STALK gets a platform fee and a reason for high-engagement users to stay.

The platform rake model scales non-linearly: each new successful creator brings their audience, which brings new users, which creates new potential creators. The key risk is regulatory — depending on framing, "pay to follow a trader's portfolio" could be construed as investment advice, triggering SEC/FINRA requirements. Structure this as entertainment/community, not advisory.

**Real example:** eToro's CopyTrader (popular investors earn up to 2% AUM from copiers), StockTwits premium streams, Public.com's "Live" feature where traders host audio commentary.

---

## Stream 11: Sponsored Watchlists / Thematic Portfolios
**Category:** Partnership
**When to pursue:** 6–12 months
**Effort:** Medium
**ARPU potential:** $2,000–$10,000/mo per sponsoring brand at 50,000+ MAU
**Apple cut:** No (brand deal / direct invoice)
**Risk:** Medium (disclosure requirements, user trust risk)
**What needs to be true first:** 25,000+ MAU, dedicated "Discover" or "Explore" section in the app, media kit and rate card, legal review of disclosure requirements

Financial brands — ETF issuers (ARK, Invesco, iShares), research firms, sector-focused products — pay to have a curated "thematic portfolio" featured in STALK's discovery section. Examples: "ARK Innovation Portfolio — sponsored by ARK Invest," "Clean Energy 25 — sponsored by Invesco," "Dividend Aristocrats — sponsored by ProShares." Users can add these to their watchlist with one tap.

The value to sponsors is performance-based brand association: being in front of engaged retail investors at the moment they're making investment decisions. The value to users is pre-built portfolio templates from recognizable brands. The disclosure must be explicit — this is advertising, not a recommendation. At 50K MAU, this is a $5K–$15K/mo revenue stream that requires no Apple tax and very little engineering.

**Real example:** Yahoo Finance features "Trending ETFs" which are often paid placements. Robinhood's "Collections" have been monetized with brand sponsorships. Morning Brew's investment newsletter sells sponsored portfolio spotlight content at $10K–$50K/placement.

---

## Stream 12: Financial Advisor Lead Generation
**Category:** Partnership
**When to pursue:** 6–12 months
**Effort:** Medium
**ARPU potential:** $50–$200 per qualified lead; at 50K MAU with 0.2% conversion = 100 leads/mo = $5,000–$20,000/mo
**Apple cut:** No (external referral)
**Risk:** Low–Medium (regulatory considerations around "advisor matching" services)
**What needs to be true first:** 25,000+ MAU, partnership with a qualified RIA matching service (SmartAsset, Facet Wealth, Harness Wealth), user base with measurable portfolio sizes

Users who have grown their portfolio to $50K+ on STALK get a contextual prompt: "Your portfolio has grown to $68K. Some investors at this level work with a financial advisor. Want to talk to one?" STALK connects them to vetted RIAs through a matching service. STALK earns $50–$200 per qualified lead (user who completes an intro call and provides contact info).

The key insight is that the lead quality is extremely high — the RIA knows exactly what the user holds, how long they've been investing, and their approximate net worth (from portfolio data). This is dramatically better quality than a generic financial lead. The matching service pays a premium for this context. Average CPA for a high-quality HNW lead in financial services is $100–$500.

**Real example:** SmartAsset (advisor match platform) generates hundreds of millions in revenue from lead generation. NerdWallet's financial advisor matching generates $100–$500 per qualified lead from their personal finance audience.

---

## Stream 13: IPO / SPAC Alert Tier
**Category:** Direct
**When to pursue:** 6–12 months
**Effort:** Medium
**ARPU potential:** $3.99/mo add-on or bundled in a "Pro+" tier at $9.99/mo
**Apple cut:** Yes (IAP)
**Risk:** Medium
**What needs to be true first:** IPO data feed (IPOMonitor, Renaissance Capital API), user base with demonstrated interest in growth investing

Pre-IPO intelligence: upcoming IPOs with AI analysis of the company's financials, lock-up expiration calendars (when early investors can sell), SPAC merger targets, and direct listing alerts. For users who want exposure to IPOs before they become mainstream news, this is a paid early-warning system.

SPAC arbitrage in particular was a retail trader obsession from 2020–2023, and IPO tracking remains an evergreen interest for growth investors. As a standalone tier, this targets the subset of users who are actively hunting for early-stage equity exposure. The data cost is low ($0–50/mo from public SEC EDGAR filings), making margin high.

**Real example:** Renaissance Capital's IPO Intelligence sells at $299/mo per user to institutional investors. Retailer-focused IPO alerts (IPO Monitor) charges $9.99–$19.99/mo and has sustained paying subscribers since 2007.

---

## Stream 14: Portfolio Insurance / Hedging Suggestions
**Category:** Partnership + Direct
**When to pursue:** 6–12 months
**Effort:** Medium
**ARPU potential:** Affiliate: $20–50 per user who opens an options account; Direct: bundled in Pro or $4.99/mo add-on
**Apple cut:** No (affiliate) / Yes (IAP for the feature)
**Risk:** Medium–High (regulatory: recommending specific hedges may constitute investment advice)
**What needs to be true first:** Portfolio concentration analysis engine, options broker affiliate relationship (Tastytrade, Webull options), legal review on framing

When a user's portfolio is heavily concentrated (e.g., 60% in NVDA), STALK surfaces a risk alert and educational content: "Your portfolio is 60% NVDA. Here's how some investors hedge single-stock concentration: protective puts, collars, covered calls. Want to learn more?" The CTA links to a broker affiliate (Tastytrade, which pays $50–$150 per funded options account).

The affiliate angle is the near-term revenue path. The long-term play is building this into a paid "Portfolio Risk Manager" tier that actively monitors concentration risk, beta exposure, and max drawdown, sending monthly hedging opportunity briefings. Legal framing must be "educational" not "advisory" — the same line fintech apps like Magnifi and Titan walk carefully.

**Real example:** Tastytrade has one of the most generous affiliate programs in options ($50 per funded account, $100 for funded options accounts). Their audience skews toward the exact user profile STALK attracts.

---

## Stream 15: Web Subscription (Bypass Apple 30%)
**Category:** Direct
**When to pursue:** 3–6 months
**Effort:** Medium (web app or web payment page + server-side subscription management)
**ARPU potential:** Same $6.99/mo but STALK keeps 100% instead of 70% — +$2.10/subscriber/mo
**Apple cut:** No (external web payment)
**Risk:** Medium (Apple policy risk if done aggressively; Epic Games case shows the line)
**What needs to be true first:** Web payment infrastructure (Stripe), server-side receipt validation and entitlement sync to iOS app, web presence (web.stalkinvest.com)

Offer the same STALK Pro subscription at web.stalkinvest.com for the same price. Users who pay via web are processed through Stripe (2.9% + $0.30 vs Apple's 30%), meaning STALK nets ~$6.49 instead of ~$4.89 per monthly subscriber. At 1,000 web subscribers, this difference is +$1,600/mo in margin — effectively a second revenue stream from the same product.

The risk is Apple's guidelines: apps cannot link to external purchase flows from within the iOS app itself (though Epic v. Apple and the DOJ consent decree have shifted this line significantly in 2024–2025). The safe implementation is: don't mention the web subscription inside the iOS app. Promote it via email, social, and web only. Users who find it on their own can subscribe there.

**Real example:** Netflix, Spotify, and every major subscription company — they stopped allowing in-app subscriptions on iOS specifically to avoid Apple's cut. Spotify's pricing is €10.99/mo on web vs €10.99/mo through Apple (Spotify refuses to raise prices for Apple subscribers to cover the cut, making Apple IAP economically worse for Spotify — they just stopped accepting new Apple IAP subscribers).

---

## Stream 16: Data Licensing to Hedge Funds / Quant Shops
**Category:** Indirect
**When to pursue:** 12–24 months
**Effort:** High (requires backend, data pipeline, legal data use agreements, privacy compliance)
**ARPU potential:** $0.50–$2.00 per user per year at scale; $2,000–$20,000/mo per institutional client
**Apple cut:** No
**Risk:** Medium (privacy regulation, user trust, legal)
**What needs to be true first:** 25,000+ MAU with real portfolio data, backend infrastructure for aggregation, GDPR/CCPA-compliant anonymization pipeline, legal counsel to structure data licensing agreements

Aggregated, anonymized portfolio data from STALK users reveals retail investor sentiment, positioning, and cost basis across thousands of stocks. Hedge funds, quant shops, and alt-data aggregators pay meaningful amounts for this signal — particularly data on retail crowding in specific tickers, average retail cost basis (which predicts sell pressure), and holding duration patterns.

The privacy implementation matters enormously. Users must consent (in privacy policy and optionally with an explicit "contribute to market research and earn [benefit]" opt-in). Data must be aggregated and anonymized — no individual portfolio data is ever sold. The ethical version of this model is one where users understand their data creates value and ideally share in it (e.g., data contributors get a Pro discount).

**Real example:** Robinhood's PFOF (Payment for Order Flow) was a form of order data monetization. Quiver Quantitative and Quandl built businesses around retail sentiment data. YipitData licenses aggregated app-derived consumer data to hedge funds at $50K–$500K/yr per client.

---

## Stream 17: B2B White-Label for Financial Advisors / Wealth Managers
**Category:** Partnership / B2B
**When to pursue:** 12–24 months
**Effort:** High
**ARPU potential:** $200–$500/mo per RIA seat; 50 advisor clients = $10,000–$25,000/mo
**Apple cut:** No (B2B SaaS invoiced directly)
**Risk:** Medium
**What needs to be true first:** Consumer product-market fit proven, backend infrastructure, white-label theming capability, inbound RIA interest (do not build speculatively), basic compliance features (audit log, client management)

Financial advisors need a tool to show clients their portfolio visually and help them understand their positions. STALK's core product — beautiful portfolio visualization, AI analysis, market context — is exactly what advisors wish they could show clients on a tablet during a review meeting. A white-labeled "Advisor Edition" of STALK allows RIAs to brand the app and use it with all their clients for a monthly seat fee.

The strategic value: B2B revenue is higher-margin, lower-churn, and not subject to Apple's tax. One advisor firm with 200 clients could be a $500/mo customer that stays for years. The risk is that building for B2B prematurely distracts from the consumer product. Only pursue when there is inbound interest from advisors who have already seen the consumer app.

**Real example:** Orion Advisor Technology (formerly Orion Portfolio Solutions) charges RIAs $40–$100/month per user for portfolio reporting tools. Riskalyze (now Nitrogen) grew from a consumer risk-assessment tool to a dominant B2B advisor platform at $200–$400/mo per advisor.

---

## Stream 18: API Access for Power Users / Developers
**Category:** Direct / Platform
**When to pursue:** 12–24 months
**Effort:** High (requires robust backend, API infrastructure, rate limiting, developer portal)
**ARPU potential:** $19–$99/mo per API subscriber; niche market, low volume
**Apple cut:** No (API subscription billed via web/Stripe)
**Risk:** Low (reputation and security risks are manageable with rate limiting)
**What needs to be true first:** Stable backend infrastructure, user portfolio data stored server-side, developer interest (validate with waitlist before building)

Power users — developers, quant hobbyists, spreadsheet-obsessed investors — want programmatic access to their own STALK portfolio data. An API that lets users pull their portfolio, alerts, and analysis into Google Sheets, Notion, custom dashboards, or personal automation scripts. The API is billed as a developer tier at $19–$99/mo, not subject to Apple's cut.

The secondary benefit: an open API creates third-party integrations that extend STALK's surface area. If a developer builds a STALK plugin for Notion or Excel, that's a distribution channel STALK didn't have to build. Open platforms compound.

**Real example:** TradingView's Pine Script and Pine API — developer tools that turned a charting tool into a platform with thousands of third-party scripts, dramatically expanding their total addressable market and retention.

---

## Stream 19: Paid Community / Premium Discord
**Category:** Direct / Platform
**When to pursue:** 6–12 months
**Effort:** Medium
**ARPU potential:** $9.99/mo community tier; at 500 members = $4,995/mo (no Apple cut if sold via web)
**Apple cut:** No (if community subscription is web-sold and Discord-hosted)
**Risk:** Medium (community management is labor-intensive; requires active moderation)
**What needs to be true first:** 10,000+ MAU, identifying 50–100 highly engaged users who would seed a community, a community manager or STALK community lead

A private Discord server exclusively for STALK Pro subscribers or a dedicated "STALK Community" tier at $9.99/mo. The server includes channels for: daily market commentary from top STALK traders, sector-specific rooms, a "show your portfolio" transparency channel, AMAs with successful STALK users, and early access to new STALK features.

The community is self-reinforcing: engaged users create content that attracts new users, who subscribe for community access, who become engaged users. The key is seeding the community with 20–30 high-quality early members before opening broadly. Empty Discord servers kill this model — quality of the founding cohort is everything.

**Real example:** The Motley Fool's Stock Advisor community ($199/yr) — premium community access is a meaningful retention lever. Fintwit/Substack hybrid models like Pomp's "The Pump" newsletter + community show that financially-focused communities convert and retain at high rates.

---

## Stream 20: Financial Education / Courses
**Category:** Direct
**When to pursue:** 6–12 months
**Effort:** Medium
**ARPU potential:** $29–$99 per course (one-time); or bundled in a Pro+ tier at $9.99/mo
**Apple cut:** Yes (if sold as IAP) / No (if sold via web and accessed via external link)
**Risk:** Low
**What needs to be true first:** User base with demonstrated educational interest, content production capability (recorded or written), clear differentiation from free YouTube content

Short-form courses built around STALK's specific features and investment workflows: "How to Read an Earnings Report," "Understanding Options Flow for Portfolio Hedging," "Portfolio Diversification: A Practical Guide Using STALK." Each course is 30–60 minutes, practical, and tied to actions the user can immediately take in the app.

The strategic fit is strong: users who engage with educational content are more engaged with the product, less likely to churn, and more likely to refer others. Education also de-commoditizes STALK — it's no longer just a portfolio tracker, it's the platform where you learn to invest better. The delivery mechanism (video, in-app cards, PDF guides) matters less than the quality of the content.

**Real example:** TastyWorks (now Tastytrade) — financial education as a user acquisition and retention strategy. Investor.gov's content shows the appetite; Tastytrade proves that actionable, opinionated education converts into active traders who become subscribers.

---

## Stream 21: Corporate Equity Plan Tracking (B2B2C)
**Category:** Partnership / B2B
**When to pursue:** 12–24 months
**Effort:** High
**ARPU potential:** $5–$15/employee/month; 1 company with 500 employees = $2,500–$7,500/mo
**Apple cut:** No (B2B contract)
**Risk:** Medium (sales cycle is long; requires compliance features for equity data)
**What needs to be true first:** Robust portfolio tracking for RSUs, ESPPs, and stock options; integration with Carta, Shareworks, or Fidelity NetBenefits; proven consumer product; HR/benefits sales capability

Companies with equity compensation programs (RSUs, stock options, ESPPs) offer STALK Pro to all employees as a benefits perk. Employees use STALK to track their equity alongside their brokerage portfolio. The company pays a per-seat corporate rate. The benefit for companies is real: employees who understand their equity compensation are more likely to remain at the company longer.

This is a long-term play that requires specific features (vesting schedule tracking, RSU tax treatment, ESPP purchase cycle alerts) and a B2B sales motion. The strategic upside is that each corporate client brings hundreds of activated users at near-zero CAC, and employees share the app with non-employee friends who become organic consumer subscribers.

**Real example:** Carta (equity management platform) expanded from cap table management to employee-facing equity tools. Pulley and Shareworks have employee-facing apps specifically for equity tracking. Betterment for Business shows the B2B2C wellness benefit model works in finance.

---

## Stream 22: News / Research Aggregation Premium
**Category:** Direct
**When to pursue:** 6–12 months
**Effort:** Medium
**ARPU potential:** $3–5 incremental per Pro user per year; potential standalone tier at $2.99/mo
**Apple cut:** Yes (IAP)
**Risk:** Low
**What needs to be true first:** Content aggregation pipeline (NewsAPI, Benzinga, Seeking Alpha affiliate content), AI summarization that personalizes to portfolio, push notification delivery

A daily AI-curated digest delivered at market open: every stock in the user's portfolio synthesized into a 3-minute read. Not generic market news — news specifically about AAPL, NVDA, and TSLA because that's what the user owns. Analyst report excerpts, news headlines, insider filings, short interest changes, all filtered to the user's specific holdings.

The differentiation from Bloomberg or CNBC is radical personalization. The user doesn't read news about 500 stocks — they read news about their 12 stocks, synthesized by AI into one crisp briefing. This is a retention feature as much as a revenue feature: users who start their day with STALK's briefing form a habit that makes the app irreplaceable.

**Real example:** Seeking Alpha Premium ($239/yr) generates a significant share of revenue from portfolio-linked news digests. The "Quant Ratings" and "Author Alerts" features — personalized to your watchlist — are their most-cited retention drivers.

---

## Stream 23: Referral Program (Virality Engine)
**Category:** Indirect (reduces CAC; enables subscription revenue)
**When to pursue:** 3–6 months
**Effort:** Low
**ARPU potential:** Indirect — reduces CAC, grows paying subscriber base. Each referral that converts is worth $58–$71/yr in subscription ARPU.
**Apple cut:** No (referral credits are given as subscription extensions, not cash — managed internally)
**Risk:** Low
**What needs to be true first:** 500+ active subscribers, referral tracking infrastructure (can be simple — promo codes + App Store attribution)

"Give a month free, get a month free." Existing Pro subscribers get a shareable link. When a friend signs up through the link, both get one free month of Pro. This converts happy subscribers into a distribution channel. The unit economics are: if a referred subscriber has the same LTV as a direct subscriber ($90 net), the cost of acquisition is one month's revenue ($5.50 net) — a 16:1 LTV:CAC ratio.

This is not a revenue stream in itself — it is the mechanism that amplifies every other revenue stream by growing the user base at near-zero marginal cost. In consumer fintech, word-of-mouth referrals have 2–3x better retention than paid acquisition channels because they come with social proof ("my friend uses this and makes money with it").

**Real example:** Robinhood's free stock referral program drove them from 0 to 1 million users on a waitlist before launch. Acorns' referral program generated $5 per referral and grew their user base to 4 million. Cash App's $5 send/receive referral mechanism was their primary growth engine.

---

## Stream 24: Push Notification Sponsored Alerts (Native Advertising)
**Category:** Indirect / Partnership
**When to pursue:** 6–12 months
**Effort:** Low
**ARPU potential:** $0.50–$2.00 per monthly active user for free-tier users; $5,000–$20,000/mo at 50K MAU
**Apple cut:** No (brand deals invoiced directly)
**Risk:** Medium (user trust — over-monetizing notifications kills engagement)
**What needs to be true first:** 20,000+ MAU, media kit, rate card, direct outreach to fintech brands (brokers, ETF sponsors, financial media)

Free-tier users receive a limited number of "sponsored alert" notifications per week from vetted financial brands. "Webull is offering 12 free stocks to new accounts this week — open your account." "Invesco is hosting a live webinar on tech sector investing — register free." These are not intrusive ads — they are relevant, financial, and can be turned off. The key constraint: maximum 1–2 sponsored notifications per week per user, always clearly labeled "Sponsored."

The risk is destroying notification trust. Notifications are STALK's most valuable engagement channel — open rates on financial push notifications are 15–25% vs. email's 20–30%. Over-monetizing notifications tanks the open rate, which tanks the feature that makes STALK feel responsive. Use this sparingly and only with high-quality brand partners.

**Real example:** Robinhood has done sponsored collections. Stock analysis apps like Webull surface sponsored ETFs in "Trending" sections. The Motley Fool's "sponsored research" alerts to their free newsletter base ($0.50–$2/click) demonstrate the model.

---

## Stream 25: Family / Household Plan
**Category:** Direct
**When to pursue:** 6–12 months
**Effort:** Low
**ARPU potential:** $9.99/mo for up to 5 family members = +$3/mo vs. individual Pro; household ARPU $9.99 vs $6.99
**Apple cut:** Yes (IAP, but Family Sharing reduces cut complexity)
**Risk:** Low
**What needs to be true first:** User base showing family/household adoption patterns, Apple Family Sharing eligibility configuration

A Family Plan at $9.99/mo covers up to 5 Apple Family Sharing members. Couples tracking investments together, parents who want to teach teenagers to invest, families managing household wealth collectively. The household is a natural unit for wealth management — many investing decisions are made at the household level.

Apple Family Sharing integration makes this technically simple: enable family sharing on the subscription in App Store Connect. The monetization gain is +$3/mo per converting household vs. individual subscription, while making STALK feel like essential household infrastructure rather than a solo app.

**Real example:** Spotify Family Plan ($16.99/mo for 6 users vs $9.99/mo individual) generates significantly higher revenue per household than individual plans. Mint (before its death) and YNAB both have family plans as their highest-ARPU tier.

---

## Stream 26: Annual + Lifetime Deal (One-Time Purchase)
**Category:** Direct
**When to pursue:** 3–6 months
**Effort:** Low (one new IAP product)
**ARPU potential:** $149.99 one-time lifetime deal; at 100 buyers/yr = $10,500/yr upfront (no future revenue but improves cash flow)
**Apple cut:** Yes (30% IAP on one-time purchase)
**Risk:** Low (financial risk: if you grow features significantly, lifetime subscribers get them free forever)
**What needs to be true first:** Stable enough feature set that lifetime pricing won't be economically damaging; App Store Connect non-consumable IAP product

A "STALK Pro Lifetime" purchase for $149.99 (roughly 2.5 years of monthly Pro at $6.99/mo). Lifetime deals appeal strongly to price-sensitive users who believe in the app long-term and hate recurring charges. They are also excellent for cash flow: $149.99 today is better than waiting 25 months for the same amount in monthly installments.

The risk: if STALK grows dramatically and adds major new features, lifetime subscribers get them at no additional cost, depressing LTV vs. the subscription model. The mitigation: cap lifetime deals at Pro-tier features as defined at time of purchase; any major new tier (Pro+, Institutional) is not included.

**Real example:** Pocketcasts, Reeder, and many iOS apps have successfully run limited-time lifetime deals through ProductHunt/AppSumo to generate cash, build a loyalty cohort, and drive reviews. AppSumo deals regularly move $100K+ in lifetime software licenses in 2–3 weeks.

---

## Stream 27: AppSumo / LTD Marketplace Launch
**Category:** Direct / Growth
**When to pursue:** 3–6 months
**Effort:** Low–Medium
**ARPU potential:** $49–$99 per LTD deal; $10,000–$50,000 total deal revenue in a 2-week window
**Apple cut:** No (AppSumo handles payment; users get a redemption code)
**Risk:** Low (reputational risk if product isn't polished at time of launch)
**What needs to be true first:** Stable, polished product on App Store; ability to handle redemption codes or account provisioning; approval from AppSumo (competitive application process)

AppSumo features software tools to their 900,000+ entrepreneur and power-user audience. A STALK Pro deal at $49–$79 one-time generates immediate cash, a burst of users, and a flood of reviews. AppSumo's audience skews toward technically sophisticated users who write detailed reviews, generate word-of-mouth, and stay active long-term.

The deal mechanics: AppSumo takes 30–50% of deal revenue but provides the entire audience. STALK handles redemption codes (a simple backend API) and customer support. A conservative AppSumo deal for a finance app of STALK's caliber could move 500–1,000 deals at $49 = $24,500–$49,000 total, of which STALK keeps 50–70%.

**Real example:** Many SaaS tools — Loom, Typeform, SurveySparrow — had their breakout moments on AppSumo. Finance tools like Snowball Analytics (portfolio tracking for dividend investors) ran AppSumo deals that gave them their first 1,000 paying users.

---

## Stream 28: Crypto Portfolio Tracking Premium
**Category:** Direct
**When to pursue:** 6–12 months
**Effort:** Medium
**ARPU potential:** Bundled in Pro or $1.99/mo crypto add-on; potential standalone crypto tier at $3.99/mo
**Apple cut:** Yes (IAP)
**Risk:** Medium (regulatory uncertainty around crypto; development complexity of multi-chain tracking)
**What needs to be true first:** Integration with CoinGecko or CoinMarketCap API for prices, wallet address lookup capability, user demand signal from existing base

Crypto portfolio tracking alongside traditional equities. Users with both a Robinhood account and a Coinbase wallet currently need two separate apps to see their full financial picture. STALK unifies them: your stock portfolio and your crypto portfolio in one health score, one daily briefing, one alert system.

The monetization hook: crypto-specific features (DeFi yield tracking, wallet ENS resolution, NFT portfolio value, on-chain whale watching) are Pro-only. The crypto audience skews younger and pays for convenience tools at high rates — crypto wallet and portfolio tracking apps like Delta and CoinStats convert free users to paid at 5–8%, nearly double the rate of traditional finance apps.

**Real example:** Delta (portfolio tracker) added crypto alongside stocks and became the most popular multi-asset portfolio tracker globally before being acquired. CoinStats ($3.99–$9.99/mo) has 1.5M users with strong subscription conversion on crypto tracking features.

---

## Stream 29: Short Selling / Bearish Signals Premium
**Category:** Direct
**When to pursue:** 6–12 months
**Effort:** Medium
**ARPU potential:** $3.99/mo add-on or bundled in Pro+; targets power traders
**Apple cut:** Yes (IAP)
**Risk:** Medium
**What needs to be true first:** Short interest data API (Fintel, S3 Partners, or FINRA public short data), display UI, user base showing interest in short data

Short squeeze radar and bearish signal data: short interest as % of float, days-to-cover, borrow cost (signals that a stock is hard to short), and historical short squeeze events. This is already referenced as a feature in the StoreKit Pro description ("Short Squeeze Radar") — the execution is connecting a real data source.

The audience is smaller but extremely high-value: retail traders who actively hunt short squeezes (GameStop 2021 was a cultural moment that created permanent demand for this data) and investors who want to know when their holdings have high short interest. Short squeeze events are viral moments — every squeeze brings a wave of new users searching for the app that predicted it.

**Real example:** Ortex (short interest data platform) charges $40–$120/mo and has a dedicated subscriber base of retail traders specifically for short selling signals. Fintel.io includes short data in their $20–$45/mo plans and consistently ranks among the fastest-growing financial data platforms.

---

## Stream 30: International Expansion Premium Tiers
**Category:** Direct
**When to pursue:** 12–24 months
**Effort:** High (localization, international exchange data, tax reporting formats per country)
**ARPU potential:** Same $6.99–$9.99/mo but in new markets; UK/EU/Canada/Australia collectively 3–5x the US market size for investing apps
**Apple cut:** Yes (IAP)
**Risk:** Medium (regulatory: financial apps in UK require FCA notification; EU requires MiFID II compliance disclosures)
**What needs to be true first:** International exchange data (LSE, TSX, ASX, Euronext), local tax reporting format support (UK ISA/SIPP tracking, Australian CGT records), localization for at least one new market, US product stable and profitable

Most US stock tracking apps are US-only by default. The UK, Australia, and Canada have large English-speaking retail investor populations that are underserved by US-centric apps. STALK with minor localization effort could serve these markets and double the addressable market.

The UK market specifically is compelling: the UK has 11 million ISA holders, a culture of stock-picking (Hargreaves Lansdown has 1.7 million clients), and apps like Freetrade and Stockopedia demonstrate strong willingness to pay for premium portfolio tools. An "International Edition" at £5.99/mo (UK) or AU$9.99/mo (Australia) captures this market with modest localization effort.

**Real example:** Sharesight is an Australian portfolio tracker that expanded to UK/Canada/New Zealand and now has 400,000+ users globally, with premium tiers at $27.50–$79/mo. Their success came from localizing tax reporting for each market — the exact feature that creates stickiness.

---

## Stream 31: STALK Pro Gift Cards / Give-as-Gift
**Category:** Direct
**When to pursue:** 3–6 months (Q4 holiday timing matters)
**Effort:** Low
**ARPU potential:** $49.99 per gift (annual plan); new subscriber cohort from gifted users who then retain on their own
**Apple cut:** Yes (IAP gift purchases)
**Risk:** Low
**What needs to be true first:** App Store gift subscription capability enabled in App Store Connect; holiday marketing materials

Financial apps make ideal gifts for the investor in your life. App Store supports gifting subscriptions — a one-tap mechanism where a user can buy someone else a year of STALK Pro. The gifting cohort has notably higher initial engagement than self-purchased subscriptions (social proof and curiosity from the gift context drives activation).

The holiday window (Black Friday through Christmas) is the peak period for subscription gifts. A simple marketing push — "Give STALK Pro to the investor in your life" — with social sharing of gift messages can generate a burst of annual plan purchases at $49.99 each. Each gifted subscription that the recipient continues after expiry becomes a recurring subscriber acquired at zero CAC.

**Real example:** TradingView gift subscriptions, Headspace gift plans, Duolingo Super gift — all major apps have leveraged gifting as a Q4 revenue amplifier. The App Store gifting mechanism handles all the complexity.

---

## Stream 32: In-App Brand Deals / Native Sponsorships
**Category:** Partnership
**When to pursue:** 6–12 months
**Effort:** Low–Medium
**ARPU potential:** $0.10–$0.50 per monthly active user per sponsored content unit; $5,000–$25,000/mo at 50K MAU
**Apple cut:** No (brand invoiced directly outside Apple)
**Risk:** Medium (user trust risk if content is seen as inauthentic)
**What needs to be true first:** 20,000+ MAU, clear separation of editorial and sponsored content, media kit with audience demographics, legal disclosure framework

Branded content units inside the STALK feed: "Daily Brief sponsored by Charles Schwab," "This week's Sector Spotlight is brought to you by iShares," "Portfolio Health Score powered by SoFi." These are not pop-up ads — they are native, contextually relevant brand placements that feel like part of the product experience. The disclosure is mandatory and visible.

The inventory that has the most commercial value: the Daily Brief (high open rate, daily touchpoint), the Sector Heat Map (relevant to financial brands), and the App Launch screen (highest impression volume). Pricing is CPM-based: $10–$25 CPM on high-engagement financial content is defensible given the audience quality. At 50K DAU and a conservative 1 ad unit/day at $15 CPM, this is $750/day = $22,500/mo.

**Real example:** Robinhood's "Robinhood Learn" content has brand partnerships. StockTwits serves sponsored content from ETF issuers and brokers throughout their feed. Morning Brew's finance newsletter generates $20–$30 CPM from financial brand advertisers.

---

## Stream 33: Transaction / Portfolio Benchmark Tool (B2B SaaS)
**Category:** B2B / Indirect
**When to pursue:** 12–24 months
**Effort:** High
**ARPU potential:** $500–$2,000/mo per B2B client (RIA compliance, fintech, research firm use cases)
**Apple cut:** No
**Risk:** Medium
**What needs to be true first:** Sufficient aggregated user data to create meaningful benchmarks, backend infrastructure, legal data use review

Financial advisors, robo-advisor platforms, and fintech companies want to benchmark their clients' portfolios against real retail investor portfolios — not theoretical indices. "How does my client's portfolio compare to what retail investors of similar risk tolerance actually hold?" STALK's aggregated, anonymized data answers this question in a way that no existing index or benchmark can.

This becomes a B2B API product: RIAs pay $200–$500/mo for API access to STALK's retail benchmark dataset. The query interface lets them compare portfolio composition, sector allocation, and volatility profile against STALK's anonymized retail cohort. This is distinct from the hedge fund data licensing play — the use case is advisor reporting, not quant alpha.

**Real example:** Quiver Quantitative sells retail flow data as a B2B product. YipitData sells aggregated consumer behavior data to financial services firms at $50K–$500K/yr enterprise contracts.

---

## Stream 34: Branded Merchandise (Low Priority / Community Signal)
**Category:** Indirect
**When to pursue:** 12+ months
**Effort:** Low
**ARPU potential:** $15–$40 per item; primarily a brand signal, not a meaningful revenue stream
**Apple cut:** No (external commerce)
**Risk:** Low
**What needs to be true first:** Recognizable brand, vocal community that self-identifies as "STALK users," brand identity strong enough to be worn publicly

STALK-branded merchandise: t-shirts ("I STALK the market"), hoodies, mugs, stickers. This is not a revenue stream — it is a brand-building mechanism that converts engaged users into walking brand ambassadors. The Robinhood green hoodie was a cultural signal in finance circles. The STALK brand, if it reaches cultural resonance, should have merch.

Revenue is negligible ($5–$15 margin per item after fulfillment). The value is the 100% of users who wear or display STALK merch as a word-of-mouth vector. Use this as a reward for top community members, referral program prizes, and conference giveaways.

**Real example:** Robinhood, Coinbase, and Wealthsimple all had merchandise that became status symbols in their respective communities. The merch itself rarely generates meaningful revenue — it generates brand salience.

---

## Stream 35: STALK Pro for Teams / Investment Clubs
**Category:** Direct
**When to pursue:** 6–12 months
**Effort:** Medium
**ARPU potential:** $24.99/mo for 5-member team vs $6.99 individual = $5/seat vs $6.99 solo, but 5x the users per account
**Apple cut:** Yes (IAP)
**Risk:** Low
**What needs to be true first:** Portfolio sharing/comparison feature, shared watchlist capability, group alert settings

Investment clubs — groups of 3–20 friends or colleagues who invest together — need a shared portfolio view. STALK Pro for Teams enables a shared watchlist, group portfolio view (each member's portfolio aggregated), group alerts, and a "club leaderboard" showing member performance. At $4.99/member/mo for a 5-person club, STALK earns $24.99/mo from one club vs. $6.99 from one individual.

The social dynamics are powerful: investment clubs with a shared tool have much higher engagement and retention than solo trackers. The club context creates social accountability (nobody wants to be the worst performer in the group), which drives daily active usage. Investment clubs also recruit new members — each new member is a new STALK user and potential subscriber.

**Real example:** Yahoo Finance Groups (discontinued but showed demand), Commonstock's collaborative investing features, and Collective2 (investment club tracking) show that the group investing use case has organic demand among retail investors.

---

---

# Revenue Stack Recommendation

## Day 1 — Launch
**Active Streams:** #1 (Freemium Subscription), #2 (Broker Affiliate), #3 (Premium Themes)

These three streams require zero additional engineering. Everything is built. The subscription drives recurring revenue; the affiliate drives one-time bounties with no Apple cut; themes catch the upgrade-reluctant user who still wants to support the app. Total realistic MRR by end of Month 1: $50–$300.

## Month 3 ($1K MRR)
**Add:** #7 (Custom Watchlist Alerts — tighten free tier limit), #15 (Web Subscription), #23 (Referral Program), #31 (Gift Subscriptions, if Q4)

By Month 3, you have enough users to measure churn and conversion behavior. Tighten the free-tier alert limit to 3 alerts (from unlimited) to sharpen the upgrade trigger. Launch the web subscription at web.stalkinvest.com and promote it only via email and social — never in-app. Launch the referral program ("give a month, get a month") to begin compounding user growth. Target: $1K MRR by end of Month 3 is achievable with 200 paid subscribers.

## Month 12 ($10K MRR)
**Add:** #4 (Analyst Alerts), #5 (Earnings Whisper), #9 (Options Flow — real data), #12 (Financial Advisor Lead Gen), #19 (Paid Community), #22 (News Research Aggregation), #27 (AppSumo LTD)

At $10K MRR, the subscription base is large enough to absorb data API costs for analyst and earnings features. The advisor lead gen requires zero engineering — just a partnership with SmartAsset or Harness Wealth. The paid community can launch as a simple Discord invite available to Pro subscribers. An AppSumo deal (3–6 months after launch, once the product is polished) can inject a one-time $15K–$30K cash bolus and bring 500–1,000 new users in one week.

## Year 2 ($50K MRR)
**Add:** #10 (Creator Monetization), #11 (Sponsored Watchlists), #16 (Data Licensing), #17 (B2B White-Label), #20 (Education Courses), #25 (Family Plans), #28 (Crypto Tracking), #29 (Short Selling Premium), #30 (International Expansion)

At $50K MRR, STALK has 5,000–10,000 paying subscribers and tens of thousands of MAU. The platform is large enough to support creator monetization (enough traders worth following), sponsored content (enough audience for brands to pay for placement), and preliminary data licensing discussions. International expansion into UK and Australia becomes viable with modest localization. The education catalog, if started in Year 1, is now a polished product that adds meaningful ARPU.

---

# LTV Model: At $10K MRR

Assumed state: 10,000 MAU, 400 active Pro subscribers (4% conversion), 6% monthly churn, 12 months of operation.

| Stream | Subscribers/Volume | Monthly Revenue | % of Total |
|--------|-------------------|-----------------|------------|
| #1 Freemium Subscription (monthly plan, 70% of paid base) | 280 @ $4.89 net | $1,369 | 13.7% |
| #1 Freemium Subscription (annual plan, 30% of paid base) | 120 @ ~$3.75/mo net | $450 | 4.5% |
| #2 Broker Affiliate | 100 funded accounts/mo @ $120 avg | $1,200 | 12.0% |
| #3 Premium Themes | 50 purchases/mo @ $2.79 net | $140 | 1.4% |
| #4 Analyst Alerts (bundled in Pro — drives conversion, not incremental) | — | — | — |
| #5 Earnings Whisper (bundled in Pro) | — | — | — |
| #9 Options Flow (bundled in Pro) | — | — | — |
| #12 Financial Advisor Lead Gen | 20 qualified leads/mo @ $100 avg | $2,000 | 20.0% |
| #15 Web Subscription | 100 web subscribers @ $6.49 net | $649 | 6.5% |
| #19 Paid Community (Discord, 200 members @ $9.99) | 200 @ $9.99 (no Apple cut) | $1,998 | 20.0% |
| #22 News Research (bundled in Pro) | — | — | — |
| #23 Referral Program (reduces CAC, not direct revenue) | — | — | — |
| #27 AppSumo LTD (one-time bolus, amortized) | ~$25K deal / 12 months | $2,083 | 20.8% |
| **Total** | | **~$9,889/mo** | **~$10K MRR** |

**Key observations:**
1. Subscription (streams #1 and #15 combined) accounts for ~$2,468/mo — only 25% of total at this milestone. The diversified stack matters significantly.
2. Financial advisor lead gen (#12) and paid community (#19) together contribute 40% of MRR — both require no Apple tax and have high margins.
3. The AppSumo LTD deal is a one-time event that distorts the monthly picture — it should be excluded from steady-state modeling; it inflates Month 6–12 MRR while not recurring.
4. Recurring steady-state MRR (excluding AppSumo amortization) is ~$7,806/mo — the path to genuine $10K recurring MRR requires either stronger subscription growth (more users) or adding a second sustained high-value stream (community or advisor leads).

**Blended ARPU across all 10,000 MAU:** $0.98/user/mo (including non-paying users)
**ARPU across 400 paying subscribers:** $24.72/subscriber/mo — meaningfully above the subscription-only $6.99 base, validating multi-stream monetization.

---

*Rex (CRO), STALK*
*Document version: 1.0 — covers 35 revenue streams across all time horizons*
*Next revision: when first 1,000 MAU data is available to validate conversion assumptions*
