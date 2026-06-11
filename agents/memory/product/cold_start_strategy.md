# Social Network Cold Start Strategy
**Author:** Sam (CPO)
**Date:** 2026-06-11
**Status:** Strategy — pre-launch
**Problem being solved:** Finance apps have no social graph at launch. Social features require users to feel the network, but the network requires users.

---

## The Problem, Stated Precisely

Every social product faces the cold start problem. STALK's version is unusually hard because:

1. **Finance is private.** People share their gym selfies. They do not share their brokerage statements. The social norm barrier is higher than consumer social.

2. **Portfolio data is sensitive.** A bad month on Instagram costs you likes. A bad month visible to your real social network costs you face and (potentially) professional credibility.

3. **Network effects in finance require trust.** You only follow someone's trades if you believe they know more than you. Trust takes time to establish. Following a stranger's trades because they're "also on STALK" is not sufficient.

4. **The chicken-and-egg is particularly vicious.** You need traders to post. Traders won't post to an empty feed. The feed stays empty. The app feels dead.

---

## Phase 1: Fake It Until the Network Is Real

### The Mock Trader System

At launch, STALK should populate the social graph with a set of **curated mock traders** — personas that feel like real traders but are controlled by the product team.

This is not unethical if done correctly. Early Facebook had test accounts. Reddit moderators seeded early subreddits with posts. Product Hunt's early listings were hand-curated by Ryan Hoover. The practice is normal; the ethics depend on implementation.

**Ethical implementation rules:**
- Mock traders are clearly labeled in internal systems but look like real users in the UI
- They are never presented as "this is a real verified person" — they're anonymous like "momentum_trader_nyc"
- They do not give financial advice or investment signals — they post takes and commentary, not instructions
- They are removed or replaced by real users as the real community grows
- If ever a user asks "is this a real person?" the answer must be honest

**Mock trader personas (design for launch):**

1. **@macro_mike** — Macro/rates focused. Posts about Fed decisions, inflation data, yield curves. Sophisticated vocabulary but explains clearly. Avatar: anonymous silhouette. ~400 "followers" (other mock accounts).

2. **@tech_stack_jenny** — FAANG investor, writes brief conviction takes: "MSFT earnings call was boring and I mean that as a compliment. +MSFT." Mixes insider-feeling language with accessible reasoning.

3. **@value_val** — Patient, Buffett-adjacent. Posts infrequently, long-form. "I've been adding to $BRK.B on every dip for 3 years. Here's why I still believe." Anchors the feed in quality when other posts trend shallow.

4. **@options_oracle** — High-risk, high-reward options trader. Posts W's prominently, occasionally posts L's (important — authenticity requires visible losses). High engagement from risk-tolerant users.

5. **@etf_elena** — Passive/index focused. Counter-voice. "Another week of active managers underperforming SPY. Here's the data." Generates productive disagreement in the feed.

**Content for mock traders:**
- Write 2-3 posts per week per persona
- Posts must reference real, timestamped market events (they need to feel current)
- Build a 90-day post backlog before launch so new users see history, not just today
- Reaction counts should start at believable but not inflated levels (3-12 reactions per post)

### What Makes These Feel Real (Not Cringe)

The line between "authentic voice" and "corporate marketing cosplay" is the difference between a working mock social graph and an embarrassing product.

**Authenticity markers:**
- Post losses, not just wins. A feed of 🔥 hot takes that are always right is immediately recognizable as fake.
- Use real ticker symbols and real prices. Reference actual earnings calls, actual CPI prints. Ground every post in a verifiable market event.
- Voice is consistent and specific per persona. @macro_mike doesn't suddenly start talking like @options_oracle.
- Posts have texture: typos occasionally, a "wait, edited" correction once, a "🤔 not sure about this one" post. Real people doubt themselves.
- No post ever says "I made 40% on this trade this month!" — performance numbers in mock traders should be realistic (8% this month, -2% that month).

**Cringe anti-patterns to avoid:**
- "Wow, AAPL earnings were really something! What does everyone think?" — this is brand voice, not trader voice
- Perfectly formatted posts every time
- No losses ever
- Suspiciously on-brand language ("STALK makes it so easy to track...")
- Posts that are implicitly product advertisements

---

## Phase 2: Introducing Real Social

### The Threshold Question

There is no universal right answer. The question is: at what scale does a real social post get enough engagement to not feel embarrassing for the poster?

A post with 0 reactions on a feed with 50 users is just "quiet." A post with 0 reactions on a feed with 50,000 users is rejection.

**Recommended threshold: 1,000 MAU minimum before enabling real user posts.**

Rationale:
- At 1,000 MAU, assuming 10% post and 80% read, a post gets seen by ~80 users and gets 8-15 reactions on average
- That's enough to feel alive
- Below 500 MAU, the expected reaction count per post is below 5 — not enough social validation to justify the vulnerability of posting

**Soft rollout approach:**
1. At 500 MAU: enable posting for opted-in power users only (invite via in-app prompt to "early community members")
2. At 1,000 MAU: open posting to all users, keep mock traders active but reduce their post frequency
3. At 5,000 MAU: gradually sunset mock traders one by one, replacing with promoted real users
4. At 10,000 MAU: full real social graph, mock traders fully retired or clearly marked as "STALK Official" accounts

### The Opt-In Architecture

Never make the social feed the only experience. Users who do not want to participate in social features should have a fully functional portfolio tracker. Social is additive, not required.

This is both ethical and strategic: forcing social participation before critical mass feels invasive. Letting users choose in means early social participants are self-selected as genuinely interested — higher quality early community.

---

## What Makes a Finance Social Post Compelling vs. Cringe

This is the most important product question for STALK's social layer. Finance is a domain where authenticity is everything. One cringe post from a mock trader, or one blatantly promotional real-user post, can define the community tone forever.

### Compelling

**A good finance social post has:** conviction + humility + specificity + timing.

- "Just averaged down on $META at $485. Either this is the last obvious buying opportunity or I'm catching a falling knife. I think it's the former. Here's my reasoning: [3 sentences]."
- "Sold half my NVIDIA position today at $950. Not because I think the AI story is over — I don't. But because I've never let a single position get to 35% of portfolio and I'm not starting now. Discipline > conviction."
- "I was wrong about $INTC. Had a 2-year bull thesis, it fell apart. Here's what I missed: [specific thing]."

Common elements:
- First-person, specific decision made today
- A specific price mentioned (grounds it in reality)
- Vulnerability or uncertainty present
- Reasoning stated briefly — not a full research note, just the logic in 2 sentences
- Not asking for engagement ("what do you think?") — just sharing

### Cringe

- "Really excited about my TSLA position! 🚀🚀🚀"
- Vague statements with no actionable content: "The market is wild right now"
- Showing gains only, never losses
- Posts that read like they're performing for an audience rather than recording genuine thinking
- Obvious pumping: "$MSTR is going to 1M, trust the thesis" with no reasoning
- Posts clearly designed to get reactions rather than share real perspective

### The Authenticity Principle

Finance social credibility = (accuracy over time) × (willingness to post losses) × (specificity of reasoning)

A trader who posts about their wins AND losses, with reasoning, and who is right more often than not over time, is the ideal community participant. Design the feed to reward this profile. If the reaction system and algorithmic ranking reward bragging and performance, you will get bragging and performance. If it rewards reasoning and accuracy, you will get reasoning and accuracy.

Feature idea: post-outcome tagging. A week after a "going long $AAPL" post, auto-attach the price outcome to the post. "+7.2% since posted" or "-3.1% since posted." This makes every post into a verifiable record. Users who share reasoning and are right will become trusted voices. This single feature may be the most important thing that differentiates STALK social from every other finance social product.

---

## The "Portfolio to Follow" Product: Curated Social Before Real Users

This is the most powerful cold start solution Sam can recommend.

### The Concept

Before real social, STALK can offer **curated investment themes** framed as "portfolios to follow." These are:

- Hand-built by the product team (or licensed from financial data providers)
- Framed as "themes" rather than advice: "High-Conviction AI Infrastructure," "Dividend + Growth Balance," "Small Cap Value Watchlist"
- Updated weekly or monthly with a brief rationale

This is the **index fund analogy**: index funds are "follow the market consensus" as a product. STALK's version is "follow this curated perspective" as a social product.

### Why This Works as a Cold Start Strategy

1. **No real social graph needed.** The product team creates the portfolios. No users required.

2. **Builds the habit of "following."** Users who follow a curated portfolio develop the behavioral pattern of checking what that portfolio is doing. This is the same mental model as following a person — and creates the habit that real social follows will leverage.

3. **Natural onboarding to real social.** When real traders with tracked performance show up, users who have been following curated portfolios already understand the value proposition: "follow someone whose judgment I trust, see what they're holding."

4. **Defensible as a product on its own.** Curated investment themes are valuable regardless of social features. This is a product you could charge for (and likely should — this is a Pro feature).

5. **Creates the "feed content" problem without the social graph problem.** The social feed needs content. Curated portfolios provide structured content until real user content is available.

### What to Build for Portfolios to Follow

Minimum: 5 distinct portfolio themes at launch.

Suggested starting portfolios:
- **AI Infrastructure** — NVDA, MSFT, AMD, TSMC, ORCL + reasoning
- **Boring Compounders** — BRK.B, V, MA, COST, WMT — low drama, consistent growth
- **Rate Sensitive Recovery** — Regional banks, REITs, utilities — for when rates fall
- **Concentrated Conviction** — 5 stocks only, high-conviction, rebalanced quarterly
- **SPY + 10%** — Index core with 5 high-conviction satellites

Each portfolio:
- Has a weekly "portfolio manager note" (300 words, written by product team or a contracted investment writer)
- Shows live performance vs. SPY benchmark
- Shows historical performance from inception
- Can be added to your watchlist / "followed" with one tap

### The Bridge to Real Social

When real users arrive, surface them using the portfolio-following as a discovery mechanism:

"@value_val follows a similar strategy to 'Boring Compounders' — 78% position overlap. Want to follow their portfolio?"

This is the moment the curated product converts to a real social graph. The user has already been trained to follow portfolios. Following a real person is the natural evolution.

---

## Risk: Regulatory Considerations

Before launching any social portfolio feature, review:

1. **Investment advice definitions** vary by jurisdiction. "Follow this portfolio" may qualify as investment advice in some regions.
2. **FINRA rules** (US) on social media and investment recommendations apply to registered entities but inform best practices regardless.
3. **Safe harbor framing**: position all social content as "investor perspectives, not advice." Add persistent disclosure where required.
4. **Copy trading specifically** (one-click copy of another user's full portfolio) will likely require legal review before launch.

This is not a reason to not build it. It is a reason to build it with legal review in parallel, not after.

---

## Summary: Cold Start Playbook in Sequence

```
Pre-launch:
  → Build 5 mock trader personas with 90-day post backlog
  → Launch 5 curated "portfolios to follow" themes
  → Enable streak + XP (solo, no social needed)

0–500 MAU:
  → Mock traders posting 2x/week each
  → Curated portfolios updated weekly with manager notes
  → No real user posting yet

500–1,000 MAU:
  → Invite 50 power users to beta-post (opt-in only)
  → Monitor quality of real posts; curate feed manually
  → Maintain mock traders at reduced frequency

1,000–5,000 MAU:
  → Open posting to all users
  → Reduce mock trader frequency by 50%
  → Surface "portfolios to follow" → real user bridge recommendations
  → Launch leaderboard (enough users to feel real now)

5,000+ MAU:
  → Sunset mock traders one by one; replace with "STALK Editorial" label for any remaining product accounts
  → Full real social graph operational
  → Consider copy portfolio feature with legal sign-off
```

The cold start problem is solvable. The key insight: do not try to fake social community. Instead, provide genuine value through curated content and solo gamification mechanics, and let the social layer emerge when there are enough real users to sustain it. The fake graph is a scaffold, not the building.
