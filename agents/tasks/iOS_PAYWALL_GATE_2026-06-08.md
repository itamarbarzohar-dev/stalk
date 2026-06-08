# Task: Implement STALK Pro Paywall — StoreKit + Gates
**Assigned to:** iOS Dev Jordan
**Priority:** P0 — BLOCKING App Store submission
**Due:** 2026-06-12 (4 days)
**From:** Rex (CRO)
**Status:** DONE — 2026-06-08 (Jordan)

---

## Context

Read `agents/memory/revenue/paywall_spec.md` before starting. This task is the full spec. What follows here is the prioritized implementation order and specific file-level instructions.

The `PremiumSheet` exists. `isPro` does not yet exist. `StoreKit` is not integrated. Without this task, STALK ships with a broken "Start Free Trial" button and zero revenue potential.

**Do NOT submit to App Store until this task is complete.**

---

## Step 1: App Store Connect Setup (Prerequisite — Itamar's action)

Before writing any code, the subscription products must exist in App Store Connect. Jordan: flag this to Itamar.

Products to create:
- Product ID: `com.itamar.stalk.pro.monthly` | Auto-renewable | $6.99/mo | Group: "STALK Pro"
- Product ID: `com.itamar.stalk.pro.annual` | Auto-renewable | $49.99/yr | Group: "STALK Pro"
- Free trial: 7 days on both products

Until products exist in App Store Connect, create a local `StoreKit.storekit` configuration file for testing (Xcode → File → New → StoreKit Configuration File).

---

## Step 2: AppState Changes

**File:** `AppState.swift`

### 2a: Add to `STALKSettings`

```swift
var isPro: Bool = false
var aiMessagesUsed: Int = 0
var priceAlertCount: Int = 0
```

### 2b: Add to `AppState`

```swift
import StoreKit

var storeKitProducts: [Product] = []

func loadStoreKitProducts() async {
    do {
        storeKitProducts = try await Product.products(for: [
            "com.itamar.stalk.pro.monthly",
            "com.itamar.stalk.pro.annual"
        ])
    } catch {
        print("StoreKit product load failed: \(error)")
    }
}

func purchaseProduct(_ product: Product) async -> Bool {
    do {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                settings.isPro = true
                saveSettings()
                return true
            case .unverified:
                return false
            }
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    } catch {
        print("Purchase failed: \(error)")
        return false
    }
}

func restorePurchases() async {
    for await result in Transaction.currentEntitlements {
        if case .verified(let transaction) = result {
            if transaction.productID == "com.itamar.stalk.pro.monthly" ||
               transaction.productID == "com.itamar.stalk.pro.annual" {
                if transaction.revocationDate == nil {
                    settings.isPro = true
                    saveSettings()
                    return
                }
            }
        }
    }
    // No active subscription found
    settings.isPro = false
    saveSettings()
}

func listenForTransactions() {
    Task {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                if transaction.productID == "com.itamar.stalk.pro.monthly" ||
                   transaction.productID == "com.itamar.stalk.pro.annual" {
                    let isActive = transaction.revocationDate == nil &&
                                   (transaction.expirationDate ?? .distantFuture) > Date()
                    settings.isPro = isActive
                    saveSettings()
                }
                await transaction.finish()
            }
        }
    }
}
```

### 2c: Call in `STALKApp`

```swift
.task {
    await appState.loadStoreKitProducts()
    appState.listenForTransactions()
    await appState.restorePurchases() // verify subscription status on every launch
}
```

---

## Step 3: Fix PremiumSheet

**File:** `ForYouView.swift` → `PremiumSheet` struct

### Changes required:

1. **Add state:**
```swift
@Environment(AppState.self) var appState
@State private var selectedPlan: String = "annual"
@State private var isPurchasing = false
@State private var showError = false
```

2. **Replace the hardcoded price section** with a plan selector:
```swift
// Annual option (pre-selected)
Button { selectedPlan = "annual" } label: {
    HStack {
        VStack(alignment: .leading) {
            Text("Annual")
                .font(.system(size: 16, weight: .black))
            Text("$49.99/yr · $4.16/month · Save 40%")
                .font(.system(size: 12))
                .foregroundStyle(Theme.text3)
        }
        Spacer()
        if selectedPlan == "annual" {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.accent)
        }
    }
    .padding(16)
    .background(selectedPlan == "annual" ? Theme.accentColor.opacity(0.08) : Theme.bg2)
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .overlay(RoundedRectangle(cornerRadius: 14).stroke(selectedPlan == "annual" ? Theme.accent : Color.clear, lineWidth: 2))
}

// Monthly option
Button { selectedPlan = "monthly" } label: {
    HStack {
        Text("Monthly")
            .font(.system(size: 16, weight: .black))
        Spacer()
        Text("$6.99/mo")
            .font(.system(size: 14))
            .foregroundStyle(Theme.text3)
    }
    .padding(16)
    .background(selectedPlan == "monthly" ? Theme.accentColor.opacity(0.08) : Theme.bg2)
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .overlay(RoundedRectangle(cornerRadius: 14).stroke(selectedPlan == "monthly" ? Theme.accent : Color.clear, lineWidth: 2))
}
```

3. **Wire the CTA button:**
```swift
Button {
    isPurchasing = true
    Task {
        let productID = selectedPlan == "annual"
            ? "com.itamar.stalk.pro.annual"
            : "com.itamar.stalk.pro.monthly"
        if let product = appState.storeKitProducts.first(where: { $0.id == productID }) {
            let success = await appState.purchaseProduct(product)
            if success { dismiss() }
            else { showError = true }
        }
        isPurchasing = false
    }
} label: {
    if isPurchasing {
        ProgressView().tint(.white)
    } else {
        Text("Start 7-Day Free Trial →")
    }
}
```

4. **Add Restore Purchases button:**
```swift
Button("Restore Purchases") {
    Task { await appState.restorePurchases() }
}
.font(.system(size: 13))
.foregroundStyle(Theme.text3)
```

5. **Add legal footer text:**
```swift
Text("7-day free trial. Payment charged to your Apple ID at end of trial. Cancel anytime in Settings > Subscriptions.")
    .font(.system(size: 10))
    .foregroundStyle(Theme.text3)
    .multilineTextAlignment(.center)
    .padding(.horizontal, 22)
```

6. **Use StoreKit prices (not hardcoded strings).** Load price from `appState.storeKitProducts`. Fall back to hardcoded only if products not loaded.

---

## Step 4: AI Chat Gate

**File:** `AIFullChatView.swift`

### Add state:
```swift
@State private var showPaywall = false
```

### Modify `sendMessage()`:
```swift
func sendMessage(_ text: String) {
    let trimmed = text.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty, !isThinking else { return }
    
    // Pro gate: 3 free messages lifetime
    if !appState.settings.isPro {
        if appState.settings.aiMessagesUsed >= 3 {
            showPaywall = true
            return
        }
        appState.settings.aiMessagesUsed += 1
        appState.saveSettings()
    }
    
    messages.append(.init(role: .user, text: trimmed))
    input = ""
    isThinking = true
    // ... rest of existing logic
}
```

### Add paywall sheet trigger:
```swift
.sheet(isPresented: $showPaywall) {
    PremiumSheet()
}
```

### Add "1 question remaining" hint when `aiMessagesUsed == 2`:
Show a subtle banner above the input bar:
```swift
if !appState.settings.isPro && appState.settings.aiMessagesUsed == 2 {
    Text("1 free question remaining — Upgrade for unlimited analysis")
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(.white.opacity(0.6))
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#7B6FEF").opacity(0.25))
}
```

---

## Step 5: Premium Themes Gate

**File:** `SettingsView.swift` → `appearanceSection()`

The theme picker is a `LazyVGrid` of `Button`. Modify each button's action:

```swift
let proThemes: Set<String> = ["gold", "midnight"]

Button {
    if proThemes.contains(t.rawValue) && !appState.settings.isPro {
        showPremium = true
        return
    }
    appState.settings.theme = t.rawValue
    appState.saveSettings()
} label: {
    Circle()
        .fill(t.gradient)
        .frame(width: 48, height: 48)
        .overlay(
            Group {
                if proThemes.contains(t.rawValue) && !appState.settings.isPro {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(.white)
                        .opacity(selected ? 1 : 0)
                }
            }
        )
        .opacity(proThemes.contains(t.rawValue) && !appState.settings.isPro ? 0.6 : 1.0)
}
```

`showPremium` state var already exists in `SettingsView`.

---

## Step 6: Onboarding Paywall Screen (Screen 5)

**File:** `OnboardingFlowView.swift`

Add a 5th screen at the end of the onboarding flow. Show it only if: `appState.positions.count > 0 && notificationsGranted`.

The screen should use the same `PremiumSheet` as a condensed version, or a purpose-built `OnboardingPaywallView`. See `paywall_spec.md` Screen 5 wireframe for layout.

Key requirements:
- CTA: "Start Free Trial →" (wires to StoreKit, same as PremiumSheet)
- "Skip for now" link: calls `completeOnboarding()`, does not show again
- No "Back" button on this screen

---

## Step 7: isPro Toggle in Settings (for testing)

**File:** `SettingsView.swift` → `aboutSection()`

Replace the existing "Upgrade to Pro" row with a dynamic display:

```swift
if appState.settings.isPro {
    // Show Pro status
    HStack {
        Text("⭐").font(.system(size: 20)).frame(width: 32)
        VStack(alignment: .leading, spacing: 2) {
            Text("STALK Pro — Active")
                .font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.gain)
            Text("Thanks for supporting STALK!")
                .font(.system(size: 11)).foregroundStyle(Theme.text3)
        }
        Spacer()
        Text("PRO")
            .font(.system(size: 12, weight: .black))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(appState.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding(.vertical, 14)
} else {
    Button { showPremium = true } label: {
        // existing "Upgrade to Pro" row
    }
}
```

---

## Definition of Done

- [ ] StoreKit configuration file created for local testing
- [ ] `isPro`, `aiMessagesUsed`, `priceAlertCount` added to `STALKSettings`
- [ ] `loadStoreKitProducts()`, `purchaseProduct()`, `restorePurchases()`, `listenForTransactions()` implemented in `AppState`
- [ ] `STALKApp` calls `loadStoreKitProducts()` and `listenForTransactions()` on launch
- [ ] `PremiumSheet` shows annual/monthly plan selector with real StoreKit prices
- [ ] `PremiumSheet` CTA actually initiates purchase, shows loading state
- [ ] `PremiumSheet` has Restore Purchases button
- [ ] `PremiumSheet` has required App Store legal footer
- [ ] AI Chat gate: 3 free messages, paywall on 4th attempt
- [ ] AI Chat hint shown at 2 messages used
- [ ] Gold + Midnight themes show lock icon and trigger paywall for free users
- [ ] Onboarding Screen 5 (paywall) built and triggered correctly
- [ ] `aboutSection()` in Settings shows Pro status if subscribed
- [ ] All gates bypass correctly when `isPro == true`
- [ ] Build compiles, tested manually in StoreKit sandbox
- [ ] PR: `feature/pro-paywall`

---

## Testing Notes

Use Xcode's StoreKit sandbox to test without real purchases:
- Product → Scheme → Edit Scheme → Run → StoreKit Configuration → select your `.storekit` file
- Use `StoreKit Test` product IDs that match your configuration
- Test: purchase, cancel, restore, expiry, grace period

**Do NOT test with real purchases in production until App Store review is complete.**
