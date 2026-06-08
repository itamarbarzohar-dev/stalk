import SwiftUI
import BackgroundTasks

@main
struct STALKApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .task {
                    BGTaskScheduler.shared.register(
                        forTaskWithIdentifier: "com.stalk.portfolio.refresh",
                        using: nil
                    ) { task in
                        handleBackgroundRefresh(task: task as! BGAppRefreshTask)
                    }
                    scheduleBackgroundRefresh()
                }
        }
    }

    private func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.stalk.portfolio.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        scheduleBackgroundRefresh()

        let positions = appState.positions
        let thresholds = appState.settings.alertThresholds

        task.expirationHandler = { task.setTaskCompleted(success: false) }

        Task {
            let tickers = positions.map(\.ticker)
            let quotes = await QuoteService.fetchManyQuotes(tickers)
            if appState.settings.priceAlerts {
                NotificationService.checkPortfolioAlerts(
                    positions: positions,
                    quotes: quotes,
                    thresholds: thresholds
                )
            }
            task.setTaskCompleted(success: true)
        }
    }
}
