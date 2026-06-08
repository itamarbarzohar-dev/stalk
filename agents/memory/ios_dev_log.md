# iOS Dev Log — Jordan

## 2026-06-08 — Paywall + StoreKit Implementation (feature/paywall-storekit)

### Summary
Implemented full monetisation system for STALK Pro. All gates live, StoreKit 2 wired, PremiumSheet rebuilt.

### Changes

**AppState.swift**
- Added `isPro: Bool`, `aiMessagesUsed: Int`, `priceAlertCount: Int` to `STALKSettings`
- Added `storeKitProducts: [Product]` to `AppState`
- Implemented `loadStoreKitProducts()` — fetches monthly + annual products from StoreKit
- Implemented `purchaseProduct(_ product: Product) async -> Bool` — StoreKit 2 purchase flow, sets `isPro = true` on verified success
- Implemented `restorePurchases()` — checks `Transaction.currentEntitlements`, sets isPro accordingly
- Implemented `listenForTransactions()` — real-time subscription status updates via `Transaction.updates`

**STALKApp.swift**
- Added `.task` on launch: loads products, starts transaction listener, restores purchases

**ForYouView.swift (PremiumSheet)**
- Full rewrite: dark indigo/purple gradient header, STALK Pro branding
- Feature list: 5 items with icons and descriptions
- Annual/monthly plan selector (annual pre-selected, highlighted, "BEST VALUE" badge)
- Prices pulled from StoreKit `Product.displayPrice`, fallback to hardcoded strings
- CTA: "Start 7-Day Free Trial" with loading spinner during purchase
- Error alert on purchase failure, success alert + auto-dismiss on success
- Restore Purchases + "Maybe later" links
- Trust signals: 256-bit encryption / App Store verified
- Required App Store legal footer

**AIFullChatView.swift**
- Added `showPaywall: Bool` state
- Added `proGateHint()` — subtle banner when `aiMessagesUsed == 2` ("1 free question remaining")
- `sendMessage()` gated: free users get 3 lifetime messages, 4th attempt shows `PremiumSheet`
- Sheet: `.sheet(isPresented: $showPaywall) { PremiumSheet() }`

**SettingsView.swift**
- `appearanceSection()`: gold + midnight themes show lock icon and trigger paywall for free users
- `aboutSection()`: dynamic display — Pro status row if subscribed, "Upgrade to Pro" button otherwise

**StoreKit.storekit**
- New sandbox configuration file for local testing
- Products: `com.itamar.stalk.pro.monthly` ($6.99/mo, 7-day trial) and `com.itamar.stalk.pro.annual` ($49.99/yr, 7-day trial)
- Group: "STALK Pro"
- To activate: Xcode → Edit Scheme → Run → StoreKit Configuration → StoreKit.storekit

### Build Status
BUILD SUCCEEDED (2026-06-08). Pre-existing warnings in QuoteService.swift (Swift 6 actor isolation) — not introduced by this PR.

### Action Required — Itamar
Create products in App Store Connect before TestFlight:
- `com.itamar.stalk.pro.monthly` | Auto-renewable | $6.99/mo | Group: STALK Pro | 7-day free trial
- `com.itamar.stalk.pro.annual` | Auto-renewable | $49.99/yr | Group: STALK Pro | 7-day free trial

---
