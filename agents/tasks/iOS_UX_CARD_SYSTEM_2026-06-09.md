# Task: Unified Card Design System — Dark Mode Migration
**Assigned to:** iOS Dev Jordan
**Authored by:** Luna (UX Designer)
**Date:** 2026-06-09
**Estimated effort:** 4–6 hours
**Priority:** CRITICAL — affects every screen in the app

---

## Goal

Every card in STALK currently uses light-mode colors: white backgrounds, `#EBEBF0` borders, `black.opacity(0.04)` shadows. These are completely invisible on a dark background. This task migrates the entire card system to the new dark design tokens and establishes a single reusable card modifier that all views use.

---

## Step 1: Update Theme.swift

Replace the entire `Theme` enum with this:

```swift
enum Theme {
    // MARK: - Backgrounds
    static let bg          = Color(hex: "#0A0A0F")   // primary app bg
    static let bg2         = Color(hex: "#0F0F17")   // secondary bg, inside cards
    static let bg3         = Color(hex: "#141420")   // tertiary bg, nested containers

    // MARK: - Cards
    static let card        = Color(hex: "#111118")
    static let cardRaised  = Color(hex: "#16161F")
    static let border      = Color.white.opacity(0.06)
    static let borderActive = Color.white.opacity(0.14)

    // MARK: - Text
    static let text        = Color(hex: "#F2F2F7")   // primary text
    static let text2       = Color(hex: "#A8A8B8")   // secondary text
    static let text3       = Color(hex: "#5C5C72")   // tertiary / muted
    static let text4       = Color(hex: "#3A3A50")   // disabled / ghost

    // MARK: - Semantic
    static let accent      = Color(hex: "#5B5BD6")
    static let accent2     = Color(hex: "#7C7CF0")
    static let gain        = Color(hex: "#00D26A")
    static let loss        = Color(hex: "#FF4757")
    static let gold        = Color(hex: "#F5A623")

    // MARK: - Semantic dim fills (use as card backgrounds, not text)
    static var gainBg: Color     { gain.opacity(0.12) }
    static var lossBg: Color     { loss.opacity(0.12) }
    static var accentBg: Color   { accent.opacity(0.12) }
    static var goldBg: Color     { gold.opacity(0.15) }

    // MARK: - Alloc bar
    static let allocColors: [Color] = [
        Color(hex: "#5B5BD6"), Color(hex: "#7C7CF0"), Color(hex: "#A78BFA"),
        Color(hex: "#818CF8"), Color(hex: "#60A5FA"), Color(hex: "#34D399"),
    ]

    // MARK: - Gradients
    static let accentGradient = LinearGradient(
        colors: [Color(hex: "#5B5BD6"), Color(hex: "#7C7CF0")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gainGradient = LinearGradient(
        colors: [Color(hex: "#00D26A"), Color(hex: "#00B85C")],
        startPoint: .leading, endPoint: .trailing
    )
    static let lossGradient = LinearGradient(
        colors: [Color(hex: "#FF4757"), Color(hex: "#E03040")],
        startPoint: .leading, endPoint: .trailing
    )
    static let goldGradient = LinearGradient(
        colors: [Color(hex: "#F5A623"), Color(hex: "#E8952A")],
        startPoint: .leading, endPoint: .trailing
    )
}
```

Keep the `Color(hex:)` extension and `Double` formatting extensions unchanged.

---

## Step 2: Create a Reusable Card ViewModifier

Add this to Theme.swift (or a new file `CardModifier.swift`):

```swift
// MARK: - Standard Card Modifier

struct STALKCard: ViewModifier {
    var radius: CGFloat = 20
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Theme.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.40), radius: 8, x: 0, y: 2)
    }
}

struct STALKCardRaised: ViewModifier {
    var radius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(Theme.cardRaised)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Theme.borderActive, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.55), radius: 16, x: 0, y: 6)
    }
}

extension View {
    func stalkCard(radius: CGFloat = 20, padding: CGFloat = 16) -> some View {
        modifier(STALKCard(radius: radius, padding: padding))
    }

    func stalkCardRaised(radius: CGFloat = 20) -> some View {
        modifier(STALKCardRaised(radius: radius))
    }
}
```

---

## Step 3: Update Every Card in the Codebase

Apply find-and-replace for the following patterns across all Swift files:

### Pattern A: Standard card background + border + shadow

Find:
```swift
.background(Theme.card)
.clipShape(RoundedRectangle(cornerRadius: 20))
.overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
.shadow(color: .black.opacity(0.04), radius: 4, y: 1)
```

Replace with:
```swift
.stalkCard(radius: 20)
// Note: remove the explicit .padding() from inside if present — stalkCard adds 16pt padding
// If the component has its own internal padding, use: .stalkCard(radius: 20, padding: 0)
```

### Pattern B: Cards with corner-radius 22/24

These use `.clipShape(RoundedRectangle(cornerRadius: 22))` or 24:
```swift
// Replace with
.stalkCard(radius: 22, padding: 0)   // keep internal .padding(18) etc
```

### Pattern C: AIAgentCard (already dark, just update colors)

The AIAgentCard uses `#1A1040 → #2D1B6E` gradient. Keep the dark approach but update to match the new palette:

```swift
// Old gradient
LinearGradient(
    colors: [Color(hex: "#1A1040"), Color(hex: "#2D1B6E"), Color(hex: "#1A1040")],
    startPoint: .topLeading, endPoint: .bottomTrailing
)

// New gradient (matches system dark tone)
LinearGradient(
    stops: [
        .init(color: Color(hex: "#0E0E20"), location: 0),
        .init(color: Color(hex: "#13103A"), location: 0.5),
        .init(color: Color(hex: "#0E0E20"), location: 1)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

The AIAgentCard `scoreCard()` inner mini-cards:
```swift
// Old
.background(.white.opacity(0.07))
.overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.10), lineWidth: 1))

// New — same approach, already correct for dark mode
.background(Color.white.opacity(0.06))
.overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.10), lineWidth: 1))
```

### Pattern D: Gain/Loss semantic backgrounds in cards

Find any instance of `Theme.gainBg` used as a card background fill and replace:
```swift
// Old (PositionCard gain/loss badge)
.background(isUp ? Theme.gainBg : Theme.lossBg)

// New
.background(isUp ? Theme.gain.opacity(0.15) : Theme.loss.opacity(0.15))
```

Find any instance of `Color(hex: "#EDEDFF")` (light indigo tag bg):
```swift
// Old (ticker tags, InsiderBuy ticker pill)
.background(Color(hex: "#EDEDFF"))

// New
.background(Theme.accent.opacity(0.15))
```

### Pattern E: briefCard in DailyBriefView

Replace the entire `briefCard` switch:

```swift
func briefCard(icon: String, title: String, body: String, type t: BriefCardType) -> some View {
    let (bg, borderColor): (Color, Color) = {
        switch t {
        case .good:    return (Theme.gain.opacity(0.10),   Theme.gain.opacity(0.28))
        case .warn:    return (Theme.gold.opacity(0.10),   Theme.gold.opacity(0.28))
        case .danger:  return (Theme.loss.opacity(0.10),   Theme.loss.opacity(0.28))
        case .alert:   return (Theme.accent.opacity(0.10), Theme.accent.opacity(0.28))
        case .neutral: return (Theme.card,                 Theme.border)
        }
    }()

    return HStack(alignment: .top, spacing: 12) {
        Text(icon).font(.system(size: 20)).frame(width: 28).padding(.top, 1)
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.text)
            Text(body)
                .font(.system(size: 12))
                .foregroundStyle(Theme.text2)
                .lineSpacing(3)
        }
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(bg)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderColor, lineWidth: 1))
}
```

### Pattern F: PositionBriefCard header

```swift
// Old
.background(isUp ? Color(hex: "#ECFDF5") : Color(hex: "#FEF2F2"))

// New
.background(isUp ? Theme.gain.opacity(0.10) : Theme.loss.opacity(0.10))
```

Divider overlays in PositionBriefCard:
```swift
// Old
Divider().overlay(isUp ? Color(hex: "#6EE7B7") : Color(hex: "#FCA5A5"))

// New
Divider().overlay(isUp ? Theme.gain.opacity(0.30) : Theme.loss.opacity(0.30))
```

### Pattern G: PremiumLockedCard glass overlay

```swift
// Old
.background(.white.opacity(0.96))

// New
.background(Color(hex: "#16161F").opacity(0.97))
.overlay(
    RoundedRectangle(cornerRadius: 18)
        .stroke(Color.white.opacity(0.10), lineWidth: 1)
)
```

### Pattern H: MarketRow and SectorChip

SectorChip — add gain/loss tint to background:
```swift
// If quote is available, tint the chip
let tint: Color = {
    guard let q = quote else { return Theme.card }
    return q.isUp ? Theme.gain.opacity(0.08) : Theme.loss.opacity(0.08)
}()

// Apply as background
.background(tint)
// Plus standard border and radius
.clipShape(RoundedRectangle(cornerRadius: 16))
.overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
```

---

## Step 4: Update All ScrollView / View Backgrounds

Every `.background(Theme.bg)` or `.background(Theme.bg2)` call is correct — Theme.bg and Theme.bg2 now resolve to the new dark values. No line-by-line changes needed after Step 1.

---

## Step 5: Skeleton Loading Animation

Add this shimmer modifier for all `MarketRowSkeleton` and future loading states:

```swift
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.07),
                        Color.white.opacity(0)
                    ],
                    startPoint: .init(x: phase, y: 0),
                    endPoint: .init(x: phase + 1, y: 0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
```

Apply to `MarketRowSkeleton`:
```swift
RoundedRectangle(cornerRadius: 4).fill(Theme.bg3).frame(width: 80, height: 14).shimmer()
```

---

## Acceptance Criteria

- [ ] `Theme.swift` updated — all light-mode values replaced with dark tokens
- [ ] `STALKCard` modifier exists and is used by at least PositionCard, MarketRow, VsMarketCard, VsFriendsCard, LiveFeedCard, TraderPostCard
- [ ] No white card backgrounds remain (`Color.white`, `Theme.card` before migration)
- [ ] No `#EBEBF0` / `Color(hex: "#EBEBF0")` border strings remain
- [ ] No `Color(hex: "#ECFDF5")` or `Color(hex: "#FEF2F2")` or `Color(hex: "#FFFBEB")` light semantic fills remain
- [ ] No `Color(hex: "#EDEDFF")` ticker tag backgrounds remain
- [ ] `briefCard` uses dark semantic fills
- [ ] `PositionBriefCard` header and dividers use dark gain/loss tints
- [ ] `PremiumLockedCard` uses dark glass overlay
- [ ] `MarketRowSkeleton` has shimmer animation
- [ ] App builds without errors
- [ ] Visual inspection: no jarring white blobs on any screen
