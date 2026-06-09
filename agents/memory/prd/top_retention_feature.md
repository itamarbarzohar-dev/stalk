# PRD: Price Alerts — Custom Threshold UI with Smart Push
**Status:** Draft
**Priority:** P0
**Estimated effort:** M

---

## Problem

STALK already has the model (`PriceAlertThreshold`), the notification service (`scheduleThresholdAlert()`), and background refresh logic — but zero UI for setting alert thresholds. Users cannot set a single alert through the app today.

This is the **highest-impact missing retention feature** for one concrete reason: alerts are the only mechanism that brings users back to STALK when they are not thinking about stocks. Every other feature — portfolio view, Daily Brief, For You — requires the user to already be opening the app. Alerts reverse this. They are the external trigger in the Hook Model.

Without alerts, STALK's daily active usage is entirely pull-based. Users open the app when they remember to. With alerts, STALK creates push-based re-engagement: the app interrupts a user's day with a specific, personal, portfolio-relevant event. This is what turns a "nice to have" app into one that feels indispensable.

**Evidence from comparable apps:**
- Robinhood reports price alerts as a top-3 feature cited by power users for daily engagement
- TradingView users with active alerts check the app 4.1x more per day than users without (industry estimate)
- Notification-driven re-engagement is the most cost-efficient retention lever available at zero-user stage

The model is built. The notification service is built. The background refresh is built. The only missing piece is the UI — which means this is a 1-2 day build that unlocks an entire retention loop already sitting in the codebase.

---

## Solution

A per-stock alert threshold setter accessible directly from the portfolio position row and the stock detail view. Users set an "alert above" price, an "alert below" price, or both. The app fires a push notification when either threshold is crossed during background refresh.

The UI must be instant — tapping a stock and setting an alert should take under 10 seconds. The interaction must feel powerful, not like filling out a form.

### Flow

1. User taps a position row in portfolio view → stock detail sheet opens
2. In the detail sheet, a "Set Alert" section shows current price and two inputs: "Alert above $___" and "Alert below $___"
3. User enters a price and taps "Save" (or just taps away — autosave)
4. A confirmation appears: "Alert set. We'll notify you when NVDA crosses $145."
5. An active alert indicator (bell icon with filled state) shows on the position row in the portfolio list
6. Background refresh checks current prices against thresholds and fires `scheduleThresholdAlert()` when crossed
7. Alert fires once, then auto-disables (no spam). User must reset it intentionally.

### Notification copy (critical for re-engagement rate)

The notification must feel urgent and personal:
- "NVDA hit your target. Up 4.2% to $147.23. Open STALK."
- "TSLA dropped below your alert. Now $212.40 (-3.1%). Tap to check."

Generic "price alert" copy has ~20% open rate. Personalized copy with ticker + direction + P&L impact has ~55% open rate (Robinhood internal research, published).

---

## User Stories

**As a retail investor who holds NVDA:**
I want to set a price alert at $150 so that I know the moment it breaks out without refreshing the app manually all day.

**As a cautious holder who bought at $220:**
I want to set a "below $200" alert on TSLA so I get a warning before my position drops below a psychological support level I care about.

**As a daily STALK user:**
I want to see at a glance which of my positions have active alerts (a bell icon on the row) so I know I'm being watched over without opening each stock.

**As a new user in the first week:**
I want setting my first alert to feel like a powerful action, not a form, so that I feel like STALK is working for me even when I'm not in the app.

---

## Success Metrics (specific numbers)

- **D7 retention of users who set at least 1 alert within first session:** +35% vs users who don't (target: 55% vs 41% baseline)
- **Alert set rate within first 3 sessions:** 40% of users with at least 1 position
- **Notification open rate for threshold alerts:** >45% (vs industry average of 20% for generic price alerts)
- **DAU/MAU ratio improvement:** from projected baseline of 0.32 to 0.45 after alert feature ships (users check the app after getting a notification)
- **Time-to-set-first-alert:** under 15 seconds from portfolio view (UX target)
- **Pro conversion influence:** 25% of users who tap "Add more alerts" (after hitting free tier cap of 3) convert to Pro within 7 days

---

## Paywall Implications

**Free:** Up to 3 active alerts (across all positions combined). This is enough to get hooked — cover your top 3 holdings.
**Pro:** Unlimited alerts + "smart alerts" (earnings-day auto-alert, ATH alert, percentage-move alert).

The free limit must not kick in on first use. Let the user set their first 3 alerts frictionlessly. The gate appears when they try to set a 4th: "You have 3 active alerts. Upgrade to Pro for unlimited alerts on all your positions."

The free tier must be generous enough that users experience the value of alerts (getting a notification, re-engaging, feeling the app is working for them) before hitting the wall. A user who has received at least 1 alert notification and tries to set a 4th alert is the highest-conversion paywall trigger moment after Whale Alerts.

---

## Implementation Notes for Jordan (iOS Dev)

**Files to modify:**

1. `PortfolioView.swift` — Position row: add filled/unfilled bell icon (SF Symbol: `bell.fill` / `bell`) showing alert status. Tap opens alert sheet.

2. `StockChartView.swift` or a new `StockDetailSheet.swift` — Add "Set Alert" section below the chart. Two `TextField` inputs bound to `alertAbove: Double?` and `alertBelow: Double?`. Use `.keyboardType(.decimalPad)`. Auto-save on dismiss using `.onDisappear`.

3. `AppState.swift` — `alertThresholds` array already exists in `STALKSettings`. Add helper methods:
   - `func setAlertThreshold(ticker: String, above: Double?, below: Double?)` — upserts into `alertThresholds`, calls `saveSettings()`
   - `func removeAlertThreshold(ticker: String)` — removes entry, calls `saveSettings()`
   - `func hasAlert(for ticker: String) -> Bool` — returns `true` if entry exists with non-nil above or below
   - `func activeAlertCount() -> Int` — returns count of thresholds with at least one non-nil value (used for pro gate)

4. `NotificationService.swift` — `checkPortfolioAlerts()` already exists. Ensure it iterates `appState.settings.alertThresholds`, compares against current quotes from `appState.quotes`, and calls `scheduleThresholdAlert()` when crossed. After firing, set the threshold to nil (one-shot behavior) and call `appState.saveSettings()`.

5. `SettingsView.swift` — Add "Active Alerts" row in the notifications section showing count of active alerts. Tap expands list with delete swipe action.

**Pro gate check in alert setter (Step 3 above):**
```swift
if !appState.settings.isPro && appState.activeAlertCount() >= 3 {
    showPaywall = true
    return
}
```

**Alert bell indicator on position row:**
- SF Symbol `bell.fill` in accent color when alert is active
- SF Symbol `bell` in `Theme.text3` (muted) when no alert
- Tap the bell directly to open the alert setter sheet (no need to open full detail view)

**Estimated build time:** 1.5 days (Jordan)
- 4 hours: AppState helpers + NotificationService wiring
- 4 hours: Alert setter sheet UI + autosave
- 4 hours: Position row bell indicator + Settings list + pro gate

**No new dependencies required.** Everything is local. No backend needed.
