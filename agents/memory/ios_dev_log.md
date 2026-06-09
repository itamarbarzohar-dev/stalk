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

---

## 2026-06-09 — BYOK Claude API + Price Alert UI

### Task 1: BYOK — Real Claude API in AIFullChatView

**New file: `KeychainHelper.swift`**
- `enum KeychainHelper` with `saveAPIKey`, `loadAPIKey`, `deleteAPIKey`
- Uses `kSecClassGenericPassword` with service `com.itamar.stalk.anthropic`
- Deletes before re-saving to avoid duplicates

**New view: `APIKeySetupView`**
- Sheet shown when user taps the key icon in the AI chat header
- Fields: SecureField for `sk-ant-...` input, "Get API Key →" button opens `https://console.anthropic.com` in Safari
- Save button activates only when key starts with `sk-ant-` and is >20 chars
- Saves to Keychain on tap, calls `onSaved()` callback so parent re-reads the key
- `presentationDetents([.medium, .large])` — dark themed to match chat

**Real API call: `callClaudeAPI(messages:apiKey:)` in `AIFullChatView`**
- `POST https://api.anthropic.com/v1/messages` with `x-api-key`, `anthropic-version: 2023-06-01`
- Model: `claude-haiku-4-5`, `max_tokens: 1024`
- `buildSystemPrompt()` injects user's full portfolio (tickers, shares, avg cost, current price, today %, total value, today P&L)
- Conversation history passed from `messages` array (skipping initial system greeting)
- Error handling: 401 → `APIError.invalidKey`, 429 → `APIError.rateLimited`, network failure → `APIError.networkError`

**Error states**
- `inlineError: String?` state drives an `errorBanner()` view between chat and input bar
- On API errors the message credit is refunded (`aiMessagesUsed -= 1`)
- Banner has dismiss "×" button

**Pro gate logic**
- Free users: 3 messages lifetime (unchanged)
- Pro users WITH API key: unlimited (bypass gate)
- Pro users WITHOUT API key: still gated at 3 (paywall prompts them to also set a key)
- Mock fallback still works if no key is set (old `generateReply()` preserved)

**Header changes**
- Key icon (🔑) shows green when connected, amber when no key — tapping opens `APIKeySetupView`
- Status dot + subtitle changes: "Connected · Claude Haiku" vs "Mock mode · Tap key icon to connect"

### Task 2: Price Alert UI

**`PositionCard` changes (PortfolioView.swift)**
- Bell badge: `Image(systemName: "bell.fill")` in ticker row when `appState.settings.alertThresholds` has an entry for this ticker
- Long-press now shows a `confirmationDialog` with three options: "Delete", "Set Price Alert", "Cancel" (replaces the immediate delete)
- `.contextMenu` added with "Set Price Alert" and "Delete Position" actions
- `.sheet(isPresented: $showAlertSheet)` presents `PriceAlertSheet`

**New view: `PriceAlertSheet`**
- `presentationDetents([.medium])`, drag indicator visible
- Shows current price from `appState.quotes`
- Two `alertField` rows: "Alert me above $___" and "Alert me below $___" with `keyboardType(.decimalPad)`
- "Clear" button top-right when an alert already exists
- `saveAlerts()` upserts into `appState.settings.alertThresholds` and calls `appState.saveSettings()`
- Placeholder values default to ±10% from current price as a helpful hint

### Build Status
`** BUILD SUCCEEDED **` — iOS Simulator, no errors (one pre-existing warning about Info.plist in Copy Bundle Resources)
