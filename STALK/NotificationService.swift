import Foundation
import UserNotifications

enum NotificationService {

    // MARK: - Permission

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .denied { return false }
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: - Market Open Notification

    static func scheduleMarketOpenNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["stalk.market.open"])

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = MarketCalendar.eastern

        var comps = DateComponents()
        comps.hour = 9
        comps.minute = 30
        comps.second = 0
        comps.weekday = nil

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "Market Open"
        content.body = "The US stock market is now open. Check your portfolio."
        content.sound = .default
        content.categoryIdentifier = "MARKET_OPEN"

        let request = UNNotificationRequest(
            identifier: "stalk.market.open",
            content: content,
            trigger: trigger
        )

        center.add(request) { _ in }
    }

    static func cancelMarketOpenNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["stalk.market.open"])
    }

    // MARK: - Price Alert Notifications

    static func schedulePriceAlert(
        ticker: String,
        currentPrice: Double,
        changePercent: Double,
        gainLoss: Double
    ) {
        guard abs(changePercent) >= 5 else { return }

        let center = UNUserNotificationCenter.current()
        let id = "stalk.price.alert.\(ticker)"

        center.removePendingNotificationRequests(withIdentifiers: [id])

        let direction = changePercent >= 0 ? "up" : "down"
        let arrow = changePercent >= 0 ? "▲" : "▼"
        let sign = changePercent >= 0 ? "+" : ""
        let gainStr = gainLoss >= 0 ? "+\(gainLoss.fmtPrice())" : gainLoss.fmtPrice()

        let content = UNMutableNotificationContent()
        content.title = "\(ticker) \(arrow) \(sign)\(String(format: "%.1f", changePercent))%"
        content.body = "\(ticker) is \(direction) \(sign)\(String(format: "%.1f", changePercent))% today. Your position: \(gainStr)."
        content.sound = .default
        content.categoryIdentifier = "PRICE_ALERT"
        content.userInfo = ["ticker": ticker]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request) { _ in }
    }

    static func scheduleThresholdAlert(ticker: String, price: Double, threshold: PriceAlertThreshold) {
        let center = UNUserNotificationCenter.current()

        if let above = threshold.alertAbove, price >= above {
            let id = "stalk.threshold.above.\(ticker)"
            let content = UNMutableNotificationContent()
            content.title = "\(ticker) hit your target"
            content.body = "\(ticker) is now \(price.fmtPrice()), above your alert of \(above.fmtPrice())."
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger)) { _ in }
        }

        if let below = threshold.alertBelow, price <= below {
            let id = "stalk.threshold.below.\(ticker)"
            let content = UNMutableNotificationContent()
            content.title = "\(ticker) dropped below your alert"
            content.body = "\(ticker) is now \(price.fmtPrice()), below your alert of \(below.fmtPrice())."
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger)) { _ in }
        }
    }

    // MARK: - Check portfolio for alerts (called during background refresh)

    static func checkPortfolioAlerts(positions: [Position], quotes: [String: Quote], thresholds: [PriceAlertThreshold]) {
        for position in positions {
            guard let quote = quotes[position.ticker] else { continue }

            // Big move alert (>5%)
            let gainLoss = quote.change * position.shares
            schedulePriceAlert(
                ticker: position.ticker,
                currentPrice: quote.price,
                changePercent: quote.changePercent,
                gainLoss: gainLoss
            )

            // Custom threshold alerts
            if let threshold = thresholds.first(where: { $0.ticker == position.ticker }) {
                scheduleThresholdAlert(ticker: position.ticker, price: quote.price, threshold: threshold)
            }
        }
    }

    // MARK: - Cancel all

    static func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Sync with settings

    static func syncWithSettings(_ settings: STALKSettings) {
        if settings.priceAlerts {
            scheduleMarketOpenNotification()
        } else {
            cancelMarketOpenNotification()
        }
    }
}
