# STALK — Company State
> Last updated: 2026-06-09
> This file is the single source of truth. Every agent reads and writes here.

## 🎯 Mission
Build STALK into the most addictive and powerful personal stock portfolio tracking app for iOS — from 0 to App Store launch and beyond.

## 📍 Current Stage
**Stage: Early Product Development**
- SwiftUI app is built and running locally
- Core features: portfolio tracking, AI agent card, market view, social feed, For You tab
- Not yet on App Store
- 0 users (pre-launch)

## ⚠️ FOUNDER DIRECTIVE — READ BEFORE ANY ACTION
**Itamar (founder) must personally approve any App Store submission, launch, or public distribution.**
- Do NOT submit to App Store without explicit approval from Itamar
- Do NOT push to TestFlight externally without approval
- Do NOT make any pricing or monetization live without approval
- Build, test, and prepare — but always stop short of actual launch and flag for review

## 🏗️ Product Status
| Feature | Status |
|---------|--------|
| Portfolio tracking | ✅ Done |
| Market view | ✅ Done |
| Social feed | ✅ Done |
| For You tab | ✅ Done |
| Daily Brief | ✅ Done |
| AI Agent card | ✅ Done |
| Live Feed card | ✅ Done |
| FOMO features | ✅ Done |
| StoreKit paywall (code) | ✅ Done |
| Onboarding flow | ✅ Done |
| Push notifications (local) | ✅ Done |
| App icon (placeholder) | ✅ Done (needs designer) |
| Privacy policy page | ✅ Done (GitHub Pages) |
| App Store listing | 🔴 Blocked — needs Apple Dev account |
| Backend/API | ❌ Not started |
| User auth | ❌ Not started |
| Social features (real) | ❌ Not started |
| Price alert threshold UI | ❌ Not started |
| Real AI API (BYOK) | ❌ Not started |
| Bundle ID change | ❌ Not started (ITAMARAZI.STALK → com.itamar.stalk) |

## 🎯 Current Sprint Goals (2026-06-09)
1. Wire real Claude API in AI chat (BYOK — Keychain) [Jordan — tasks/iOS_BYOK_AI_2026-06-09.md]
2. Build price alert threshold UI per stock [Jordan — tasks/iOS_PRICE_ALERT_UI_2026-06-09.md]
3. Full UX audit + futuristic design system — exact hex/px specs per screen [Luna — tasks/UX_FULL_AUDIT_2026-06-09.md]
4. Business model deep-dive — analyze ALL monetization models, pick one [Rex — tasks/CRO_BUSINESS_MODEL_ANALYSIS_2026-06-09.md]
5. Product perspective on business model [Sam — tasks/CPO_BUSINESS_MODEL_INPUT_2026-06-09.md]
6. Backend architecture final decision [Maya — tasks/CTO_BACKEND_DECISION_2026-06-09.md]
7. Fix bundle ID to com.itamar.stalk [blocked until Apple Dev account confirmed]
8. Wait for Itamar to enroll in Apple Developer Program ($99/yr)

## 📊 Key Metrics
- Revenue: $0
- Users: 0 (pre-launch, founder review mode)
- App Store: Not listed
- GitHub: public, collaborator added (razinskymaayan-crypto)

## 🧠 Strategic Priorities (This Quarter)
1. Founder approval of product
2. Apple Developer Account enrollment (Itamar's action)
3. App Store launch (after approval)
4. First 100 users

## 📝 Open Decisions (Pending Itamar)
- Apple Developer Account: enroll at developer.apple.com ($99/yr)
- Backend: Firebase vs Supabase vs nothing for v1?
- Target market: Israel first or global?
- App icon: designer / Figma / hire?
- Bundle ID confirmation: com.itamar.stalk

## 🚧 Blockers
- App Store submission blocked until Itamar enrolls in Apple Developer Program
- Real StoreKit purchases blocked until App Store Connect products created
- Real AI API calls blocked until BYOK flow is implemented

## 📅 Last Agent Activity
- 2026-06-09: CEO Alex opened sprint — 6 tasks filed for Rex, Sam, Luna, Jordan (x2), Maya
- 2026-06-09: CRO Rex completed full business model analysis (7 models) + revenue recommendation — see agents/memory/revenue/
- 2026-06-09: Build fixed (isPro, aiMessagesUsed, StoreKit added to AppState) — app running in simulator
- 2026-06-08: iOS Dev Jordan completed onboarding, push notifications, paywall task, launch screen, privacy policy
- 2026-06-08: CRO Rex defined monetization strategy and paywall spec
- 2026-06-08: razinskymaayan-crypto added as GitHub collaborator
