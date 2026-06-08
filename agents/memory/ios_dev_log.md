# iOS Dev Log — Jordan

## 2026-06-08 — App Store Readiness Sprint

### Completed

**Fix A: iOS Deployment Target**
- Changed `IPHONEOS_DEPLOYMENT_TARGET` from `26.5` to `17.0` in both Debug and Release target configs in `project.pbxproj`
- Set `TARGETED_DEVICE_FAMILY = 1` (iPhone only, was `"1,2,7"`)

**Fix B: App Icon**
- Created `STALK/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` — 1024x1024 indigo (#5B5BD6) background with white block-letter "S"
- Updated `Contents.json` to reference the PNG for all three iOS universal adaptive icon slots (light, dark, tinted)
- Note: placeholder icon — production will need a designer pass

**Fix C: Privacy Policy**
- Created `docs/privacy.html` — ready for GitHub Pages at `https://itamarbarzohar-dev.github.io/stalk/privacy`
- Policy states: zero data collection, all local, no analytics, no tracking

**Custom Info.plist**
- Switched from `GENERATE_INFOPLIST_FILE = YES` to a custom `STALK/STALK-Info.plist`
- Added `UIBackgroundModes: [fetch, processing]` and `BGTaskSchedulerPermittedIdentifiers: [com.stalk.portfolio.refresh]`
- Required for BGTaskScheduler registration

**Onboarding Flow (`OnboardingView.swift`)**
- 4-screen `OnboardingFlowView` with spring page transitions
- Screen 1: Welcome + name/username input, validation (2–30 chars / 3–20 chars), skip uses "Investor"/"@user"
- Screen 2: Trending chips with live prices from QuoteService, popular picks (SPY/QQQ/IBIT), AddPositionSheet pre-fill via new `prefillTicker` param
- Screen 3: Live portfolio value with animated counter (0→actual in 300ms), allocation bars, loading state
- Screen 4: Notifications ask with value-framing examples, UNUserNotificationCenter auth request
- `STALKSettings.hasCompletedOnboarding: Bool = false` added — set `true` on Screen 1 complete (never shows again)
- `ContentView.swift` gates main UI behind `.fullScreenCover` when `!hasCompletedOnboarding`
- `AddPositionSheet` gained optional `prefillTicker: String = ""` with `.onAppear` prefill

**Push Notifications (`NotificationService.swift`)**
- `requestAuthorization()` — async, respects previously denied status
- `scheduleMarketOpenNotification()` — `UNCalendarNotificationTrigger` repeating at 9:30 AM ET weekdays
- `schedulePriceAlert()` — fires when position moves >5% (called during background refresh)
- `scheduleThresholdAlert()` — fires when price crosses user-defined above/below thresholds
- `checkPortfolioAlerts()` — called in BGAppRefreshTask handler in `STALKApp`
- `syncWithSettings()` — called from Settings toggle to enable/disable market open alert

**AppState changes**
- Added `PriceAlertThreshold: Codable, Identifiable` struct with `alertAbove: Double?` and `alertBelow: Double?`
- Added `STALKSettings.alertThresholds: [PriceAlertThreshold] = []`

**STALKApp changes**
- `import BackgroundTasks`
- BGTaskScheduler.shared.register for `com.stalk.portfolio.refresh` in `.task` modifier
- `handleBackgroundRefresh()` fetches quotes and calls `NotificationService.checkPortfolioAlerts()`
- `scheduleBackgroundRefresh()` submits next BGAppRefreshTaskRequest (15-min earliest)

### Build Status
`** BUILD SUCCEEDED **` — iOS Simulator, iPhone 17, iOS 26.5 SDK

### PR
https://github.com/itamarbarzohar-dev/stalk/pull/3

### Known TODOs / Next Sprint
- App icon needs professional design treatment (current is programmatic placeholder)
- `AddPositionSheet` prefill doesn't focus the shares field — UX improvement
- Notification permission denied state in onboarding Screen 4 should show "Go to Settings" instead of system dialog (can't re-prompt once denied)
- BGAppRefreshTask interval is 15 min minimum but iOS throttles this heavily in practice
- Alert thresholds UI not yet implemented — `PriceAlertThreshold` model is ready but no UI in PortfolioView to set them
