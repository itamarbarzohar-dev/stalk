import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) var appState
    @State private var addingPosition = false
    @State private var chartTicker: String? = nil

    var body: some View {
        Group {
            switch appState.selectedTab {
            case .market:     MarketView(onTicker: { chartTicker = $0 })
            case .portfolio:  PortfolioView(onTicker: { chartTicker = $0 }, onAdd: { addingPosition = true })
            case .watchlist:  WatchlistView(onTicker: { chartTicker = $0 })
            case .ai:         AIHubView(onTicker: { chartTicker = $0 })
            case .feed:       FeedView(onTicker: { chartTicker = $0 })
            case .forYou:     ForYouView(onTicker: { chartTicker = $0 })
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
    @State private var aiPulse = false

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "chart.line.uptrend.xyaxis",
                label: "Market",
                tab: .market,
                activeColor: Color(hex: "#0A84FF")
            )
            TabBarButton(
                icon: "briefcase.fill",
                label: "Portfolio",
                tab: .portfolio,
                activeColor: Color(hex: "#5B5BD6")
            )
            TabBarButton(
                icon: "list.star",
                label: "Watchlist",
                tab: .watchlist,
                activeColor: Color(hex: "#F59E0B")
            )

            // ── AI Center Button ──────────────────────────────────────────
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    appState.selectedTab = .ai
                }
            } label: {
                VStack(spacing: 4) {
                    ZStack {
                        if appState.selectedTab == .ai {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#5B5BD6"), Color(hex: "#7C7CF0")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 58, height: 58)
                                .shadow(color: Color(hex: "#5B5BD6").opacity(0.55), radius: 14, y: 4)
                                .scaleEffect(aiPulse ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: aiPulse)
                        } else {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#5B5BD6"), Color(hex: "#9C8FF5")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 54, height: 54)
                                .shadow(color: Color(hex: "#5B5BD6").opacity(0.35), radius: 10, y: 3)
                        }
                        Image(systemName: "sparkles")
                            .font(.system(size: appState.selectedTab == .ai ? 24 : 22, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    Text("STALK AI")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(appState.selectedTab == .ai ? Color(hex: "#5B5BD6") : Color(hex: "#8A8A9A"))
                        .textCase(.uppercase)
                        .kerning(0.3)
                }
            }
            .offset(y: -6)
            .frame(maxWidth: .infinity)
            .buttonStyle(.plain)
            .onAppear { aiPulse = true }

            TabBarButton(
                icon: "person.2.fill",
                label: "Feed",
                tab: .feed,
                activeColor: Color(hex: "#FF375F")
            )
            TabBarButton(
                icon: "bolt.fill",
                label: "For You",
                tab: .forYou,
                activeColor: Color(hex: "#FF9500")
            )
        }
        .padding(.horizontal, 4)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(Theme.tabBar)
        .background(.ultraThinMaterial.opacity(0.3))
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
        }
    }
}

struct TabBarButton: View {
    @Environment(AppState.self) var appState
    let icon: String
    let label: String
    let tab: Tab
    let activeColor: Color

    var isActive: Bool { appState.selectedTab == tab }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                appState.selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isActive ? .bold : .regular))
                    .foregroundStyle(isActive ? activeColor : Color(hex: "#8A8A9A"))
                    .scaleEffect(isActive ? 1.12 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)

                Text(label)
                    .font(.system(size: 9, weight: isActive ? .bold : .semibold))
                    .foregroundStyle(isActive ? activeColor : Color(hex: "#8A8A9A"))
                    .textCase(.uppercase)
                    .kerning(0.4)

                // Active indicator dot
                Circle()
                    .fill(activeColor)
                    .frame(width: 4, height: 4)
                    .opacity(isActive ? 1 : 0)
                    .scaleEffect(isActive ? 1 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
