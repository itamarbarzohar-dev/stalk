# STALK — Shared Agent Context

## What is STALK
STALK is a native iOS portfolio tracking app for retail investors. It combines live portfolio P&L, AI-powered market context personalized to your holdings, gamified engagement mechanics (Portfolio Health Score, streaks, ATH alerts), and a social feed. Target user: the engaged retail investor who checks their portfolio multiple times a day. Priced at $6.99/mo. Pre-launch, 0 users, 0 revenue.

## Paths
- Project root: `/Users/itamarbarzohar/Desktop/STALK`
- Xcode project: `/Users/itamarbarzohar/Desktop/STALK/STALK.xcodeproj`
- Agents dir: `/Users/itamarbarzohar/Desktop/STALK/agents`
- GitHub: `git@github.com:itamarbarzohar-dev/stalk.git`

## How to Start Every Session
1. Read `../COMPANY_STATE.md` — single source of truth for current state
2. Read `../tasks/[YOUR_AGENT]_*` — your pending tasks
3. Read `../reports/` — what was done recently
4. Take action. Write outputs. Update state.

## Shared Constraints — All Agents
- NEVER push directly to `main` — always branch + PR
- NEVER submit to App Store without explicit approval from Itamar (the founder)
- NEVER make StoreKit purchases live without App Store Connect products created
- NEVER start P2 features (social/backend) before P1 features are complete and App Store is live
- Itamar must personally approve any public distribution, pricing change, or external TestFlight release

## Current Stage
Pre-launch. App is feature-complete for v1. Blocked on Apple Developer Program enrollment (Itamar's action). Revenue: $0. Users: 0.

## Key Decisions (Do Not Revisit)
- **AI**: BYOK via Keychain, `claude-haiku-4-5`, no backend proxy
- **Backend**: None for v1. Supabase for v1.1, 30 days post-launch.
- **Monetization**: Freemium subscription ($6.99/mo or $59.99/yr) + broker affiliate. No ads.
- **Social**: Mock data for v1. Real social requires backend (v1.1).
- **Pricing**: $6.99/mo, $59.99/yr with 7-day free trial. Do not change.
