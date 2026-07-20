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
            case .radar:      RadarView(onTicker: { chartTicker = $0 })
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

    private let aiActive   = LinearGradient(colors: [Color(hex: "#1A1A2E"), Color(hex: "#16213E"), Color(hex: "#0F3460")], startPoint: .topLeading, endPoint: .bottomTrailing)
    private let aiInactive = LinearGradient(colors: [Color(hex: "#4A4580"), Color(hex: "#6B68A8")], startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        VStack(spacing: 0) {
            // hairline separator
            Rectangle()
                .fill(Theme.border)
                .frame(height: 0.5)

            HStack(alignment: .center, spacing: 0) {
                // ── STALK AI — pill-style premium button ─────────────────
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
                        appState.selectedTab = .ai
                    }
                } label: {
                    let isAI = appState.selectedTab == .ai
                    HStack(spacing: isAI ? 9 : 0) {
                        ZStack {
                            if isAI {
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width: 34, height: 34)
                                    .scaleEffect(aiPulse ? 1.06 : 1.0)
                                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: aiPulse)
                            }
                            Image(systemName: "sparkles")
                                .font(.system(size: 20, weight: isAI ? .bold : .semibold))
                                .foregroundStyle(isAI ? .white : Color(hex: "#7A7AAA"))
                        }
                        if isAI {
                            Text("STALK AI")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.white)
                                .kerning(0.5)
                                .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                        }
                    }
                    .padding(.horizontal, isAI ? 22 : 0)
                    .padding(.vertical, isAI ? 13 : 0)
                    .background(
                        Group {
                            if isAI {
                                RoundedRectangle(cornerRadius: 26)
                                    .fill(aiActive)
                                    .shadow(color: Color(hex: "#0F3460").opacity(0.55), radius: 14, y: 5)
                            }
                        }
                    )
                    .frame(maxWidth: isAI ? nil : .infinity)
                    .frame(height: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .onAppear { aiPulse = true }
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: appState.selectedTab == .ai)

                // ── Regular tabs ─────────────────────────────────────────
                TabBarButton(icon: "chart.line.uptrend.xyaxis", label: "Market",    tab: .market,    activeColor: Color(hex: "#0A84FF"))
                TabBarButton(icon: "briefcase.fill",            label: "Portfolio", tab: .portfolio, activeColor: Color(hex: "#5B5BD6"))
                TabBarButton(icon: "list.star",                 label: "Watchlist", tab: .watchlist, activeColor: Color(hex: "#F59E0B"))
                TabBarButton(icon: "person.2.fill",             label: "Feed",      tab: .feed,      activeColor: Color(hex: "#FF375F"))
                TabBarButton(icon: "bolt.fill",                 label: "For You",   tab: .forYou,    activeColor: Color(hex: "#FF9500"))
                TabBarButton(icon: "dot.radiowaves.left.and.right", label: "Radar", tab: .radar,     activeColor: Color(hex: "#06B6D4"))
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 4)
        }
        .background(.ultraThinMaterial)
        .background(Theme.tabBar.opacity(0.6))
        .ignoresSafeArea(edges: .bottom)
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
            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                appState.selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: isActive ? .bold : .regular))
                    .foregroundStyle(isActive ? activeColor : Color(hex: "#636375"))
                    .scaleEffect(isActive ? 1.1 : 1.0)
                    .animation(.spring(response: 0.28, dampingFraction: 0.6), value: isActive)

                Text(label)
                    .font(.system(size: 8.5, weight: isActive ? .bold : .medium))
                    .foregroundStyle(isActive ? activeColor : Color(hex: "#636375"))
                    .kerning(0.2)

                Rectangle()
                    .fill(activeColor)
                    .frame(width: isActive ? 16 : 0, height: 2)
                    .clipShape(Capsule())
                    .opacity(isActive ? 1 : 0)
                    .animation(.spring(response: 0.28, dampingFraction: 0.6), value: isActive)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}
