# Task: Premium Tab Bar Design
**Assigned to:** iOS Dev Jordan
**Authored by:** Luna (UX Designer)
**Date:** 2026-06-09
**Estimated effort:** 2–3 hours
**Priority:** HIGH — visible on every single screen, every single session

---

## Goal

The default iOS `TabView` renders a system-styled tab bar: gray icons, gray/blue text labels, light or translucent background. On a dark-mode app targeting a premium aesthetic this is unacceptable — it looks like a default-template app. STALK needs a custom tab bar that feels like it belongs to a $15/month trading product.

---

## Reference Aesthetic

Think: Nothing Phone launcher bar. Clean, minimal, dark. Icons glow their accent color when active. The background is nearly invisible — just a hint of separation from the content above.

---

## Current State

The app uses a standard SwiftUI `TabView` with system tab items. The active tab likely uses the default system blue or the accent color if tinted. Background is the system translucent bar.

---

## New Tab Bar Specification

### Container

```
Height: 72pt (content) + safe area bottom inset (auto)
Background: #0A0A0F (matches app bg — NOT translucent, NOT blurred)
Top border: 1pt line, color rgba(255,255,255,0.08)
Position: pinned to bottom, zIndex above scroll content
```

Do NOT use the system tab bar background or `UITabBar.appearance()` hacks. Build a custom `HStack` overlay positioned at the bottom of the main content area.

### Tab Items

The app has 4 tabs: Portfolio, Market, For You, Feed.

```
Tab icon size: 22pt SF Symbol, weight: medium
Tab label: 10pt Semibold, letter-spacing 0.3pt
Icon + label gap: 4pt
Item vertical padding: 10pt top, 8pt bottom
Item width: screen width / 4 (flex)
```

### Active State

```
Icon color:   #5B5BD6 (accent)
Label color:  #5B5BD6 (accent)
Background:   accent.opacity(0.10) pill behind the icon
Pill size:    42pt wide, 30pt tall
Pill corner:  Capsule
Pill animation: spring in when tab selected
```

### Inactive State

```
Icon color:   #5C5C72 (text3)
Label color:  #5C5C72 (text3)
Background:   none
```

### Active Indicator Animation

When a tab is selected, the pill background springs in:
```swift
.scaleEffect(isSelected ? 1.0 : 0.01)
.opacity(isSelected ? 1.0 : 0.0)
.animation(.spring(response: 0.30, dampingFraction: 0.70), value: isSelected)
```

Icon scales slightly:
```swift
.scaleEffect(isSelected ? 1.08 : 1.0)
.animation(.spring(response: 0.25, dampingFraction: 0.65), value: isSelected)
```

### SF Symbol Mapping

```swift
let tabs: [(id: Tab, icon: String, activeIcon: String, label: String)] = [
    (.portfolio, "briefcase",           "briefcase.fill",         "Portfolio"),
    (.market,    "chart.bar",           "chart.bar.fill",         "Market"),
    (.forYou,    "sparkles",            "sparkles",               "For You"),
    (.feed,      "person.2",            "person.2.fill",          "Feed"),
]
```

Note: `sparkles` does not have a `.fill` variant — use the same symbol for both states.

---

## Implementation

### Option A: Overlay Tab Bar (Recommended)

Instead of using `TabView`'s built-in tab bar, hide the system bar and overlay a custom one. This gives full control.

```swift
// In ContentView (or wherever TabView lives)
TabView(selection: $appState.selectedTab) {
    PortfolioView(...)
        .tag(Tab.portfolio)
    MarketView(...)
        .tag(Tab.market)
    ForYouView(...)
        .tag(Tab.forYou)
    FeedView(...)
        .tag(Tab.feed)
}
.tabViewStyle(.page(indexDisplayMode: .never))  // hides default bar
// OR use the UIKit approach below
.toolbar(.hidden, for: .tabBar)                 // iOS 16+
.overlay(alignment: .bottom) {
    CustomTabBar(selectedTab: $appState.selectedTab)
}
```

### Custom Tab Bar Component

```swift
struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    struct TabItem {
        let tab: Tab
        let icon: String
        let activeIcon: String
        let label: String
    }

    let items: [TabItem] = [
        .init(tab: .portfolio, icon: "briefcase",    activeIcon: "briefcase.fill",    label: "Portfolio"),
        .init(tab: .market,    icon: "chart.bar",    activeIcon: "chart.bar.fill",    label: "Market"),
        .init(tab: .forYou,    icon: "sparkles",     activeIcon: "sparkles",          label: "For You"),
        .init(tab: .feed,      icon: "person.2",     activeIcon: "person.2.fill",     label: "Feed"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            // Tab items
            HStack(spacing: 0) {
                ForEach(items, id: \.label) { item in
                    TabBarItem(
                        item: item,
                        isSelected: selectedTab == item.tab,
                        onTap: {
                            withAnimation(.spring(response: 0.30, dampingFraction: 0.70)) {
                                selectedTab = item.tab
                            }
                        }
                    )
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 8)
            .padding(.horizontal, 8)

            // Safe area fill
            Color(hex: "#0A0A0F")
                .frame(maxWidth: .infinity)
                .frame(height: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        }
        .background(Color(hex: "#0A0A0F"))
    }
}

struct TabBarItem: View {
    let item: CustomTabBar.TabItem
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    // Active background pill
                    Capsule()
                        .fill(Color(hex: "#5B5BD6").opacity(0.12))
                        .frame(width: 42, height: 30)
                        .scaleEffect(isSelected ? 1.0 : 0.01)
                        .opacity(isSelected ? 1.0 : 0.0)
                        .animation(.spring(response: 0.30, dampingFraction: 0.70), value: isSelected)

                    // Icon
                    Image(systemName: isSelected ? item.activeIcon : item.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(isSelected ? Color(hex: "#5B5BD6") : Color(hex: "#5C5C72"))
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isSelected)
                        .frame(width: 42, height: 30)
                }

                Text(item.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isSelected ? Color(hex: "#5B5BD6") : Color(hex: "#5C5C72"))
                    .kerning(0.3)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
```

### Safe Area Handling

The custom tab bar must respect the bottom safe area (home indicator on newer iPhones). Use `safeAreaInsets` from the scene or GeometryReader:

```swift
// Better approach — use safeAreaInset modifier on the content
TabView(selection: $appState.selectedTab) {
    // tab content...
}
.toolbar(.hidden, for: .tabBar)
.safeAreaInset(edge: .bottom, spacing: 0) {
    CustomTabBar(selectedTab: $appState.selectedTab)
}
```

Using `.safeAreaInset` is the cleanest approach — it pushes scroll content up by the tab bar height automatically, so no manual `Color.clear.frame(height: 100)` spacers are needed at the bottom of each scroll view.

---

## Remove the Bottom Spacers

Once `.safeAreaInset` is applied, remove the spacer hack at the bottom of each screen:

```swift
// Remove this from PortfolioView, MarketView, ForYouView, FeedView:
Color.clear.frame(height: 100)
```

The system will handle the safe area inset automatically.

---

## FAB Position Update

The FAB (AddFAB) in PortfolioView currently has:
```swift
.padding(.bottom, 88)
```

After the custom tab bar, measure the actual tab bar height (72pt + safe area) and update to:
```swift
.padding(.bottom, 80)   // sits just above the tab bar
```

---

## Haptic Feedback on Tab Switch

Add a subtle haptic when a tab is tapped:

```swift
func onTap() {
    let impact = UIImpactFeedbackGenerator(style: .light)
    impact.impactOccurred()
    withAnimation(.spring(response: 0.30, dampingFraction: 0.70)) {
        selectedTab = item.tab
    }
}
```

---

## Additional: Hide System Navigation Bar on All Screens

The screens use `.padding(.top, 52)` to account for the navigation bar. This is fragile — Dynamic Island devices need more. Use proper safe area:

```swift
// Each screen's top padding should be:
.padding(.top, 0)  // remove the hardcoded 52

// And the VStack/ScrollView should respect safeArea via:
.ignoresSafeArea(edges: .top)  // on the hero/header
// The content below the hero uses natural safe area
```

This is an optional improvement — can be done in a separate task if the current approach is working.

---

## Acceptance Criteria

- [ ] System `TabView` tab bar is hidden (not visible anywhere)
- [ ] Custom `CustomTabBar` renders at the bottom of the screen
- [ ] Active tab icon is `#5B5BD6` with pill background
- [ ] Inactive tab icons are `#5C5C72`
- [ ] Pill animates in/out with spring on tab change
- [ ] Icon scales slightly on selection (1.08x)
- [ ] Tab bar background is `#0A0A0F` — no blur, no translucency
- [ ] Top border is visible: `rgba(255,255,255,0.08)`, 1pt
- [ ] Bottom safe area is correctly filled (no gap showing wallpaper behind tab bar)
- [ ] Scroll content does not hide behind tab bar (`.safeAreaInset` working)
- [ ] `Color.clear.frame(height: 100)` spacers removed from all 4 screens
- [ ] FAB in Portfolio is above the tab bar with correct padding
- [ ] Haptic feedback fires on tab tap
- [ ] App builds and runs without crashes on both SE-sized and Pro Max-sized simulators
