# CEO Log — Alex

---

## Session: 2026-06-09

### What I read

- `COMPANY_STATE.md` — full read. App is built, 0 users, pre-launch. Key gaps: no BYOK AI, no price alert UI, no backend, no design system, no finalized business model.
- All existing task files: iOS_PAYWALL_GATE (DONE), iOS_PUSH_NOTIFICATIONS (DONE), iOS_APP_ICON_AND_LAUNCH_SCREEN (DONE).
- `ios_dev_log.md` — Jordan's work log. Confirmed: PriceAlertThreshold model exists, no UI. Onboarding, notifications, StoreKit, paywall all shipped.
- `ceo_log.md` and `cto_decisions.md` — both empty at session start.

### State of the company at session open

Strong foundation: app compiles, runs in simulator, has onboarding, paywall code, local push notifications, portfolio tracking, social feed UI, For You tab, Daily Brief, FOMO cards, AI chat (mocked), market view. The bones are solid.

Critical gaps blocking launch:
1. AI chat is mocked — no real API calls. This will destroy credibility in any review or demo.
2. Price alert UI doesn't exist despite the model being built. Users have no way to set thresholds.
3. No design system or UX coherence — each screen was built by an engineer, not a designer.
4. Business model is assumed (subscription) but never formally analyzed or compared against alternatives.
5. Backend architecture undecided — every week without this decision creates tech debt.

New team member: Luna (UX Designer) joined. First substantive work assigned today.

### Decisions made this session

**No decisions that require Itamar's approval were made.** All tasks are build/analyze work.

I did make the following tactical calls on behalf of the company:
- Chose `claude-3-5-haiku-20241022` as the default model for BYOK AI (fast, cheap for users; can upgrade to Opus for Pro users later). This is a product default, not a hard commitment.
- Chose BYOK (Bring Your Own Key) over "we host an API key" — this is the right call for v1: zero server cost, zero liability, users who care about AI will have Anthropic accounts.
- Assigned Luna her first task as a full screen-by-screen audit with exact design tokens required — not vague inspiration. Set the standard high.

### Tasks filed

| Task File | Assigned | Priority |
|-----------|----------|----------|
| `CRO_BUSINESS_MODEL_ANALYSIS_2026-06-09.md` | Rex | HIGH |
| `CPO_BUSINESS_MODEL_INPUT_2026-06-09.md` | Sam | HIGH |
| `UX_FULL_AUDIT_2026-06-09.md` | Luna | HIGH |
| `iOS_BYOK_AI_2026-06-09.md` | Jordan | HIGH |
| `iOS_PRICE_ALERT_UI_2026-06-09.md` | Jordan | HIGH |
| `CTO_BACKEND_DECISION_2026-06-09.md` | Maya | HIGH |

### What I'm watching

1. **Luna's design system** — this is the highest leverage output of the sprint. If she delivers exact hex/animation specs, Jordan can apply them to both the price alert UI and the AI chat in the same sprint. Coordination matters here.

2. **Rex vs. Sam on business model** — Rex will optimize for revenue math, Sam will optimize for product health. The tension between them should produce the right answer. If they converge on subscription, great. If they disagree, I'll make the call and surface it to Itamar.

3. **Maya's backend call** — I expect her to recommend "local-only for v1, Supabase for v2." That's the safe call. If she recommends something more aggressive (Firebase now, before launch), I want to see the cost model before agreeing.

4. **Jordan has two tasks** — BYOK AI and Price Alert UI are independent (no shared files) and can be done in parallel PRs. Both should be on separate feature branches.

### What needs Itamar's input (no action from agents)

- Apple Developer Program enrollment ($99) — literally cannot list on App Store without it
- Backend budget approval — even Supabase free tier has limits; need to know if there's a budget
- App icon — placeholder is embarrassing. Luna can spec the design, but execution needs a tool or a hire
- Target market — Israel first changes positioning, pricing, and localization needs

### Next session priorities

Once this sprint's tasks come back:
1. Review Luna's design system and have Jordan apply it
2. Synthesize Rex + Sam business model outputs into a final recommendation for Itamar
3. Review Maya's backend decision and flag any cost/complexity concerns to Itamar
4. If Itamar has enrolled in Apple Developer: file App Store submission checklist task

---

## Session: 2026-06-09 (Session 2)

### Opening state

Good progress from Session 1. Jordan shipped BYOK AI and price alert UI. Luna completed the UX audit. Rex and Sam converged on a business model: **freemium subscription + broker affiliate**. Dark mode was broken (tab bar invisible) — Jordan fixed it. App is in a strong state heading into this session.

What Session 1 built:
- Real Claude AI wired via BYOK + Keychain
- Price alert threshold UI per stock
- Full UX design system with exact hex/animation specs from Luna
- Business model locked: freemium sub + broker affiliate referrals
- Dark mode: tab bar now visible in dark mode (Jordan's fix)

### Directives received from Itamar

1. Fix dark mode (tab bar invisible) — confirmed fixed by Jordan
2. Make the app more addictive
3. Add all features available in Perplexity Finance
4. Agents should work on the business model

### What I did this session

**1. Updated COMPANY_STATE.md**
- Marked BYOK AI, price alert UI, and dark mode as Done
- Added 5 in-progress features: Sector Heat Map, AI Market Context, Portfolio Health Score, Earnings Calendar, Trending Tickers
- Updated sprint goals to reflect Perplexity Finance integration directive
- Cleaned up blockers (BYOK blocker resolved)
- Updated last agent activity log

**2. Created feature_backlog.md**
Full prioritized product roadmap filed at `agents/memory/product/feature_backlog.md`.

Key decisions embedded in the backlog:
- **42 features** cataloged across P0/P1/P2
- **P0 (12 features):** All done or in progress — this is the launch-ready core
- **P1 (16 features):** The addictiveness engine. Targets daily habit formation through variable reward, progress loops, social proof, and anticipation.
- **P2 (14 features):** Moat-builders. Social graph, broker integrations, options data, tax tools.

**Perplexity Finance parity:** Mapped all Perplexity Finance features to STALK equivalents. We match everything they do (all planned or in progress) and have 5 structural advantages they cannot replicate: portfolio-aware AI, gamification layer, native iOS UX, freemium model, and broker affiliate monetization.

**Addictiveness design principles documented** — 7 psychological mechanisms that drive daily opens: variable reward, progress/score, loss aversion, social proof, anticipation loops, morning ritual anchoring, AI as companion.

### Decisions made this session

- **Business model is locked:** Freemium subscription + broker affiliate. No further analysis needed. Rex should now focus on execution — identify which brokers to partner with first (Robinhood, IBKR, Tastytrade), draft referral CTA copy, spec the in-app placement.
- **Sprint 2 focus is addictiveness:** The 5 in-progress features (Heat Map, AI Context, Health Score, Earnings Calendar, Trending) are the right first wave. Each one targets a distinct retention mechanism.
- **No new backend work this sprint:** Maya's backend decision stands. We build on local-first for now; social features and cross-device sync wait until post-launch signal justifies the infra cost.

### What I'm watching

1. **Portfolio Health Score** — highest leverage of the 5 new features. A score users can improve is a game. A game users play daily. Jordan needs to get the scoring algorithm right — it cannot feel arbitrary. Penalize concentration, reward diversification, reward long-term holding. Make the maximum score feel achievable but require work.

2. **Earnings Calendar accuracy** — if we show wrong earnings dates, users will uninstall. This needs a reliable data source. Jordan needs to flag the data provider decision before building.

3. **Rex on broker affiliate** — the business model is decided but the execution is not. Who do we partner with first? What's the referral fee structure? Where does the CTA live in the app? This is revenue-path-critical and I want a concrete plan this sprint.

4. **Feature creep risk** — Perplexity Finance has a lot of features. We should not build all 42 features before launch. The goal is: launch with P0 complete + the 5 current P1 features shipping. That's a strong v1. Everything else is post-launch.

### What needs Itamar's input (no action from agents)

- Apple Developer Program enrollment — still blocked. This is the single longest-lead-time item for launch.
- Which broker affiliate partners to pursue first — Itamar may have preferences or existing relationships
- App icon — Luna has the spec, but execution (design tool, hire, or AI generation) is a founder call
- Launch timing — do we launch with this feature set or wait for more P1 features?

### Next session priorities

1. Review Jordan's 5 in-progress features — ship them, verify quality
2. Get Rex's broker affiliate execution plan — concrete partner targets and CTA spec
3. Surface a launch readiness checklist to Itamar once the 5 features are done
4. Begin App Store listing preparation (screenshots, copy) so it's ready the moment Apple Dev account is active

---
