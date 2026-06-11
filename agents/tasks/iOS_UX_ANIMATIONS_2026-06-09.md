# iOS UX Animations — Implementation Task
**Author:** Luna (UX Designer)
**Assignee:** Jordan (iOS Dev)
**Date:** 2026-06-09
**Priority:** High
**Estimated effort:** 4–6 hours

---

## Context

This task upgrades STALK's visual feel from "solid" to "premium." The goal is Bloomberg Terminal precision meets Nothing Phone motion. Every change here is value-driven animation — no timers, no particle effects, nothing gratuitous. Just numbers that roll and cards that land.

Reference specs in:
- `/agents/memory/design/portfolio_hero_v2.md`
- `/agents/memory/design/number_animations.md`
- `/agents/memory/design/card_stagger.md`
- `/agents/memory/design/perplexity_features.md`

---

## Task 1: Add `AnimatedPrice` Component

**File to create:** `STALK/AnimatedPrice.swift`

```swift
import SwiftUI

struct AnimatedPrice: View {
    let value: Double
    let format: (Double) -> String
    @State private var displayed: Double

    init(value: Double, format: @escaping (Double) -> String) {
        self.value = value
        self.format = format
        self._displayed = State(initialValue: value)
    }

    var body: some View {
        Text(format(displayed))
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(
                .spring(response: 0.4, dampingFraction: 0.8),
                value: displayed
            )
            .onChange(of: value) { _, newValue in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    displayed = newValue
                }
            }
    }
}
```

**Testing:** Add a preview with a Button that increments a value. Confirm digits roll smoothly with no layout shift.

---

## Task 2: Upgrade `PortfolioHero` in `PortfolioView.swift`

### 2a. Total value number

Replace:
```swift
Text(appState.totalValue.fmtPrice())
    .font(.system(size: 44, weight: .heavy))
    .foregroundStyle(.white)
    .minimumScaleFactor(0.5)
```

With:
```swift
AnimatedPrice(value: appState.totalValue) { $0.fmtPrice() }
    .font(.system(size: 48, weight: .black))
    .foregroundStyle(.white)
    .minimumScaleFactor(0.5)
    .animation(.spring(response: 0.5, dampingFraction: 0.75), value: appState.totalValue)
```

### 2b. P&L row — split the single capsule into two elements

Replace:
```swift
Text("\(isGain ? "+" : "")\(appState.totalPnl.fmtPrice())  \(appState.totalPnlPct.fmtPct())")
    .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
    .padding(.horizontal, 14).padding(.vertical, 6)
    .background(isGain ? .white.opacity(0.2) : Color(hex: "#E5534B").opacity(0.35))
    .clipShape(Capsule())
    .padding(.top, 10)
```

With:
```swift
HStack(spacing: 8) {
    AnimatedPrice(value: appState.totalPnl) { v in
        (v >= 0 ? "+" : "") + v.fmtPrice()
    }
    .font(.system(size: 22, weight: .bold))
    .foregroundStyle(isGain ? Theme.gain : Theme.loss)
    .animation(.easeInOut(duration: 0.3), value: isGain)

    AnimatedPrice(value: appState.totalPnlPct) { $0.fmtPct() }
        .font(.system(size: 14, weight: .bold))
        .foregroundStyle(isGain ? Theme.gain : Theme.loss)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background((isGain ? Theme.gain : Theme.loss).opacity(0.15))
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.3), value: isGain)
}
.padding(.top, 8)
```

### 2c. Hero radial glow

In the `ZStack(alignment: .top)` of `PortfolioHero.body`, add BELOW `appState.heroGradient`:

```swift
appState.heroGradient

RadialGradient(
    colors: [
        Color(hex: "#5B5BD6").opacity(0.18),
        Color.clear
    ],
    center: .init(x: 0.35, y: 0.42),
    startRadius: 0,
    endRadius: 180
)
.blendMode(.screen)
.allowsHitTesting(false)
```

### 2d. Market status pill — glass treatment

Add `@State private var pulseScale: CGFloat = 1.0` to `PortfolioHero`.

Replace:
```swift
HStack(spacing: 6) {
    Circle().fill(marketStatus.dotColor).frame(width: 7, height: 7)
        .overlay(
            Circle().fill(marketStatus.dotColor.opacity(0.3))
                .frame(width: 13, height: 13)
                .opacity(marketStatus.isLive ? 1 : 0)
        )
    Text(marketStatus.label)
        .font(.system(size: 11, weight: .bold))
        .foregroundStyle(.white.opacity(0.9))
    Text("·")
        .foregroundStyle(.white.opacity(0.4))
        .font(.system(size: 11))
    Text(marketStatus.subtitle)
        .font(.system(size: 11))
        .foregroundStyle(.white.opacity(0.65))
}
.padding(.bottom, 14)
```

With:
```swift
HStack(spacing: 6) {
    ZStack {
        if marketStatus.isLive {
            Circle()
                .fill(marketStatus.dotColor.opacity(0.3))
                .frame(width: 14, height: 14)
                .scaleEffect(pulseScale)
                .animation(
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: pulseScale
                )
        }
        Circle()
            .fill(marketStatus.dotColor)
            .frame(width: 7, height: 7)
    }

    Text(marketStatus.label)
        .font(.system(size: 11, weight: .bold))
        .foregroundStyle(.white.opacity(0.9))

    Rectangle()
        .fill(.white.opacity(0.25))
        .frame(width: 1, height: 10)

    Text(marketStatus.subtitle)
        .font(.system(size: 11))
        .foregroundStyle(.white.opacity(0.6))
}
.padding(.horizontal, 12)
.padding(.vertical, 6)
.background(.white.opacity(0.08))
.clipShape(Capsule())
.overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
.padding(.bottom, 14)
.onAppear { pulseScale = 1.4 }
```

### 2e. ATH Badge

Add `@State private var athPulse: CGFloat = 1.0` to `PortfolioHero`.

Replace the `pill("🏆 NEW ATH!", "", ...)` call with:
```swift
HStack(spacing: 5) {
    Text("🏆")
        .font(.system(size: 12))
    Text("NEW ATH")
        .font(.system(size: 11, weight: .black))
        .foregroundStyle(Theme.gold)
        .kerning(0.5)
        .textCase(.uppercase)
}
.padding(.horizontal, 12)
.padding(.vertical, 6)
.background(Theme.gold.opacity(0.15))
.clipShape(Capsule())
.overlay(Capsule().stroke(Theme.gold.opacity(0.4), lineWidth: 1))
.scaleEffect(athPulse)
.animation(
    .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
    value: athPulse
)
.onAppear { athPulse = 1.04 }
```

### 2f. Streak Badge

Replace the `pill("Streak", "🔥 \(appState.streak)d", ...)` call with:
```swift
HStack(spacing: 5) {
    Text("🔥")
        .font(.system(size: 13))
    VStack(spacing: 0) {
        Text("\(appState.streak)d")
            .font(.system(size: 13, weight: .black))
            .foregroundStyle(.white)
        Text("Streak")
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(.white.opacity(0.7))
    }
}
.padding(.horizontal, 13)
.padding(.vertical, 7)
.background(
    LinearGradient(
        colors: [Color(hex: "#F97316"), Color(hex: "#EA580C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
)
.clipShape(RoundedRectangle(cornerRadius: 12))
.shadow(color: Color(hex: "#F97316").opacity(0.35), radius: 8, y: 3)
```

---

## Task 3: Add `StaggeredEntrance` ViewModifier

**File to create:** `STALK/StaggeredEntrance.swift`

```swift
import SwiftUI

struct StaggeredEntrance: ViewModifier {
    let index: Int
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 28)
            .animation(
                .spring(response: 0.45, dampingFraction: 0.75)
                    .delay(min(Double(index) * 0.06, 0.30)),
                value: appeared
            )
            .onAppear { appeared = true }
    }
}

extension View {
    func staggeredEntrance(index: Int) -> some View {
        modifier(StaggeredEntrance(index: index))
    }
}
```

### Apply in `PortfolioView.body`:

```swift
if !appState.positions.isEmpty {
    AIAgentCard()
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
        .staggeredEntrance(index: 0)

    VsMarketCard()
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
        .staggeredEntrance(index: 1)

    VsFriendsCard()
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
        .staggeredEntrance(index: 2)

    LiveFeedCard()
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
        .staggeredEntrance(index: 3)
}

PositionsList(onTicker: onTicker)
    .padding(.horizontal, 14)
    .staggeredEntrance(index: 4)
```

### Apply in `PositionsList`:

```swift
VStack(spacing: 10) {
    ForEach(Array(appState.positions.enumerated()), id: \.element.id) { i, position in
        PositionCard(position: position, onTap: { onTicker(position.ticker) })
            .staggeredEntrance(index: i)
    }
    // ...
}
```

---

## Task 4: `PositionCard` — animated values

In `PositionCard.body`, replace the right-side value/PnL `Text` views with `AnimatedPrice`:

```swift
VStack(alignment: .trailing, spacing: 3) {
    AnimatedPrice(value: value) { $0.fmtPrice() }
        .font(.system(size: 15, weight: .bold))
        .foregroundStyle(Theme.text)

    AnimatedPrice(value: pnl) { $0.fmtChange() }
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(isUp ? Theme.gain : Theme.loss)
        .animation(.easeInOut(duration: 0.3), value: isUp)

    if let q = quote {
        AnimatedPrice(value: q.changePercent) {
            "Today " + $0.fmtPct()
        }
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(dayIsUp ? Theme.gain : Theme.loss)
        .animation(.easeInOut(duration: 0.3), value: dayIsUp)
    }
}
```

---

## Task 5: Wrap `AppState` mutations in `withAnimation`

In `AppState.swift`, find `refreshPortfolio()` and `refreshMarket()`. Wrap state assignments in `withAnimation`:

```swift
// Before (example):
self.quotes[ticker] = newQuote

// After:
withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
    self.quotes[ticker] = newQuote
}
```

If these run on a background thread, use:
```swift
await MainActor.run {
    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
        self.quotes = newQuotes
    }
}
```

This is the single change that makes ALL `AnimatedPrice` views across the app animate simultaneously when a refresh happens.

---

## Task 6: New Feature Stubs (for upcoming sprint)

Create placeholder files for the new feature cards so they compile. Each file should contain a minimal `struct SomeCard: View { var body: some View { EmptyView() } }`:

- `STALK/SectorHeatMapCard.swift`
- `STALK/AIMarketContextCard.swift`
- `STALK/PortfolioHealthCard.swift`
- `STALK/TrendingTickersCard.swift`

Full implementations are specced in `/agents/memory/design/perplexity_features.md`. Implement these after Tasks 1–5 are shipped and tested.

---

## Acceptance Criteria

- [ ] Opening the Portfolio tab: cards stagger in from below, each 60ms after the previous
- [ ] Pulling to refresh: the total value number rolls to the new value — digits animate, no hard snap
- [ ] When portfolio gains switch to losses (or vice versa): P&L dollar and percent fade to the new color
- [ ] Market status pill has glass styling with animated pulse dot when market is live
- [ ] ATH badge breathes with a subtle scale pulse (1.0 → 1.04 → 1.0) when visible
- [ ] Streak badge shows orange gradient, not flat white
- [ ] Hero radial glow is visible in dark mode (check on actual device, not just simulator — simulator gamma is different)
- [ ] No regression: all existing tap targets, long press, sheets still work
- [ ] No third-party packages added

---

## Notes for Jordan

1. **Test the radial glow on a real device.** The `.screen` blend mode looks very different between simulator (gamma-corrected sRGB) and a real OLED display. You may need to nudge opacity up to 0.22 on device.

2. **`AnimatedPrice` vs direct `Text`.** For text that includes mixed content (ticker name + price in one string), keep using `Text`. `AnimatedPrice` is only for single numeric values. Do not try to use it for strings like `"Today +1.23%"` as a whole — either split them or apply `.contentTransition(.numericText())` directly on the `Text` with a manual `withAnimation` wrapper.

3. **Stagger delay cap.** The `min(..., 0.30)` cap in `StaggeredEntrance` means anything beyond index 5 still starts at 300ms. This is intentional — we don't want the 10th position card appearing 600ms after the tab tap.

4. **`@State private var appeared = false` in `StaggeredEntrance`.** This resets every time the view is recreated. If STALK uses `if selectedTab == .portfolio { PortfolioView() }` tab switching (recommended), the view IS recreated on each tab tap and the stagger replays automatically. If it uses `TabView` with all views alive simultaneously, `onAppear` will only fire once. In that case, use the `.onChange(of: trigger)` pattern from the stagger spec.
