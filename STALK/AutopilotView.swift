import SwiftUI

// MARK: - Local Model

struct AutopilotStrategy: Identifiable {
    let id: Int
    let emoji: String
    let name: String
    let risk: RiskLevel
    let description: String
    let holdings: [String]
    let perf: TraderPerf
    let followers: Int
    let aum: String

    enum RiskLevel: String {
        case low       = "Low Risk"
        case medium    = "Medium Risk"
        case high      = "High Risk"
        case aggressive = "Aggressive"

        var color: Color {
            switch self {
            case .low:        return Theme.gain
            case .medium:     return Theme.gold
            case .high:       return Color(hex: "#FF8C42")
            case .aggressive: return Theme.loss
            }
        }

        var bgColor: Color {
            switch self {
            case .low:        return Theme.gain.opacity(0.15)
            case .medium:     return Theme.gold.opacity(0.15)
            case .high:       return Color(hex: "#FF8C42").opacity(0.15)
            case .aggressive: return Theme.loss.opacity(0.15)
            }
        }
    }
}

let AI_STRATEGIES: [AutopilotStrategy] = [
    AutopilotStrategy(
        id: 1,
        emoji: "🚀",
        name: "STALK Momentum",
        risk: .high,
        description: "Rides the hottest momentum names in AI and semiconductors. Rebalances weekly based on relative strength signals. High volatility, high conviction.",
        holdings: ["NVDA", "META", "AMD", "TSLA", "ARM"],
        perf: TraderPerf(day: 1.8, sixMonth: 31.4, ytd: 44.2, allTime: 127.8),
        followers: 12400,
        aum: "$2.4M"
    ),
    AutopilotStrategy(
        id: 2,
        emoji: "🤖",
        name: "AI Wave",
        risk: .aggressive,
        description: "Pure-play exposure to the AI infrastructure buildout. Concentrates in foundational chip makers and hyperscalers driving the next wave of compute.",
        holdings: ["NVDA", "AVGO", "TSM", "SMCI", "MSFT"],
        perf: TraderPerf(day: 2.4, sixMonth: 48.2, ytd: 61.0, allTime: 198.4),
        followers: 8920,
        aum: "$1.8M"
    ),
    AutopilotStrategy(
        id: 3,
        emoji: "💰",
        name: "Steady Dividend",
        risk: .low,
        description: "Sleep-well-at-night portfolio. Dividend aristocrats and defensive names that generate consistent income regardless of market conditions.",
        holdings: ["KO", "JNJ", "V", "BRK-B", "SCHD"],
        perf: TraderPerf(day: 0.3, sixMonth: 7.2, ytd: 11.4, allTime: 42.1),
        followers: 21300,
        aum: "$5.1M"
    ),
    AutopilotStrategy(
        id: 4,
        emoji: "🛡️",
        name: "Macro Hedge",
        risk: .medium,
        description: "Designed to hold value through macro uncertainty. Blends gold, bonds, utilities, and diversified equities to weather any economic storm.",
        holdings: ["GLD", "TLT", "XLU", "BRK-B", "SPY"],
        perf: TraderPerf(day: -0.2, sixMonth: 4.8, ytd: 8.9, allTime: 31.2),
        followers: 15700,
        aum: "$3.2M"
    ),
    AutopilotStrategy(
        id: 5,
        emoji: "🎯",
        name: "Small Cap Hunter",
        risk: .aggressive,
        description: "High-conviction bets on emerging tech disruptors. Targets small caps with transformative potential in AI, space, and quantum computing.",
        holdings: ["PLTR", "SOFI", "IONQ", "RKLB", "SOUN"],
        perf: TraderPerf(day: 3.1, sixMonth: 22.4, ytd: 38.7, allTime: 84.3),
        followers: 6810,
        aum: "$890K"
    ),
]

// MARK: - Main View

struct AutopilotView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    @State private var followedStrategies: Set<Int> = []
    @State private var expandedStrategy: Int? = nil
    @State private var pulseScale: CGFloat = 1.0
    @State private var showProAlert = false

    var activeStrategies: [AutopilotStrategy] {
        AI_STRATEGIES.filter { followedStrategies.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    autopilotHeader()

                    VStack(spacing: 24) {
                        if !activeStrategies.isEmpty {
                            activeStrategiesSection()
                        }

                        strategiesSection()

                        disclaimer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 60)
                }
            }
            .background(Theme.bg)
            .ignoresSafeArea(edges: .top)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.85))
                            .frame(width: 32, height: 32)
                            .background(.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .alert("Upgrade to STALK Pro", isPresented: $showProAlert) {
                Button("Upgrade") { }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enable Autopilot to let AI automatically mirror this strategy in your portfolio. Available with STALK Pro.")
            }
        }
    }

    // MARK: - Header

    @ViewBuilder
    func autopilotHeader() -> some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [
                    Color(hex: "#1A0938"),
                    Color(hex: "#2D1B6B"),
                    Color(hex: "#4B3BA8"),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                }
                .padding(.top, 52)

                Text("AI AUTOPILOT")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.55))
                    .kerning(2.0)
                    .padding(.top, 4)

                Text("AI Autopilot")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.top, 6)

                Text("Let AI manage your strategy")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.top, 4)

                heroPulseCard()
                    .padding(.top, 20)
                    .padding(.bottom, 28)
            }
            .padding(.horizontal, 20)
        }
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 32)
                .fill(Theme.bg)
                .frame(height: 32)
                .offset(y: 16)
        }
    }

    @ViewBuilder
    func heroPulseCard() -> some View {
        ZStack {
            // Glow rings
            Circle()
                .fill(Color(hex: "#7C6FE8").opacity(0.18))
                .frame(width: 120, height: 120)
                .scaleEffect(pulseScale)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulseScale)

            Circle()
                .fill(Color(hex: "#5B5BD6").opacity(0.25))
                .frame(width: 80, height: 80)
                .scaleEffect(pulseScale * 0.92)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.3), value: pulseScale)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#6F6FE8"), Color(hex: "#A78BFA")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: Color(hex: "#5B5BD6").opacity(0.6), radius: 12)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("5 AI Strategies")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)

                    Text("$13.4M Tracking")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.70))
                }

                Spacer()

                VStack(spacing: 3) {
                    Circle()
                        .fill(Theme.gain)
                        .frame(width: 8, height: 8)
                        .scaleEffect(pulseScale)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseScale)
                    Text("LIVE")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(Theme.gain)
                        .kerning(1.0)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(.white.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            )
        }
        .onAppear { pulseScale = 1.12 }
    }

    // MARK: - Active Strategies Section

    @ViewBuilder
    func activeStrategiesSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("My Active Strategies")

            VStack(spacing: 10) {
                ForEach(activeStrategies) { strategy in
                    HStack(spacing: 12) {
                        Text(strategy.emoji)
                            .font(.system(size: 22))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(strategy.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.text)
                            Text(strategy.risk.rawValue)
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.text2)
                        }

                        Spacer()

                        Text("ACTIVE")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(Theme.gain)
                            .kerning(0.8)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.gain.opacity(0.15))
                            .clipShape(Capsule())

                        perfBadge(strategy.perf.day)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Theme.gain.opacity(0.25), lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Strategies Section

    @ViewBuilder
    func strategiesSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("AI Strategies")

            VStack(spacing: 14) {
                ForEach(AI_STRATEGIES) { strategy in
                    strategyCard(strategy)
                }
            }
        }
    }

    @ViewBuilder
    func strategyCard(_ strategy: AutopilotStrategy) -> some View {
        let isExpanded = expandedStrategy == strategy.id
        let isFollowing = followedStrategies.contains(strategy.id)

        VStack(alignment: .leading, spacing: 0) {
            // Tap header to expand
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    expandedStrategy = isExpanded ? nil : strategy.id
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Text(strategy.emoji)
                        .font(.system(size: 26))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(strategy.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Theme.text)

                            riskBadge(strategy.risk)
                        }

                        Text(strategy.description.prefix(60) + (strategy.description.count > 60 ? "..." : ""))
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.text2)
                            .lineLimit(isExpanded ? nil : 1)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.text3)
                        .padding(.top, 4)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Expanded description
            if isExpanded {
                Text(strategy.description)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text2)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Perf grid
            perfGrid(strategy.perf)
                .padding(.horizontal, 16)
                .padding(.top, 14)

            // Holdings chips
            holdingsRow(strategy.holdings)
                .padding(.horizontal, 16)
                .padding(.top, 12)

            // Followers + AUM
            HStack(spacing: 0) {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                    Text(formatFollowers(strategy.followers))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.text2)
                }

                Text(" · ")
                    .foregroundStyle(Theme.text3)
                    .font(.system(size: 12))

                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                    Text(strategy.aum + " AUM")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.text2)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            // Action buttons
            HStack(spacing: 10) {
                followButton(strategy: strategy, isFollowing: isFollowing)
                autopilotButton(strategy: strategy)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isFollowing ? Theme.accent.opacity(0.35) : Theme.border,
                    lineWidth: isFollowing ? 1.5 : 1
                )
        )
        .shadow(color: .black.opacity(0.30), radius: 10, x: 0, y: 4)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isFollowing)
    }

    @ViewBuilder
    func perfGrid(_ perf: TraderPerf) -> some View {
        let metrics: [(label: String, value: Double)] = [
            ("Today",    perf.day),
            ("6 Month",  perf.sixMonth),
            ("YTD",      perf.ytd),
            ("All Time", perf.allTime),
        ]

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(metrics, id: \.label) { metric in
                VStack(spacing: 3) {
                    Text(metric.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.text3)
                        .textCase(.uppercase)
                        .kerning(0.4)
                    Text(formatPct(metric.value))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(metric.value >= 0 ? Theme.gain : Theme.loss)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(metric.value >= 0 ? Theme.gainBg : Theme.lossBg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    @ViewBuilder
    func holdingsRow(_ holdings: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(holdings, id: \.self) { ticker in
                    Text(ticker)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Theme.accentBg)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.accent.opacity(0.25), lineWidth: 1))
                }
            }
        }
    }

    @ViewBuilder
    func followButton(strategy: AutopilotStrategy, isFollowing: Bool) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                if isFollowing {
                    followedStrategies.remove(strategy.id)
                } else {
                    followedStrategies.insert(strategy.id)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isFollowing ? "checkmark" : "plus")
                    .font(.system(size: 12, weight: .bold))
                Text(isFollowing ? "Following" : "Follow Strategy")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(isFollowing ? Theme.accent : Theme.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isFollowing ? Theme.accentBg : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFollowing ? Theme.accent.opacity(0.5) : Theme.border, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func autopilotButton(strategy: AutopilotStrategy) -> some View {
        let isPro = appState.settings.isPro

        Button {
            if isPro {
                // Autopilot enable action (Pro)
            } else {
                showProAlert = true
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isPro ? "bolt.fill" : "lock.fill")
                    .font(.system(size: 12, weight: .bold))
                Text("Enable Autopilot")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isPro {
                        AnyView(Theme.accentGradient)
                    } else {
                        AnyView(Color(hex: "#3A3A4A"))
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Disclaimer

    @ViewBuilder
    func disclaimer() -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Theme.text3)
                .padding(.top, 1)

            Text("AI strategies are for informational purposes only. STALK does not execute trades on your behalf.")
                .font(.system(size: 12))
                .foregroundStyle(Theme.text3)
                .multilineTextAlignment(.leading)
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    // MARK: - Helpers

    @ViewBuilder
    func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Theme.text3)
            .kerning(1.2)
    }

    @ViewBuilder
    func riskBadge(_ risk: AutopilotStrategy.RiskLevel) -> some View {
        Text(risk.rawValue)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(risk.color)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(risk.bgColor)
            .clipShape(Capsule())
    }

    @ViewBuilder
    func perfBadge(_ value: Double) -> some View {
        Text(formatPct(value))
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(value >= 0 ? Theme.gain : Theme.loss)
    }

    private func formatPct(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", value))%"
    }

    private func formatFollowers(_ count: Int) -> String {
        if count >= 1000 {
            let k = Double(count) / 1000.0
            return String(format: "%.1fK followers", k)
        }
        return "\(count) followers"
    }
}
