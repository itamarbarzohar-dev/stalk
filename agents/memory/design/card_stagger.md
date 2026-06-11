# Card Stagger Animation — Design Spec
**Author:** Luna (UX Designer)
**Date:** 2026-06-09
**Status:** Ready for implementation

---

## Goal

When a tab is tapped and a new screen renders, cards should not all appear at once. They stagger in from below with a spring — each card slightly delayed relative to the previous. This gives the UI a sense of physical depth and makes the screen feel "assembled" rather than "teleported."

Reference aesthetic: Linear app list loads, Vercel dashboard card entrance.

---

## Animation Parameters

| Parameter | Value | Rationale |
|---|---|---|
| Delay per card | `Double(index) * 0.06` | 60ms between each card — fast enough to finish before the user starts scrolling |
| Spring response | `0.45` | Slightly slower than price animations — cards are larger, heavier |
| Damping fraction | `0.75` | Noticeable overshoot — the card "lands" with physical weight |
| Initial Y offset | `28` | Cards start 28pt below their resting position — enough to see motion, not so much it looks like a bottom sheet |
| Initial opacity | `0` | Cards fade in alongside the slide — combined makes it feel premium |

---

## ViewModifier: `StaggeredEntrance`

```swift
struct StaggeredEntrance: ViewModifier {
    let index: Int
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 28)
            .animation(
                .spring(response: 0.45, dampingFraction: 0.75)
                    .delay(Double(index) * 0.06),
                value: appeared
            )
            .onAppear {
                appeared = true
                // onAppear fires when the view enters the view hierarchy.
                // The animation block plays from (opacity: 0, y: 28) -> (opacity: 1, y: 0)
                // with the calculated delay.
            }
    }
}

extension View {
    func staggeredEntrance(index: Int) -> some View {
        modifier(StaggeredEntrance(index: index))
    }
}
```

---

## Usage

### PortfolioView card stack:

```swift
VStack(spacing: 0) {
    PortfolioHero()
        .padding(.bottom, 12)
        // Hero does NOT stagger — it's always present, not a card

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
}
```

### PositionsList — individual position cards:

```swift
VStack(spacing: 10) {
    ForEach(Array(appState.positions.enumerated()), id: \.element.id) { i, position in
        PositionCard(position: position, onTap: { onTicker(position.ticker) })
            .staggeredEntrance(index: i)
            // Each position card gets its own stagger index
            // With 4 section cards above, you may optionally offset:
            // .staggeredEntrance(index: i + 5)
            // But starting from 0 is fine since PositionsList itself staggers in
    }
}
```

### New feature screens (Sector Heat Map, Earnings Calendar, etc.):

```swift
// In any ForEach that renders a list of cards:
ForEach(Array(items.enumerated()), id: \.element.id) { i, item in
    SomeCard(item: item)
        .staggeredEntrance(index: i)
}

// For fixed layouts with named cards:
VStack(spacing: 12) {
    SectorHeatMapCard()
        .staggeredEntrance(index: 0)
    AIMarketContextCard()
        .staggeredEntrance(index: 1)
    PortfolioHealthCard()
        .staggeredEntrance(index: 2)
}
```

---

## Tab Switch Reset

The stagger should replay every time the user taps into a tab, not just on first load. To achieve this, the `appeared` state must reset when the parent tab changes.

```swift
struct StaggeredEntrance: ViewModifier {
    let index: Int
    var trigger: Bool = true
    // Pass a trigger that changes on tab switch

    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 28)
            .animation(
                .spring(response: 0.45, dampingFraction: 0.75)
                    .delay(Double(index) * 0.06),
                value: appeared
            )
            .onAppear { appeared = true }
            .onChange(of: trigger) { _, _ in
                // Reset and replay
                appeared = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    appeared = true
                }
            }
    }
}
```

Pass `trigger: appState.selectedTab == .portfolio` (or whichever tab) into each modifier. When the bool flips true, cards replay their entrance.

**Simpler alternative:** If tab views use `if selectedTab == .thisTab { ContentView() }` branching rather than `TabView`, the views are fully destroyed and recreated on tab switch — `onAppear` fires naturally and no trigger is needed. Prefer this pattern for STALK.

---

## Cap the delay

For screens with many items (e.g. 20 positions in PositionsList), cap the delay so the last card doesn't wait 1.2 seconds:

```swift
.delay(min(Double(index) * 0.06, 0.30))
// Cards beyond index 5 all animate at the same 300ms delay
// This means they arrive as a "wave" rather than an endless drip
```

---

## Cards that should NOT stagger

- Navigation bar / top bar items
- The hero section (`PortfolioHero`)
- FAB button (`AddFAB`)
- Empty state text
- Loading spinners

Stagger is for content cards only. Navigation chrome should always be instant.
