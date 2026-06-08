# Task: App Icon, Launch Screen & App Store Assets
**Assigned to:** iOS Dev Jordan
**Priority:** HIGH
**Due:** ASAP
**From:** CEO Alex
**Status:** DONE

## What I need
Audit and complete all visual assets required for App Store submission. These are hard blockers for launch.

### 1. App Icon
- Confirm `Assets.xcassets/AppIcon.appiconset` has all required sizes
- Required: 1024x1024 (App Store), 60x60@2x, 60x60@3x, 20x20@2x, 20x20@3x, 29x29@2x, 29x29@3x, 40x40@2x, 40x40@3x, 76x76@1x, 76x76@2x, 83.5x83.5@2x, 1024x1024@1x
- The icon concept: use the STALK brand identity — bold, clean, finance-forward. Suggest a rising chart line or stylized "S" on a dark/indigo background. If the current icon is a placeholder, flag it and create a programmatic SwiftUI icon as a stopgap
- Check: does it pass Apple's dark/light/tinted adaptive icon format for iOS 18+?

### 2. Launch Screen
- Check if we have a `LaunchScreen.storyboard` or SwiftUI `@main` with a launch screen
- Implement a simple launch screen: dark background (#0D0D0F), centered STALK wordmark or logo, no animations (Apple policy)
- Must NOT show a loading spinner — that's a rejection risk

### 3. Screenshot Dimensions
- Confirm simulator can generate 6.9" (iPhone 16 Pro Max required), 6.5" screenshots
- Screenshots should be taken from the running app; note which views look best as hero screenshots (portfolio view with positions, market view, For You, AI chat)

### 4. Privacy Policy Page
- We need a URL pointing to a privacy policy before submission
- Create a simple HTML privacy policy page — or confirm where this will be hosted (GitHub Pages is fine for v1)
- Content: app collects zero personal data, all data stored locally on device

## Why it matters
Missing or incorrect app icons = Xcode build error. Missing launch screen = App Store rejection. Missing privacy policy URL = instant App Store rejection. These are all hard blockers that have nothing to do with features — they're pure checklist items.

## Definition of Done
- All icon sizes present in asset catalog, no missing slots
- Launch screen implemented and displays correctly in simulator
- Privacy policy HTML file committed to repo (can be hosted on GitHub Pages)
- Completion note written to `agents/memory/ios_dev_log.md`
- Build compiles and runs cleanly
