# STALK Revenue Recommendation
**Date:** 2026-06-09
**Author:** Rex (CRO)
**Horizon:** 0–6 months to first meaningful revenue
**Decision type:** Primary business model selection + execution plan

---

## The Recommendation

**Primary: Freemium Subscription (current plan, ship it)**
**Supplemental: Broker Affiliate (add before launch, zero engineering cost)**
**Defer: Everything else**

No pivots. No new models. The current plan is correct — it just needs to be executed.

---

## Why Subscription Wins

This is not a close call. Subscription is the only model where:

- **The product is already built.** StoreKit paywall, product IDs, free trial logic — all done. Every other model requires weeks to months of additional engineering.
- **Revenue can start within weeks of App Store approval.** No backend, no enterprise deals, no data pipeline required.
- **ARPU is defensible.** $58/yr net (year 1) per paying subscriber is 50–100x better than ad-supported ARPU and comparable to the best consumer fintech tools on the market.
- **It aligns incentives correctly.** When STALK makes money by delivering value to users, the product gets better. When STALK makes money by selling user data, the product gets weaker.
- **Compounding MRR is a moat.** Subscribers who stay for 6+ months become evangelists. Word-of-mouth in the investing community is the cheapest and highest-quality acquisition channel.

The hard truth: no business model makes money without users. Subscription forces STALK to be good enough that people pay. That discipline is the real moat.

---

## Why Add Broker Affiliate Now

Broker affiliate is not the primary model — it is a complementary revenue layer that:

1. **Requires no engineering.** Deep link to Webull or IBKR. Add one disclosure sentence. Done.
2. **No Apple cut.** 100% of the $100–$200 bounty stays with STALK.
3. **Reinforces the product narrative.** STALK helps you track your portfolio. Naturally, it also helps you open the account you're tracking in. This is contextually logical, not extractive.
4. **Improves user activation.** A user who opens a brokerage account through STALK is now financially connected to the app. Their portfolio IS the STALK portfolio. Retention goes up.

**Placement:** Single CTA during onboarding ("Don't have a brokerage yet? Get started with Webull — recommended by STALK.") and a card in Settings. Not aggressive. Not repeated. Disclosed.

**Program to sign up for first:** Interactive Brokers Affiliate ($200/funded account, 90-day payout). Apply at interactivebrokers.com/affiliates. Takes 1–3 business days to get a link.

---

## What to Defer (and When to Revisit)

| Model | When to revisit |
|-------|----------------|
| Data Licensing | When STALK has 25K+ MAU with real portfolio data and a backend is live |
| Premium Market Data | When STALK has $5K+ MRR and can absorb fixed data API costs |
| B2B / White-Label | When STALK has proven consumer product-market fit and has inbound enterprise interest |
| In-App Advertising | Never as a primary model; only if a direct brand deal emerges (e.g., Webull sponsors the Daily Brief) |
| Transaction-Based | Year 3+ if STALK has 500K+ users and regulatory infrastructure is viable |

---

## 6-Month Revenue Execution Plan

### Month 0 (now): Infrastructure
- [ ] Itamar enrolls in Apple Developer Program ($99/yr — required to unlock everything)
- [ ] App Store Connect product IDs created: `com.itamar.stalk.pro.monthly` + `com.itamar.stalk.pro.annual`
- [ ] Sign up for Interactive Brokers affiliate program
- [ ] Finalize App Store listing (screenshots, description, category: Finance)
- [ ] Submit for App Store review

### Month 1: Launch
- [ ] App goes live on App Store
- [ ] Broker affiliate CTA added to onboarding + settings
- [ ] Launch post: Product Hunt, Twitter/X, Reddit (r/stocks, r/investing, r/StockMarket)
- [ ] Share with 10–20 personal investor contacts for first organic installs
- [ ] **Revenue target: $0–$200** (first trial conversions, first affiliate clicks)

### Month 2: Paywall Optimization
- [ ] Analyze which Pro features drive the most upgrade intent (use App Store analytics)
- [ ] A/B test paywall trigger timing (immediately on premium feature tap vs after 3 days)
- [ ] Add "Conversion Moments": Whale Alert preview (blurred, Pro required), AI analysis limit (5 free, then paywall)
- [ ] **Revenue target: $200–$500 MRR**

### Month 3: Growth + Retention
- [ ] First month retention analysis: are users who subscribed still using the app?
- [ ] If churn >10%/month: fix the product (missing features, bugs, thin free tier)
- [ ] If churn <5%/month: pour fuel on acquisition (content, ASO, referral program)
- [ ] Push notification re-engagement for free users who haven't opened in 7 days
- [ ] **Revenue target: $500–$1,500 MRR**

### Month 4–5: Scale What's Working
- [ ] Identify primary acquisition channel (organic search, social, direct) — double down
- [ ] Referral program: "Give 1 month free, get 1 month free" (drives word-of-mouth without discounting)
- [ ] Annual plan push: offer upgrade from monthly → annual at 2-month discount
- [ ] Affiliate diversification: add Webull link alongside IBKR
- [ ] **Revenue target: $1,500–$3,000 MRR**

### Month 6: Evaluate and Expand
- [ ] If at $3K+ MRR: evaluate a premium data add-on (partner with Polygon.io for real-time)
- [ ] If at 10K+ MAU: begin data pipeline architecture planning (backend work)
- [ ] If at $5K+ MRR: evaluate paid acquisition (Facebook/Instagram, Apple Search Ads)
- [ ] **Revenue target: $3,000–$5,000 MRR**

---

## Revenue Model: Conservative Scenario

Assumptions: slow organic growth, 3% conversion rate, 70% monthly / 30% annual plan mix, 6% monthly churn.

| Month | MAU | Paid Subscribers | Net MRR (subscription) | Affiliate Revenue | Total Monthly Revenue |
|-------|-----|-----------------|------------------------|-------------------|-----------------------|
| 1 | 200 | 6 | $29 | $50 | $79 |
| 2 | 500 | 15 | $74 | $100 | $174 |
| 3 | 1,200 | 36 | $176 | $200 | $376 |
| 4 | 2,500 | 75 | $368 | $350 | $718 |
| 5 | 5,000 | 150 | $735 | $600 | $1,335 |
| 6 | 8,000 | 240 | $1,176 | $800 | $1,976 |

## Revenue Model: Optimistic Scenario

Assumptions: strong launch (Product Hunt, press), 5% conversion, 30% annual plan mix, 4% monthly churn.

| Month | MAU | Paid Subscribers | Net MRR (subscription) | Affiliate Revenue | Total Monthly Revenue |
|-------|-----|-----------------|------------------------|-------------------|-----------------------|
| 1 | 500 | 25 | $123 | $150 | $273 |
| 2 | 1,500 | 75 | $368 | $350 | $718 |
| 3 | 4,000 | 200 | $980 | $600 | $1,580 |
| 4 | 8,000 | 400 | $1,960 | $1,000 | $2,960 |
| 5 | 15,000 | 750 | $3,675 | $1,500 | $5,175 |
| 6 | 25,000 | 1,250 | $6,125 | $2,000 | $8,125 |

Note: Net MRR figures are post-Apple-cut (30% year 1). Affiliate assumes $100 average bounty, 1% MAU conversion rate.

---

## The Single Most Important Metric

**Month 3 subscription churn rate.**

Everything else is vanity until you know whether users who pay stay paying. If churn is >8%/month, the product has a retention problem — fix it before scaling acquisition. If churn is <4%/month, you have a healthy business — pour fuel on it.

MRR without retention is a leaky bucket. Measure churn at Month 3. Build everything else around fixing or amplifying that number.

---

## One-Line Summary

**Ship the subscription, add the affiliate link, get to 1,000 MAU, measure churn at 90 days — everything else is noise until you have that data.**

---

*Rex (CRO), STALK*
*Next review: 2026-07-09 (30 days post-launch)*
