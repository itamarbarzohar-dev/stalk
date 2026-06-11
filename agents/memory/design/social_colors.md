# Social Feature Color Palette
**Author:** Luna (UX Designer)
**Date:** 2026-06-11
**Status:** Final — add to Theme.swift

---

## Overview

These colors extend the existing STALK design system specifically for gamification, social activity, and community features. They are additive — they do not replace existing semantic colors for price movement (`#00D26A` / `#FF4757`) which remain unchanged.

---

## Color Definitions

### XP / Gamification
```
Name: xpAmber
Hex: #F59E0B
Role: XP points, level progress bars, level-up UI
Usage:
  - XP number labels (e.g., "+50 XP")
  - Filled segments of level progress bar
  - Level number badge background
Why amber: warm, energetic, distinct from gain green. Signals reward without implying financial meaning.
```

### Streak Fire
```
Name: streakOrange
Hex: #F97316
Role: Active streak counter, fire emoji context, streak continuation prompts
Usage:
  - Streak day count (e.g., "🔥 14")
  - Streak at-risk warning banner (with pulsing opacity)
  - Streak freeze icon
Why orange: fire-adjacent, sits between XP amber and danger red. Warm urgency without alarm.
```

### Social Activity / Social Proof
```
Name: socialCyan
Hex: #06B6D4
Role: Social presence signals — live viewer counts, recent activity indicators
Usage:
  - "12 people checked this stock today"
  - "3 traders in your network hold this"
  - Live activity dot (pulsing)
  - Verified badge checkmark
Why cyan: cool, tech-forward. Creates visual separation from financial data. Implies network/information rather than money.
```

### Achievement Gold
```
Name: achievementGold
Hex: #F5A623
Blend: .screen (for shine overlays)
Role: Earned achievements, milestone markers, unlock animations
Usage:
  - Badge shine sweep animation (use .screen blend)
  - #1 leaderboard ring gradient base
  - "New achievement" toast border
  - Crown icon on top leaderboard position
Note: When using as a fill/background, use at 15-20% opacity. Full saturation is reserved for earned states — diluting it for decoration cheapens the earned signal.
```

### Reaction Selected State
```
Name: reactionIndigo
Hex: #5B5BD6
Role: Selected reaction pill, "you reacted" state
Usage:
  - Reaction pill border when selected: 1pt stroke #5B5BD6
  - Reaction pill background when selected: #5B5BD6 at 25% opacity
  - Count label when user has reacted
Note: This is the existing app accent color. Reusing it for reactions ties social interaction to the app's core identity — reacting feels like "this is STALK" not a tacked-on feature.
```

### "New" Badge / Unseen Indicator
```
Name: newBadgeGreen
Hex: #00D26A
Pulse: opacity 1.0 → 0.5 → 1.0, duration 1.4s, repeat forever
Role: "New" labels, unseen content dots, new achievement notification
Usage:
  - Small dot on story avatars with unseen content
  - "NEW" pill on newly unlocked badges
  - Notification badge on social tab icon
  - Unread reaction indicator
Note: This is the same green as positive price movement — intentional. "New" should feel like gain. The app's emotional vocabulary equates novelty with upside.
```

---

## Full Social Palette Reference

| Token | Hex | Usage |
|-------|-----|-------|
| `xpAmber` | `#F59E0B` | XP, levels, progress |
| `streakOrange` | `#F97316` | Streak counter, fire |
| `socialCyan` | `#06B6D4` | Social proof, activity, verified |
| `achievementGold` | `#F5A623` | Badges, #1 rank, milestones |
| `reactionIndigo` | `#5B5BD6` | Selected reactions (= app accent) |
| `newBadgeGreen` | `#00D26A` | Unseen, new content (= gain green) |

---

## Usage Rules

**Do not mix gamification and financial colors in the same context.**
If a number is a percentage return, it must use `#00D26A` or `#FF4757`.
If a number is XP or points, it must use `#F59E0B`.
Mixing these trains the eye to confuse game rewards with real money — which is dark pattern territory.

**Pulsing is reserved for actionable or time-sensitive states.**
- Streak at risk: pulse orange
- Unseen stories: pulse green
- ATH ring: pulse gold
Do not pulse decorative elements. Motion means meaning.

**Achievement gold is earned, not decorative.**
Do not use `#F5A623` for section headers, dividers, or UI chrome.
It must only appear when the user has accomplished something — or is about to.

---

## SwiftUI Implementation Notes

```swift
// Add to Theme.swift or Color+STALK.swift
extension Color {
    static let xpAmber        = Color(hex: "#F59E0B")
    static let streakOrange   = Color(hex: "#F97316")
    static let socialCyan     = Color(hex: "#06B6D4")
    static let achievementGold = Color(hex: "#F5A623")
    static let reactionIndigo = Color(hex: "#5B5BD6") // = existing accent
    static let newBadgeGreen  = Color(hex: "#00D26A") // = existing gainGreen
}
```

```swift
// Achievement shine modifier example
struct AchievementShineModifier: ViewModifier {
    @State private var shimmerOffset: CGFloat = -1.0

    func body(content: Content) -> some View {
        content.overlay(
            LinearGradient(
                colors: [.clear, Color.achievementGold.opacity(0.6), .clear],
                startPoint: .init(x: shimmerOffset, y: 0),
                endPoint: .init(x: shimmerOffset + 0.5, y: 1)
            )
            .blendMode(.screen)
        )
        .onAppear {
            withAnimation(.linear(duration: 2.0).delay(0.5)) {
                shimmerOffset = 1.5
            }
        }
    }
}
```

```swift
// Social activity pulse
struct PulsingDot: View {
    @State private var opacity: Double = 1.0

    var body: some View {
        Circle()
            .fill(Color.newBadgeGreen)
            .frame(width: 8, height: 8)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever()) {
                    opacity = 0.5
                }
            }
    }
}
```
