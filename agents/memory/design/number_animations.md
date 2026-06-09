# Number Animation System — Design Spec
**Author:** Luna (UX Designer)
**Date:** 2026-06-09
**Status:** Ready for implementation

---

## Philosophy

Every price and value in STALK should feel alive. Static numbers in a finance app communicate stale data. Animated digits communicate a live feed. The goal is not flashy — it is the quiet confidence of Bloomberg Terminal: numbers that roll, not snap.

The system is built on two primitives:
1. SwiftUI's `.contentTransition(.numericText())` — OS-native digit rollover, zero overhead
2. A reusable `AnimatedPrice` ViewModifier that standardizes the animation curve across the entire app

---

## Core Primitive: `.contentTransition(.numericText())`

`.numericText()` instructs SwiftUI to animate each digit position individually when a `Text` value changes. Digits that stay the same don't move. Only changed digits roll.

**Requirements:**
- Must be wrapped in `withAnimation` at the mutation call site, OR the view must declare `.animation(.., value:)` on the Text itself
- Works on `Text` only — not `Label`, not custom drawn paths
- Available iOS 16+

**Correct call site pattern (in AppState or any mutation):**
```swift
withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
    self.quotes[ticker] = newQuote
    // All views observing quotes will animate their Text transitions
}
```

If mutations happen off-main or via async tasks, dispatch the animation onto Main:
```swift
await MainActor.run {
    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
        self.quotes[ticker] = newQuote
    }
}
```

---

## Reusable Component: `AnimatedPrice`

```swift
struct AnimatedPrice: View {
    let value: Double
    let format: (Double) -> String

    // Internal displayed value — separate from `value` so we can
    // defer the animation start to .onAppear and drive it with .animation
    @State private var displayed: Double

    init(value: Double, format: @escaping (Double) -> String) {
        self.value = value
        self.format = format
        // Initialize displayed to value so there's no animation on first render
        self._displayed = State(initialValue: value)
    }

    var body: some View {
        Text(format(displayed))
            .monospacedDigit()
            // monospacedDigit prevents layout shifts as digit widths change
            .contentTransition(.numericText())
            .animation(
                .spring(response: 0.4, dampingFraction: 0.8),
                value: displayed
            )
            .onChange(of: value) { _, newValue in
                // onChange drives the animation — displayed chases value
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    displayed = newValue
                }
            }
    }
}
```

**Usage examples:**

```swift
// Portfolio total value (hero)
AnimatedPrice(value: appState.totalValue) { $0.fmtPrice() }
    .font(.system(size: 48, weight: .black))
    .foregroundStyle(.white)

// Position card value
AnimatedPrice(value: positionValue) { $0.fmtPrice() }
    .font(.system(size: 15, weight: .bold))
    .foregroundStyle(Theme.text)

// P&L dollar amount
AnimatedPrice(value: pnl) { $0.fmtChange() }
    .font(.system(size: 22, weight: .bold))
    .foregroundStyle(isGain ? Theme.gain : Theme.loss)

// Percentage — note: fmtPct() already adds +/- prefix
AnimatedPrice(value: pnlPct) { $0.fmtPct() }
    .font(.system(size: 14, weight: .bold))
    .foregroundStyle(isGain ? Theme.gain : Theme.loss)

// Ticker price in detail view
AnimatedPrice(value: quote.price) { $0.fmtPrice() }
    .font(.system(size: 34, weight: .heavy))
    .foregroundStyle(Theme.text)
```

---

## Animation Curve Rationale

**Spring: `response: 0.4, dampingFraction: 0.8`**

- `response: 0.4` — settles in ~400ms. Fast enough to feel real-time, slow enough that the digit roll is perceptible
- `dampingFraction: 0.8` — slight overshoot at 0.8 gives the number a tiny "bounce" that subconsciously communicates momentum (price going up "bounces" up, price going down "bounces" down)
- Do NOT use `dampingFraction: 1.0` (critically damped) — it feels corporate and dead

For the portfolio hero (48pt, most important number), use a slightly slower spring to give it gravity:
```swift
.spring(response: 0.5, dampingFraction: 0.75)
```

---

## Color Transition on Sign Change

When P&L flips from positive to negative (or back), the color should also animate:

```swift
// Wrap the color in an animation block alongside the value
AnimatedPrice(value: pnl) { $0.fmtChange() }
    .foregroundStyle(pnl >= 0 ? Theme.gain : Theme.loss)
    .animation(.easeInOut(duration: 0.3), value: pnl >= 0)
    // This animates the foregroundStyle color transition
```

SwiftUI can cross-fade `foregroundStyle` colors when the bool changes, giving a smooth red-to-green flip.

---

## Where to Apply Across the App

| Location | View | Value |
|---|---|---|
| Portfolio Hero | `PortfolioHero` | `totalValue`, `totalPnl`, `totalPnlPct`, `todayPnlPct` |
| Position Cards | `PositionCard` | `value`, `pnl` |
| Ticker Detail (price header) | `TickerDetailView` | `quote.price`, `quote.change`, `quote.changePercent` |
| AI Agent card grid | `AIAgentCard.scoreCard` | return %, today % |
| vs Market rows | `VsMarketCard.compRow` | all return values |
| Portfolio Health Score | `PortfolioHealthScore` (new) | score integer |
| Trending tickers | `TrendingTickerRow` (new) | price, changePercent |

---

## What NOT to Animate

- **Allocation bar segments** — use `.animation(.easeOut(duration: 0.5), value: pct)` on the `scaleEffect` instead, not numericText
- **Static labels** — "Total Portfolio Value", ticker symbols, company names — never animate these
- **Error/empty states** — no animation on zero values during loading
- **The ATH badge count** — it's a trophy, it should snap in dramatically, not roll in

---

## Performance Notes

`.contentTransition(.numericText())` is GPU-composited by UIKit — it does not cause view re-renders. It is safe to use on every price display in the app simultaneously. The only cost is the `withAnimation` call frequency; avoid driving it faster than the actual data refresh rate (currently every 30s background / on-demand pull-to-refresh).
