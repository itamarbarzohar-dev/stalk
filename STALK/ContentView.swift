import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) var appState
    @State private var addingPosition = false
    @State private var chartTicker: String? = nil

    var body: some View {
        Group {
            switch appState.selectedTab {
            case .market:    MarketView(onTicker: { chartTicker = $0 })
            case .portfolio: PortfolioView(onTicker: { chartTicker = $0 }, onAdd: { addingPosition = true })
            case .search:    SearchView(onTicker: { chartTicker = $0 })
            case .feed:      FeedView(onTicker: { chartTicker = $0 })
            case .forYou:    ForYouView(onTicker: { chartTicker = $0 })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CustomTabBar(addingPosition: $addingPosition)
        }
        .sheet(isPresented: $addingPosition) {
            AddPositionSheet()
        }
        .sheet(item: $chartTicker) { ticker in
            StockChartView(ticker: ticker)
        }
        .sheet(isPresented: Binding(
            get: { appState.showSettings },
            set: { appState.showSettings = $0 }
        )) {
            SettingsView()
        }
        .sheet(isPresented: Binding(
            get: { appState.showAIChat },
            set: { appState.showAIChat = $0 }
        )) {
            AIFullChatView()
        }
        .sheet(isPresented: Binding(
            get: { appState.showDailyBrief },
            set: { appState.showDailyBrief = $0 }
        )) {
            DailyBriefView()
        }
        .background(Theme.bg.ignoresSafeArea())
        .fullScreenCover(isPresented: Binding(
            get: { !appState.settings.hasCompletedOnboarding },
            set: { if !$0 { appState.settings.hasCompletedOnboarding = true; appState.saveSettings() } }
        )) {
            OnboardingFlowView()
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Environment(AppState.self) var appState
    @Binding var addingPosition: Bool

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "chart.line.uptrend.xyaxis", label: "Market", tab: .market)
            TabBarButton(icon: "briefcase.fill", label: "Portfolio", tab: .portfolio)

            // Center FAB
            Button {
                appState.selectedTab = .search
            } label: {
                ZStack {
                    Circle()
                        .fill(Theme.accentGradient)
                        .frame(width: 56, height: 56)
                        .shadow(color: Theme.accent.opacity(0.45), radius: 10, y: 4)
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .offset(y: -8)
            .frame(maxWidth: .infinity)

            TabBarButton(icon: "person.2.fill", label: "Feed", tab: .feed)
            TabBarButton(icon: "bolt.fill", label: "For You", tab: .forYou)
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

struct TabBarButton: View {
    @Environment(AppState.self) var appState
    let icon: String
    let label: String
    let tab: Tab

    var isActive: Bool { appState.selectedTab == tab }

    var body: some View {
        Button {
            appState.selectedTab = tab
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isActive ? Theme.accent : Theme.text3)
                Text(label)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(isActive ? Theme.accent : Theme.text3)
                    .textCase(.uppercase)
                    .kerning(0.4)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
