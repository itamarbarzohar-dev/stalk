import SwiftUI

@main
struct STALKApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .task {
                    await appState.loadStoreKitProducts()
                    appState.listenForTransactions()
                    await appState.restorePurchases()
                }
        }
    }
}
