# Portfolio Hero v2 — Design Spec
**Author:** Luna (UX Designer)
**Date:** 2026-06-09
**Status:** Ready for implementation

---

## Current Problems (from PortfolioView.swift audit)

1. **Value size is slightly too small** — currently 44pt `.heavy`. Upgrading to 48pt SF Pro Display Black with `.monospacedDigit()` adds presence and prevents layout shift when digits change.
2. **No animated number transitions** — `Text(appState.totalValue.fmtPrice())` renders statically. Every price update is a hard snap, which kills the sense of "live" data.
3. **Hero gradient is too subtle** — `appState.heroGradient` is a `LinearGradient` applied as a ZStack background. On #0A0A0F it almost disappears. Replace with a radial glow centered behind the number.
4. **P&L capsule uses raw `.white.opacity(0.2)`** — should use semantic `Theme.gain`/`Theme.loss` at 15% opacity to stay consistent with the design system.
5. **Market status pill has no glass treatment** — it reads as plain inline text. Needs a distinct glass pill.
6. **ATH badge is a plain pill** — no motion, no drama. Should pulse.
7. **Streak badge has no gradient** — flat `.white.opacity(0.15)`. Needs the orange gradient to feel earned.

---

## Spec: Total Value Display

```swift
Text(appState.totalValue.fmtPrice())
    .font(.system(size: 48, weight: .black, design: .default))
    .fontDesign(.default)
    // SF Pro Display at 48pt Black weight
    // Explicitly NOT .rounded — we want the engineering precision of Default
    .monospacedDigit()
    // Prevents layout jitter when digits change width
    .foregroundStyle(.white)
    .contentTransition(.numericText())
    // Animates digit rolls on value change — requires withAnimation wrapper at call site
    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.totalValue)
```

**Label above the number:**
```swift
Text("Total Portfolio Value")
    .font(.system(size: 11, weight: .semibold))
    .foregroundStyle(.white.opacity(0.5))
    .kerning(0.5)
    .textCase(.uppercase)
    // Tiny label, high kerning — reads as a field label, not a headline
```

---

## Spec: P&L Line

Replace the current single-capsule approach with a two-element row:

```swift
HStack(spacing: 8) {
    // Dollar amount — large, colored, no capsule
    Text("\(isGain ? "+" : "")\(appState.totalPnl.fmtPrice())")
        .font(.system(size: 22, weight: .bold))
        .foregroundStyle(isGain ? Theme.gain : Theme.loss)
        .monospacedDigit()
        .contentTransition(.numericText())
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.totalPnl)

    // Percentage — capsule pill with semantic color bg
    Text(appState.totalPnlPct.fmtPct())
        .font(.system(size: 14, weight: .bold))
        .foregroundStyle(isGain ? Theme.gain : Theme.loss)
        .monospacedDigit()
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background((isGain ? Theme.gain : Theme.loss).opacity(0.15))
        .clipShape(Capsule())
        .contentTransition(.numericText())
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.totalPnlPct)
}
.padding(.top, 8)
```

---

## Spec: Hero Radial Glow

Replace `appState.heroGradient` used as a ZStack background with a layered approach:

```swift
ZStack(alignment: .top) {
    // Base: keep the existing linear gradient for the color wash
    appState.heroGradient

    // Radial glow: indigo centered behind the value number
    // Position it roughly where the number sits (~140pt from top)
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
    // .screen blendMode makes it additive — it brightens without washing out the bg
    // On very dark backgrounds, .screen is far more effective than .normal

    VStack(alignment: .leading, spacing: 0) {
        // ... existing content ...
    }
}
```

**Note:** The glow radius (180pt) and opacity (0.18) are calibrated for #0A0A0F. If `heroGradient` shifts to a lighter palette, drop opacity to 0.12.

---

## Spec: Market Status Pill

Replace the current inline HStack with a proper glass pill:

```swift
HStack(spacing: 6) {
    // Left dot with pulse ring for live state
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
// Glass fill: white at 8% — reads as frosted on dark bg
.background(.ultraThinMaterial.opacity(0.15))
// Subtle material layer underneath for depth
.clipShape(Capsule())
.overlay(
    Capsule()
        .stroke(.white.opacity(0.12), lineWidth: 1)
    // Glass border: white at 12%
)
.padding(.bottom, 14)
```

Add `@State private var pulseScale: CGFloat = 1.0` and trigger with `.onAppear { pulseScale = 1.4 }`.

---

## Spec: ATH Badge

Replace the current `pill("🏆 NEW ATH!", ...)` with a dedicated animated badge:

```swift
// ATH Badge — gold, pulsing scale
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
    .easeInOut(duration: 0.9)
        .repeatForever(autoreverses: true),
    value: athPulse
)
.onAppear { athPulse = 1.04 }
// Gentle breathing pulse — 1.0 to 1.04 — just enough to draw the eye
```

Add `@State private var athPulse: CGFloat = 1.0`.

---

## Spec: Streak Badge

Replace the current flat streak pill with an orange gradient badge:

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
// Orange glow shadow to make it feel warm and earned
```

---

## Layout Changes Summary

| Element | Before | After |
|---|---|---|
| Value font | 44pt `.heavy` | 48pt `.black` + `.monospacedDigit()` |
| Value animation | None | `.contentTransition(.numericText())` |
| P&L dollar | Inside capsule | Bare 22pt bold, `Theme.gain/loss` colored |
| P&L percent | Inside same capsule | Separate pill, semantic bg at 15% opacity |
| Hero gradient | Linear only | Linear + radial indigo glow via `.screen` |
| Market status | Plain inline HStack | Glass capsule pill |
| ATH badge | Plain colored pill | Gold bordered pill with pulse animation |
| Streak badge | Flat white pill | Orange gradient pill with shadow glow |

---

## Constraints

- All animations must be value-driven (no `Timer` loops) — use `withAnimation` at the `AppState` update call site
- `.contentTransition` requires iOS 16+, which STALK already targets
- `.ultraThinMaterial` on the glass pill requires the view to have a non-clear background behind it — the hero gradient satisfies this
- No third-party dependencies
