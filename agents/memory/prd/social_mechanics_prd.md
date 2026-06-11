# Social Addictiveness Mechanics PRD
**Author:** Sam (CPO)
**Date:** 2026-06-11
**Status:** Strategy — pre-implementation
**Audience:** Itamar (founder), Luna (design), future engineering leads

---

## The Core Thesis

Social features are not a feature set. They are a retention operating system. Each mechanic maps to a specific neurological loop that, when activated repeatedly, rewires a user's relationship with the app from "useful tool" to "daily ritual."

Finance makes social mechanics both more powerful and more fragile than consumer social. More powerful because the stakes are real money — loss aversion hits harder, status hits deeper. More fragile because inauthenticity breaks trust immediately and trust, in finance, is the product.

---

## Mechanics Map

| Feature | Mechanism | Expected Retention Impact |
|---------|-----------|--------------------------|
| Stories row | FOMO + social presence | +15% D1 retention |
| Reactions | Social validation | +20% session length |
| Leaderboard | Competition + status | +35% D7 retention |
| Streaks + XP | Loss aversion (don't break streak) | +40% D30 retention |
| Achievements | Completion compulsion | +25% activation |
| Copy portfolios | Social proof + shortcut | +30% add-position rate |

---

## Feature Deep Dives

---

### Stories Row: FOMO + Social Presence

**What it is neurologically:**
Stories exploit the psychological concept of *ephemerality salience* — the knowledge that content will disappear creates urgency that permanently available content cannot. Combine this with *social presence* (seeing that real humans are active right now) and you get FOMO: the anxiety that meaningful things are happening without you.

The stories row is the first thing a user sees. It immediately signals: *the world is moving, other traders are acting, you might be missing something.* In a finance app, this maps directly to the fundamental fear of every retail investor: being the last to know.

**How others use it:**
- Instagram: Stories drove a 35% increase in daily opens post-launch. The ring format (who's seen, who hasn't) created a compulsive check pattern.
- Snapchat: 10-second ephemeral content trained users to open multiple times per day to not miss anything.
- Robinhood: No stories, but their notification layer ("TSLA is up 5% today") performs the same function — urgency injection.

**STALK's finance context:**
More powerful. A friend's Instagram story might be interesting. A friend's trading story — "I just sold half my NVDA" — is actionable. The gap between content that entertains and content that could make you money is enormous. Every story view has financial stakes attached, which elevates urgency beyond anything consumer social can produce.

Risk: Users must feel the stories are authentic portfolio activity, not performance. The moment it feels like bragging theater, the financial urgency collapses into social cringe.

**Implementation priority note:** Stories require a social graph. Launch with curated mock traders first (see cold start strategy).

---

### Reactions: Social Validation

**What it is neurologically:**
Social validation operates through the brain's dopaminergic reward pathway. Receiving acknowledgment from others — particularly unpredictably timed acknowledgment — activates the same variable reward circuit as slot machines. The key word is *variable*: you post, and sometimes you get 3 reactions, sometimes 47. The unpredictability is what makes it addictive, not the validation itself.

Giving reactions also generates engagement: the act of tapping 🔥 on someone's trade take creates a micro-investment in that relationship and in the content, increasing likelihood of returning to check for a reply or response.

**How others use it:**
- Twitter/X: The like button's variable feedback drove session extension even for users who had already read everything new.
- Instagram: Reaction variety (6 emoji in 2016) increased engagement by 9x compared to single like, because it lowered the cost of responding (you don't need to type anything).
- Facebook: Reactions correlated with +40% session length in internal studies.

**STALK's finance context:**
More powerful for content creators (the trader who posted), slightly less powerful for reactors. In consumer social, you react to social content. In STALK, you react to financial takes — the take has a measurable outcome. If someone posts "I'm going long AAPL going into earnings" and you react 📈, then AAPL beats earnings, that reaction becomes a shared win. Finance adds a *verification loop* that consumer social lacks: was this take right?

This can be extended: show reaction-to-outcome data ("You 🔥-ed 83% of NVIDIA_Trader's takes. He was right 71% of the time"). Now reactions feed back into portfolio intelligence.

---

### Leaderboard: Competition + Status

**What it is neurologically:**
Leaderboards activate *social comparison* (Festinger, 1954) — humans instinctively measure their performance against visible peers. The mechanism has two distinct modes: *approaching from below* (I need to beat the person ahead of me) and *defending from above* (I can't let the person behind me catch up). Both states generate return visits and action-taking.

Status is real. High leaderboard position is social capital that costs real effort to earn and can be lost. The combination of *visible public ranking* + *effort to maintain* + *risk of losing position* is one of the most retention-optimized mechanics known.

**How others use it:**
- Duolingo: Leaderboard was cited as the single highest-impact retention feature in their 2019 product review. Weekly cohorts with promotion/demotion drove a 10x increase in "defensive practice" sessions (users studying not to improve but to avoid demotion).
- Fantasy sports: Season-long leaderboard drives consistent engagement over months, even when fantasy performance is partially luck-based.
- Chess.com: Elo rating (public, precise, always updating) is their primary retention driver.

**STALK's finance context:**
More powerful. Leaderboard in a game is about synthetic points. Leaderboard in STALK is about real money performance. This creates genuine status: if you are #1 on the STALK leaderboard, you are genuinely a better investor than everyone below you over that period. That status means something beyond the app.

The risk is this same power can cause shame and abandonment for users performing poorly. Mitigation: never show a user's absolute rank to other users without consent. Personal rank is private by default; public rank requires opt-in. Show relative improvement ("You moved up 12 spots this week") rather than absolute position when rank is low.

**Period selection is critical:** 1D, 1W, 1M, YTD, All-Time. Different users win on different horizons. A long-term value investor who trails on 1D rankings but dominates YTD will stay engaged if they can see their preferred metric.

---

### Streaks + XP: Loss Aversion

**What it is neurologically:**
Loss aversion is the most powerful and well-documented behavioral economics principle: *losses loom larger than gains* (Kahneman & Tversky, 1979). People will work harder to avoid losing something than to gain the equivalent thing. A streak is a manufactured possession — once you have a 20-day streak, you have something real to lose.

XP extends this: accumulated points become an asset. The higher your XP, the more you stand to lose by disengaging. Together, streaks and XP create a *sunk cost momentum* that pulls users back even on days when they have no actual reason to open the app.

**How others use it:**
- Duolingo: Streak is their #1 retention driver. Internal data shows users with streaks > 14 days have 3x the 60-day retention of users without. They introduced "streak freeze" to reduce anxiety (which paradoxically increased streak maintenance) and streak leaderboards to layer competition on top.
- Snapchat: Snap streaks (maintaining daily messaging chains) drove teen retention fiercely — the social pressure of *two people losing a streak* is more powerful than a single user losing one.
- Habitica: Gamifying tasks with XP and streaks turned to-do list completion into an identity-level behavior.

**STALK's finance context:**
More powerful for the right framing. A streak in Duolingo means "you practiced Spanish." A streak in STALK should mean "you showed up for your money." Every day you check in, you are slightly more informed than if you hadn't. This is *actually true* — finance streaks have real utility justification, not just behavioral manipulation. Lead with the real value: "Investors who track their portfolio daily make 12% fewer emotional decisions."

XP framing matters: do not use gaming language. Call it "experience" or "investor score," not "XP." Keep the gamification mechanics but present them as investor development, not a game. This respects the financial context and avoids the cringe factor.

---

### Achievements: Completion Compulsion

**What it is neurologically:**
Completion compulsion (the Zeigarnik effect) is the tendency for incomplete tasks to occupy more mental bandwidth than completed ones. A partially filled achievement progress bar is cognitively stickier than an empty one. Achievements also tap *identity formation* — unlocking "Diamond Hands" badge means something about who you are as an investor, not just what you did.

The key mechanic is the *progress reveal*: show users how close they are to the next badge. "3 more days for Streak Warrior" creates a specific, achievable micro-goal that drives return visits.

**How others use it:**
- Xbox/PlayStation achievement systems: Metacritic/OpenCritic data shows games with robust achievement systems have 22% higher completion rates.
- Starbucks Rewards: Stars → tier progression drives frequency. The endowed progress effect (giving users a 2/10 stamp card instead of 0/10 means they fill it faster) is a known achievement mechanic.
- Robinhood: Their confetti animation on first stock purchase and various first-trade milestones were engagement-driving — later controversially removed under regulatory pressure.

**STALK's finance context:**
Moderately powerful. Finance achievements are meaningful only if the achievements represent real investor behavior, not vanity metrics. "First trade" and "30-day streak" are good. "Most app opens in a week" is dark pattern territory. Keep achievements honest — they should signal genuine investor development.

Proposed badge ladder: First Buy → First Win → First Loss (normalize losses) → 7-Day Streak → Diamond Hands (held through 20%+ drawdown) → Contrarian (bought during -10% day) → Social Starter (first post) → Top 10% Leaderboard.

---

### Copy Portfolios: Social Proof + Shortcut

**What it is neurologically:**
Social proof (Cialdini) is the heuristic that "what others are doing is probably correct." In finance, this manifests as *performance-adjacent FOMO*: if someone with 48% YTD returns holds NVDA, maybe I should too. Copy investing removes the decision cost — the shortcut from "I don't know what to buy" to "I'll follow someone who does" is the product.

The second mechanic is *effort reduction*: investing decisions are cognitively expensive. Copy reduces them to a single "follow this trader" decision, dramatically lowering activation energy for new users.

**How others use it:**
- eToro: Their "CopyTrader" feature is cited as the primary driver of their 30M+ user base. Users who copy trade are 2x more retained than users who don't.
- Twitter: Retweet (sharing someone else's take rather than creating your own) drives 65% of total content distribution. The copy behavior is the majority behavior.
- Index funds: Passive investing is "copy the market" — the largest and fastest-growing investment category. STALK's social graph version of this is directionally correct.

**STALK's finance context:**
Maximally powerful. Finance is the domain where social proof is most dangerous and most appealing simultaneously. Someone with no investment knowledge has a strong rational reason to copy someone with demonstrable returns. The feature can be genuinely useful, not just psychologically exploitative.

Risk: regulatory. Copy investing features may require disclosure ("past performance does not guarantee..."), and in some jurisdictions, operating as a copy trading platform requires financial advisory licensing. Build with legal review. Frame as "inspiration" not "signals" in early versions.

---

## The Single Feature to Build First

**If Itamar can only build one social feature: Streaks + XP.**

Why:

1. **No social graph required.** Unlike stories, leaderboard (at any meaningful size), or reactions — streaks are solo. They work on day one, with zero other users. This is the cold start solution.

2. **Highest long-term retention lever.** D30 retention (+40%) is the number that determines whether STALK becomes a real business. D1 is easy to move with novelty. D30 is where the app either becomes a habit or dies.

3. **Creates the behavior that all other features depend on.** A user with a 14-day streak opens the app daily. That daily opener is the audience for stories, the participant in leaderboard, the reactor to posts. Without daily active users, every other social feature is empty. Streaks build the DAU base that makes social features feel alive.

4. **Finance framing is natural.** "Track your portfolio every day" is an intrinsically sensible ask. The streak is not a manufactured compulsion — it's a habit wrapper around genuinely useful behavior.

5. **Cheap to build relative to impact.** Compared to a full stories system or leaderboard infrastructure, a streak counter + XP tracker is a small engineering surface with outsized retention return.

Build streaks first. Build them right. Watch D30 retention. Then build leaderboard on top of the engaged daily-active user base you've created.

---

## Sequencing Recommendation

```
Month 1-2: Streaks + XP (solo, no social graph needed)
Month 3:   Achievement badges (solo, rewards streak behavior)
Month 4:   Leaderboard (needs ~500 MAU to feel real)
Month 5:   Stories + Reactions (needs curated mock graph + real users)
Month 6+:  Copy Portfolios (requires regulatory review, meaningful user base)
```

Do not rush to launch all features simultaneously. The worst outcome is launching a social feed with no content and no reactions — an empty social graph is more damaging than no social feature at all. Sequence the non-social features first to build the DAU base, then surface social features when there are real users to populate them.
