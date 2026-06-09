# Task: Price Alert Threshold UI
**Assigned to:** Jordan (iOS Dev)
**Priority:** HIGH
**Due:** 2026-06-09
**From:** CEO Alex
**Status:** OPEN

## Context

The `PriceAlertThreshold` model exists (added by Jordan on 2026-06-08 in `NotificationService.swift` / `AppState.swift`):
```swift
struct PriceAlertThreshold: Codable, Identifiable {
    var id: String  // ticker symbol
    var alertAbove: Double?
    var alertBelow: Double?
}
```
And `STALKSettings.alertThresholds: [PriceAlertThreshold]` is already persisted.

`NotificationService.scheduleThresholdAlert()` already fires a notification when price crosses thresholds.

What's missing: the UI to actually set these thresholds. Without UI, the model is invisible to users.

## What I need

### Entry Point: Stock Row in PortfolioView

In `PortfolioView`, each position row should have a way to access alert settings. Two acceptable approaches (choose the cleanest):

**Option A — Swipe action:**
Add a trailing swipe action on each position row:
```swift
.swipeActions(edge: .trailing) {
    Button {
        selectedAlertTicker = position.ticker
        showAlertSheet = true
    } label: {
        Label("Alert", systemImage: "bell.badge")
    }
    .tint(Color(hex: "#5B5BD6"))
}
```

**Option B — Bell icon on row:**
Add a `bell.fill` SF Symbol on the right side of each position row. If an alert is set for that ticker, show `bell.badge.fill` in accent color. Tap opens the sheet.

Pick whichever looks cleaner. If you're unsure, use Option B (visible affordance beats hidden swipe).

Add state to `PortfolioView`:
```swift
@State private var selectedAlertTicker: String? = nil
@State private var showAlertSheet = false
```

Attach sheet:
```swift
.sheet(isPresented: $showAlertSheet) {
    if let ticker = selectedAlertTicker {
        PriceAlertSheet(ticker: ticker)
    }
}
```

### PriceAlertSheet View

Create `STALK/Views/PriceAlertSheet.swift`.

The sheet covers the following layout (top to bottom):

**Header**
- Title: "[TICKER] Price Alert" — e.g., "AAPL Price Alert"
- Current price (fetched from QuoteService on appear): "Current price: $XXX.XX"
- Subtitle: "Get notified when price crosses your thresholds"

**Alert Above Section**
- Toggle: "Alert above" (on/off)
- When on: show a `TextField` with `$` prefix for the threshold price
- Placeholder: "e.g. \(currentPrice * 1.10, formatted as $XXX.XX)" — shows +10% as default hint
- Validation: must be a valid Double greater than 0

**Alert Below Section**
- Toggle: "Alert below" (on/off)
- When on: show a `TextField` for the threshold price
- Placeholder: "e.g. \(currentPrice * 0.90, formatted as $XXX.XX)" — shows -10% as default hint
- Validation: must be valid Double greater than 0 and less than alert-above value (if both set)

**Pro Gate**
If `!appState.settings.isPro` and user already has >= 3 tickers with active alerts (`appState.settings.alertThresholds.count >= 3`):
- Disable the save button
- Show inline message: "Upgrade to STALK Pro for unlimited price alerts"
- Show "Upgrade" button that triggers `showPaywall = true`

**Save Button**
- Label: "Save Alert" (or "Update Alert" if existing alert exists for this ticker)
- On tap: upsert into `appState.settings.alertThresholds`, call `appState.saveSettings()`
- Then: call `NotificationService.shared.scheduleThresholdAlert(...)` with the new thresholds
- Dismiss sheet

**Remove Alert Link**
- Only show if an existing alert is set for this ticker
- "Remove alert" in destructive red
- On tap: remove from `appState.settings.alertThresholds`, cancel related `UNNotificationCenter` pending notifications for this ticker, dismiss

### Wire to NotificationService

In `NotificationService.swift`, ensure `scheduleThresholdAlert()` signature handles both above and below thresholds. If the method currently only handles one direction, update it:

```swift
func scheduleThresholdAlert(ticker: String, currentPrice: Double, alertAbove: Double?, alertBelow: Double?) {
    // Cancel any existing notifications for this ticker before scheduling new ones
    UNUserNotificationCenter.current().removePendingNotificationRequests(
        withIdentifiers: ["\(ticker)-above", "\(ticker)-below"]
    )
    
    if let above = alertAbove, currentPrice < above {
        let content = UNMutableNotificationContent()
        content.title = "\(ticker) hit your target"
        content.body = "\(ticker) crossed above $\(String(format: "%.2f", above))"
        content.sound = .default
        // Note: local notifications can't trigger on a price condition — 
        // this actually fires from background refresh when price is fetched.
        // Schedule as a pending notification that BGTask will manage.
        scheduleNotification(content: content, identifier: "\(ticker)-above")
    }
    
    if let below = alertBelow, currentPrice > below {
        let content = UNMutableNotificationContent()
        content.title = "\(ticker) alert"
        content.body = "\(ticker) dropped below $\(String(format: "%.2f", below))"
        content.sound = .default
        scheduleNotification(content: content, identifier: "\(ticker)-below")
    }
}
```

### Portfolio View Alert Indicator

In the position list, show a badge/indicator when an alert is active for a given ticker:

```swift
// In position row view:
let hasAlert = appState.settings.alertThresholds.contains(where: { $0.id == position.ticker && ($0.alertAbove != nil || $0.alertBelow != nil) })

Image(systemName: hasAlert ? "bell.badge.fill" : "bell")
    .font(.system(size: 13))
    .foregroundStyle(hasAlert ? Theme.accent : Theme.text3)
```

## Design Notes (apply Luna's spec when available)

Until Luna delivers the design audit, use these defaults:
- Sheet background: `Theme.bg1`
- Input field border: `Theme.bg3` (inactive), `Theme.accent` (focused)
- Input field height: 52pt
- Input field corner radius: 12pt
- Toggle tint: `Theme.accent`
- Section spacing: 24pt between above/below sections
- Save button: full-width, 56pt height, 16pt corner radius, `Theme.accent` gradient background

If Luna delivers the UX audit before this task is done, apply her exact specs instead of the above.

## Why it matters

Price alerts are the #1 reason users keep a portfolio tracking app installed. Robinhood and Webull both feature this prominently. The model has been implemented since last sprint — every day without UI is a feature that exists in code but delivers zero user value. This is the fastest high-impact task available.

## Definition of Done

- [ ] Bell icon (or swipe action) visible on each position row in PortfolioView
- [ ] `PriceAlertSheet` opens when triggered, shows current price, above/below toggles + inputs
- [ ] Thresholds saved to `appState.settings.alertThresholds` and persisted
- [ ] Removing an alert clears it from storage and cancels pending notifications
- [ ] Pro gate: free users limited to 3 active alerts, paywall shown at limit
- [ ] Alert indicator visible on position row when alert is active
- [ ] `NotificationService.scheduleThresholdAlert()` handles both above and below
- [ ] Build compiles and tested in simulator
- [ ] Create PR from `feature/price-alert-ui` to main
- [ ] Log completion in `agents/memory/ios_dev_log.md`
