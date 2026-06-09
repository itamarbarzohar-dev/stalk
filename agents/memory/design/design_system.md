# STALK Design System
**Version 1.0 — June 2026**
**Authored by Luna (UX Designer Agent)**

The aesthetic north star: Bloomberg Terminal rigor meets Nothing Phone minimalism meets Linear.app craft. Everything dark, layered, premium. Users should feel like they're holding a $999 trading terminal, not a hobby app.

---

## 1. Color Palette

### Background Layers

| Token | Hex | Role |
|---|---|---|
| `bg0` | `#07070C` | Deepest background — used behind modal sheets, scrim overlays |
| `bg1` | `#0A0A0F` | Primary app background — ALL ScrollView / View backgrounds |
| `bg2` | `#0F0F17` | Secondary background — used inside cards, section fills |
| `bg3` | `#141420` | Tertiary background — nested containers, input fields, row fills |

> Current Theme.swift uses `#F7F8FC` (light) and `#EEEEF5` (near-white). These must all be replaced. The app is light-mode today. The new system is dark-only.

### Cards & Surfaces

| Token | Hex | Usage |
|---|---|---|
| `card` | `#111118` | Default card background |
| `cardRaised` | `#16161F` | Elevated card (modal sheets, popovers) |
| `cardBorder` | `rgba(255,255,255,0.06)` | Universal card border — use `.opacity(0.06)` in SwiftUI |
| `cardBorderActive` | `rgba(255,255,255,0.14)` | Selected / focused card border |
| `glassFill` | `rgba(255,255,255,0.04)` | Glass effect surface fill |
| `glassBorder` | `rgba(255,255,255,0.10)` | Glass effect border |

### Text Hierarchy

| Token | Hex | Usage |
|---|---|---|
| `text1` | `#F2F2F7` | Primary text — headings, prices, important labels |
| `text2` | `#A8A8B8` | Secondary text — subtitles, descriptions, body copy |
| `text3` | `#5C5C72` | Tertiary text — labels, captions, placeholders |
| `text4` | `#3A3A50` | Disabled / ghost text — hints, deemphasized metadata |

> Current `Theme.text = #18181B`, `text2 = #52525B`, `text3 = #A1A1AA` are light-mode. Replace all.

### Semantic: Gain / Loss

| Token | Hex | Note |
|---|---|---|
| `gain` | `#00D26A` | Vivid green — more punchy than current `#059669` |
| `gainDim` | `#00D26A` at `.opacity(0.15)` | Tinted background fills behind gain numbers |
| `gainBorder` | `#00D26A` at `.opacity(0.30)` | Gain card borders |
| `loss` | `#FF4757` | Sharp red — more saturated than current `#E5534B` |
| `lossDim` | `#FF4757` at `.opacity(0.15)` | Tinted background fills behind loss numbers |
| `lossBorder` | `#FF4757` at `.opacity(0.30)` | Loss card borders |

### Accent & Brand

| Token | Hex | Usage |
|---|---|---|
| `accent` | `#5B5BD6` | Electric indigo — primary interactive color |
| `accent2` | `#7C7CF0` | Lighter indigo — gradient end, secondary accent |
| `accentDim` | `#5B5BD6` at `.opacity(0.15)` | Tinted accent backgrounds |
| `accentGlow` | `#5B5BD6` at `.opacity(0.30)` | Shadow glow for accent buttons |
| `gold` | `#F5A623` | ATH badge, ranking #1, "BEST VALUE" tag |
| `goldDim` | `#F5A623` at `.opacity(0.18)` | Gold tint backgrounds |
| `marketLive` | `#00D26A` | Live market dot |
| `marketClosed` | `#5C5C72` | Closed market dot |
| `marketPre` | `#F5A623` | Pre/after market dot |

### Gradients

```
accentGradient:   #5B5BD6 → #7C7CF0  (topLeading → bottomTrailing)
heroGradient:     #0A0A0F → #111130 → #0A0A0F  (radial center-top)
gainGradient:     #00D26A → #00B85C  (leading → trailing)
lossGradient:     #FF4757 → #E03040  (leading → trailing)
goldGradient:     #F5A623 → #E8952A  (leading → trailing)
aiCardGradient:   #0E0E20 → #13103A → #0E0E20  (topLeading → bottomTrailing)
```

---

## 2. Typography Scale

All text uses **SF Pro**. Numbers use **SF Pro Display** with `.monospacedDigit()` modifier for tabular alignment.

| Role | Size | Weight | Tracking | Usage |
|---|---|---|---|---|
| `displayNumber` | 48pt | Black (900) | -0.5pt | Portfolio total value hero |
| `displayNumberSm` | 36pt | Black (900) | -0.5pt | Large number in hero sub-stats |
| `heroLabel` | 26pt | Bold (700) | -0.3pt | Screen title (Market, For You) |
| `sectionTitle` | 15pt | Semibold (600) | 0pt | Card titles, section headers |
| `body` | 13pt | Regular (400) | 0pt | Body copy, feed post text |
| `bodySemibold` | 13pt | Semibold (600) | 0pt | Row names, important body |
| `bodyBold` | 13pt | Bold (700) | 0pt | Prices in rows, key values |
| `label` | 11pt | Medium (500) | 0pt | Supporting labels, subtitles |
| `caption` | 10pt | Semibold (600) | 0.8pt uppercase | Section headers, UPPERCASE labels |
| `micro` | 9pt | Bold (700) | 0.5pt uppercase | Tag labels, stat unit labels |
| `numberLarge` | 22pt | Black (900) | -0.3pt | P&L in cards, leaderboard |
| `numberMedium` | 15pt | Bold (700) | 0pt | Row prices, card values |
| `numberSmall` | 13pt | Black (900) | 0pt | Percentage changes |
| `pillText` | 12pt | Bold (700) | 0pt | Pill/capsule labels |
| `brandMark` | 13pt | Black (900) | 5pt | "STALK" logotype |

### Number Rendering Rules
- Always apply `.monospacedDigit()` to price and percent strings so digits don't jump width
- Gain/loss values get their respective color tokens, never default text color
- Animated number transitions: use `withAnimation(.easeInOut(duration: 0.35))` on value changes

---

## 3. Spacing System (4pt Base Grid)

All spacing is multiples of 4pt.

| Token | Value | Usage |
|---|---|---|
| `space1` | 4pt | Micro gap — icon to label, badge internal padding |
| `space2` | 8pt | Tight gap — between related elements within a card |
| `space3` | 12pt | Standard gap — card internal vertical rhythm |
| `space4` | 16pt | Default padding — card internal horizontal padding |
| `space5` | 20pt | Medium gap — between cards, hero padding |
| `space6` | 24pt | Large gap — section spacing |
| `space7` | 32pt | XL gap — major section dividers |
| `space8` | 48pt | XXL — hero top padding, safe area buffer |
| `horizontalPadding` | 16pt | Global horizontal margin (currently 14pt — increase to 16pt) |
| `cardPadding` | 16pt | Universal internal card padding |
| `fabBottomPadding` | 96pt | FAB above tab bar |

---

## 4. Corner Radii

| Component | Radius | Rationale |
|---|---|---|
| Hero card | 28pt bottom corners only | Bleeds edge-to-edge at top |
| Standard card | 20pt | Consistent, premium feel |
| Inner card / sub-surface | 14pt | Nested within standard card |
| Pill / capsule | `Capsule()` | Use SwiftUI Capsule shape |
| Score mini-card | 12pt | 2×2 grid cards inside AI card |
| Tag / chip | 8pt | Ticker tags, status badges |
| FAB | `Circle()` | Always circular |
| Input field | 14pt | Text fields, search |
| Bottom sheet / modal | 28pt top corners | Standard iOS sheet feel |
| Tab bar | 0pt | Full-width flush with bottom |
| Sector chip | 16pt | Horizontal scroll chips |

---

## 5. Shadow System

All shadows are dark-mode appropriate: dark ink instead of `black.opacity(0.05)`.

| Elevation | Shadow | Usage |
|---|---|---|
| Level 0 | none | Flat elements, section labels |
| Level 1 | `color: .black.opacity(0.40), radius: 8, x: 0, y: 2` | Standard cards |
| Level 2 | `color: .black.opacity(0.55), radius: 16, x: 0, y: 6` | Raised cards, active cards |
| Level 3 | `color: .black.opacity(0.70), radius: 28, x: 0, y: 12` | Modals, bottom sheets |
| Accent glow | `color: accent.opacity(0.35), radius: 20, x: 0, y: 4` | CTA buttons, FAB |
| Gain glow | `color: gain.opacity(0.25), radius: 12, x: 0, y: 0` | Gain-state cards |
| Loss glow | `color: loss.opacity(0.25), radius: 12, x: 0, y: 0` | Loss-state cards |
| Gold glow | `color: gold.opacity(0.30), radius: 16, x: 0, y: 4` | ATH badge, #1 rank |

> Current app uses `shadow(color: .black.opacity(0.04-0.05), radius: 3-8)` — far too weak for dark mode. These disappear completely on dark backgrounds.

---

## 6. Animation Timing

### Durations

| Name | Duration | Curve | Usage |
|---|---|---|---|
| `micro` | 0.10s | `.easeOut` | Press feedback, scale effects |
| `fast` | 0.20s | `.easeInOut` | Toggle states, visibility |
| `standard` | 0.30s | `.easeInOut` | Card transitions, tab switch |
| `smooth` | 0.45s | `.spring(response: 0.45, dampingFraction: 0.75)` | Cards springing in on appear |
| `springy` | 0.55s | `.spring(response: 0.55, dampingFraction: 0.65)` | FAB bounce, hero value change |
| `slow` | 0.60s | `.easeInOut` | Chart draw animation, page transitions |
| `hero` | 0.80s | `.spring(response: 0.8, dampingFraction: 0.7)` | Portfolio value first load |

### Number Update Animation
When a price value changes, animate with:
```swift
withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
    displayedValue = newValue
}
```
Use `Text(value).contentTransition(.numericText())` — available iOS 16+.

### Card Appear Animation
Cards in a list should stagger in:
```swift
.opacity(appeared ? 1 : 0)
.offset(y: appeared ? 0 : 16)
.animation(.spring(response: 0.45, dampingFraction: 0.75).delay(Double(index) * 0.05), value: appeared)
```

### Press Feedback
```swift
.scaleEffect(pressing ? 0.97 : 1.0)
.animation(.easeOut(duration: 0.10), value: pressing)
```

### Chart Draw
Stroke path from 0 → 1 trim using:
```swift
.trim(from: 0, to: animationProgress)
.animation(.easeInOut(duration: 0.80), value: animationProgress)
```

### Tab Bar Transition
Content fade + slide using `.transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))` with `standard` duration.

---

## 7. Component Specs

### Card Anatomy
Every card follows this exact pattern:
```
Background: #111118
Border: rgba(255,255,255,0.06), lineWidth: 1
Corner radius: 20pt
Padding: 16pt all sides
Shadow: Level 1
```

### Active / Selected Card State
```
Background: #16161F
Border: rgba(255,255,255,0.14), lineWidth: 1.5
Shadow: Level 2
```

### Pill / Badge
```
Background: semantic color at opacity(0.15)
Border: none
Corner radius: Capsule
Font: 11pt Semibold or 10pt Bold uppercase
Padding: horizontal 10pt, vertical 4pt
```

### Section Header
```
Font: 10pt Black, uppercase, letter-spacing 1.2pt
Color: text3 (#5C5C72)
Margin bottom: 10pt
Margin top: 22pt
```

### Divider
```
Color: rgba(255,255,255,0.06)
Height: 1pt (use Divider() with .overlay(Color(...)))
```

---

## 8. What Currently Exists in Theme.swift vs What Must Change

| Current Token | Current Value | New Value | Action |
|---|---|---|---|
| `accent` | `#5B5BD6` | `#5B5BD6` | Keep — correct |
| `accent2` | `#8B7CF6` | `#7C7CF0` | Update — slightly less purple |
| `gain` | `#059669` | `#00D26A` | Update — more vivid |
| `loss` | `#E5534B` | `#FF4757` | Update — more saturated |
| `gainBg` | `#ECFDF5` (light green) | `#00D26A` at `.opacity(0.12)` | Replace — dark mode |
| `lossBg` | `#FEF2F2` (light red) | `#FF4757` at `.opacity(0.12)` | Replace — dark mode |
| `bg` | `#F7F8FC` (near-white) | `#0A0A0F` | Replace — core change |
| `bg2` | `#EEEEF5` (light gray) | `#141420` | Replace — core change |
| `card` | `Color.white` | `#111118` | Replace — core change |
| `text` | `#18181B` | `#F2F2F7` | Replace — dark mode |
| `text2` | `#52525B` | `#A8A8B8` | Replace — dark mode |
| `text3` | `#A1A1AA` | `#5C5C72` | Replace — dark mode |
| `border` | `#EBEBF0` | `rgba(255,255,255,0.06)` | Replace — dark mode |
| `gold` | `#D97706` | `#F5A623` | Update — slightly lighter |
| `goldBg` | `#FFFBEB` (light yellow) | `#F5A623` at `.opacity(0.15)` | Replace — dark mode |
| `allocColors` | purple shades | Keep core set, ensure visible on dark | Verify contrast |
| `accentGradient` | `#5B5BD6 → #8B7CF6` | `#5B5BD6 → #7C7CF0` | Update end color |
