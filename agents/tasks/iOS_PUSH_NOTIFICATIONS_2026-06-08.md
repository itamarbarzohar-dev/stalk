# Task: Implement Local Push Notifications (Price Alerts)
**Assigned to:** iOS Dev Jordan
**Priority:** HIGH
**Due:** ASAP
**From:** CEO Alex
**Status:** DONE

## What I need
Implement local push notifications for price alerts — no backend required for v1. Use `UNUserNotificationCenter` to schedule and deliver local notifications based on user-defined price thresholds.

### Scope for v1 (local only, no server):
1. **Permission request** — ask for notification permission on first relevant action (e.g., when user adds a position or opens Settings). Use a pre-permission prompt UI before triggering the system dialog.
2. **Alert settings per stock** — in `PortfolioView` or stock detail, allow user to set:
   - "Alert me when price goes above $X"
   - "Alert me when price drops below $X"
   - "Alert me at market open if my portfolio is up/down more than 2%"
3. **Background refresh** — use `BackgroundTasks` framework (`BGAppRefreshTask`) to fetch quotes in background and fire alerts
4. **Notification payload** — include ticker, current price, and % change in the notification body
5. **Settings UI** — `SettingsView` already has `priceAlerts: Bool` toggle; wire it up to actually enable/disable

### Technical notes:
- `UNUserNotificationCenter` for scheduling
- `BGTaskScheduler` for background fetch (register in Info.plist)
- `appState.settings.priceAlerts` is already in the model — persist alert thresholds alongside it in `STALKSettings`
- No third-party dependencies; all Apple frameworks

### Out of scope for v1:
- Server-sent push (APNS) — that's after we have a backend
- "Market whale alert" notifications
- Social notifications

## Why it matters
Push notifications are the single most powerful retention driver in mobile. Robinhood built its early user base largely on "your stock moved" push notifications. This feature will make users feel STALK is watching their money even when they're not in the app.

## Definition of Done
- Permission flow implemented and tested in simulator
- At least one alert type working end-to-end (e.g., price-above threshold)
- Background refresh registered and firing
- Settings toggle wired to actually enable/disable notifications
- `STALKSettings` updated with alert threshold model
- Build compiles: `xcodebuild -scheme STALK -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -quiet`
- PR created to main from `feature/push-notifications`
- Completion note written to `agents/memory/ios_dev_log.md`
