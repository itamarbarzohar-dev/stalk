# Task: Portfolio Hero Card — Premium Dark Redesign
**Assigned to:** iOS Dev Jordan
**Authored by:** Luna (UX Designer)
**Date:** 2026-06-09
**Estimated effort:** 3–4 hours
**Priority:** CRITICAL — this is the first thing every user sees

---

## Goal

Transform the PortfolioHero component from a light-gradient header that drops into a white screen into a fully dark, immersive hero that anchors the entire Portfolio tab. Every element must feel deliberate and premium. No placeholder styling.

---

## Exact Specification

### 1. Background

The hero sits at the top of a dark screen. Replace all light values:

```swift
// Background of the entire ScrollView
.background(Color(hex: "#0A0A0F"))

// The scrim overlay at the bottom of the hero (currently white blob)
// Was: RoundedRectangle(cornerRadius: 36).fill(Theme.bg).frame(height: 36).offset(y: 18)
// New: same shape but dark
RoundedRectangle(cornerRadius: 36)
    .fill(Color(hex: "#0A0A0F"))
    .frame(height: 36)
    .offset(y: 18)
```

### 2. Hero Gradient

The hero gradient should feel like a deep space window — dark center with subtle indigo nebula.

```swift
// Replace heroGradient in AppState (or override here)
// New gradient: radial-style using LinearGradient
LinearGradient(
    stops: [
        .init(color: Color(hex: "#0D0D1A"), location: 0),
        .init(color: Color(hex: "#111130"), location: 0.5),
        .init(color: Color(hex: "#0D0D1A"), location: 1)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### 3. Top Bar ("STALK" + Daily Brief + Settings)

Current: white opacity buttons, text, emoji

New:
```
"STALK" logotype:
  - Font: SF Pro, 13pt, Black weight
  - Kerning: 5pt
  - Color: #F2F2F7 at opacity(0.95)

Daily Brief button:
  - Background: rgba(255,255,255,0.08)
  - Border: rgba(255,255,255,0.12), lineWidth 1
  - ClipShape: Capsule
  - Horizontal padding: 13pt, vertical: 7pt
  - Icon: SF Symbol "doc.text" (not emoji "📋")
  - Text: "Daily Brief", 12pt Bold, #F2F2F7

Settings button:
  - Background: rgba(255,255,255,0.08)
  - Border: rgba(255,255,255,0.12), lineWidth 1
  - ClipShape: Circle
  - Icon: "gearshape.fill", 15pt, #F2F2F7 at opacity(0.85)
  - Frame: 34×34
```

### 4. Market Status Pill

```
Live dot:
  - Inner dot: 7×7, fill = marketStatus.dotColor
  - Pulse ring (when isLive):
    • 13×13 circle, same color at opacity(0.25)
    • Animate: scaleEffect 1.0→1.5, opacity 1.0→0.0
    • Loop with .repeatForever(autoreverses: false), duration 1.2s
    • Animation: .easeOut(duration: 1.2)

Label text: 11pt Bold, #F2F2F7 at opacity(0.90)
Separator "·": #F2F2F7 at opacity(0.35)
Subtitle text: 11pt Regular, #F2F2F7 at opacity(0.60)
```

### 5. Portfolio Value (THE Hero Number)

This is the most important number in the app. Give it weight.

```
"Total Portfolio Value" label:
  - Font: 11pt Semibold
  - Color: #F2F2F7 at opacity(0.55)
  - Tracking (kerning): 0.5pt
  - Padding bottom: 6pt

Portfolio value text:
  - Font: SF Pro Display, 48pt, Black weight
  - Color: #F2F2F7
  - Modifier: .monospacedDigit()
  - Modifier: .contentTransition(.numericText(countsDown: false))
  - minimumScaleFactor: 0.6

Animation on value change:
  withAnimation(.interpolatingSpring(stiffness: 180, damping: 22)) {
      // update displayedValue
  }
```

### 6. PnL Pill (below the value)

```
Gain state:
  - Background: Color(hex: "#00D26A") at opacity(0.18)
  - Border: Color(hex: "#00D26A") at opacity(0.35), lineWidth 1
  - Text: "+$X,XXX.XX  +XX.XX%"
  - Font: 14pt Bold
  - Color: #00D26A
  - ClipShape: Capsule
  - Padding: horizontal 14, vertical 7

Loss state:
  - Background: Color(hex: "#FF4757") at opacity(0.18)
  - Border: Color(hex: "#FF4757") at opacity(0.35), lineWidth 1
  - Text: "-$X,XXX.XX  -XX.XX%"
  - Font: 14pt Bold
  - Color: #FF4757
  - ClipShape: Capsule
  - Padding: horizontal 14, vertical 7
```

### 7. Stat Pills (Today / ATH / Streak)

Replace `.white.opacity(0.15)` with semantic fills:

```swift
func pill(_ label: String, _ value: String, accent: Color) -> some View {
    VStack(spacing: 2) {
        if value.isEmpty {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        } else {
            Text(value)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(.white)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.60))
        }
    }
    .padding(.horizontal, 13)
    .padding(.vertical, 8)
    .background(accent)                                        // semantic color already passed in
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.white.opacity(0.12), lineWidth: 1)
    )
}
```

Caller updates:
```swift
// Today pill
pill("Today", appState.todayPnlPct.fmtPct(),
     accent: appState.todayPnl >= 0 
         ? Color(hex: "#00D26A").opacity(0.20) 
         : Color(hex: "#FF4757").opacity(0.22))

// ATH pill
pill("NEW ATH!", "", accent: Color(hex: "#F5A623").opacity(0.25))

// From ATH pill
pill("From ATH", "-\(fromATH.fmtPrice())", accent: Color.white.opacity(0.08))

// Streak pill
pill("Streak", "\(appState.streak)d", accent: Color(hex: "#FF6B35").opacity(0.22))
// Note: remove fire emoji, use plain number + "d"
```

### 8. AllocBar

```
Height: 8pt (was 5pt)
Gap between segments: 1pt (was 2pt)
Corner radius: each segment uses Capsule
Animation: on appear, each segment scales from 0 → full width
  .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(i) * 0.04), value: appeared)
Top margin: 18pt (was 16pt)
```

### 9. Overall Hero Container Padding

```
.padding(.horizontal, 20)   // unchanged
.padding(.top, 56)           // was 52, bump for dynamic island devices
.padding(.bottom, 32)        // was 28
```

---

## Full SwiftUI Snippet for PortfolioHero Body Structure

This is the intended layering order inside the ZStack:

```swift
ZStack(alignment: .top) {
    // Layer 1: Hero gradient
    LinearGradient(
        stops: [
            .init(color: Color(hex: "#0D0D1A"), location: 0),
            .init(color: Color(hex: "#111130"), location: 0.5),
            .init(color: Color(hex: "#0D0D1A"), location: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Layer 2: Subtle noise/grain texture (optional — use if available)
    // Color.white.opacity(0.015).blendMode(.overlay)
    
    // Layer 3: Content
    VStack(alignment: .leading, spacing: 0) {
        topBar()
            .padding(.bottom, 16)
        
        marketStatusPill()
            .padding(.bottom, 16)
        
        valueSection()        // label + 48pt number + PnL pill + stat pills
            .padding(.bottom, 20)
        
        if !appState.positions.isEmpty {
            AllocBar()
        }
    }
    .padding(.horizontal, 20)
    .padding(.top, 56)
    .padding(.bottom, 32)
}
.overlay(alignment: .bottom) {
    // Dark scrim transition — NOT white
    RoundedRectangle(cornerRadius: 36)
        .fill(Color(hex: "#0A0A0F"))
        .frame(height: 36)
        .offset(y: 18)
}
```

---

## What NOT to Change

- The live-pulse ring animation logic (just add SwiftUI `.repeatForever` animation)
- The `MarketCalendar.status()` logic
- ATH / streak detection logic
- AppState data bindings
- The `.task` and `.refreshable` modifiers on the parent ScrollView

---

## Acceptance Criteria

- [ ] Hero gradient is dark, not colorful
- [ ] Portfolio value is 48pt, Black weight, tabular digits
- [ ] PnL pill has visible gain (green tint) and loss (red tint) states
- [ ] All stat pills are readable on the dark gradient
- [ ] AllocBar is 8pt, segments animate on load
- [ ] Scrim transition at bottom of hero blends into `#0A0A0F` not white
- [ ] Live market dot pulses with repeating animation
- [ ] No "📋" emoji — use SF Symbol in Daily Brief button
- [ ] All number displays use `.monospacedDigit()`
