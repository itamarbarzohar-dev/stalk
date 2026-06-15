import SwiftUI

struct AIHubView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void

    @State private var showChat = false
    @State private var showAutopilot = false
    @State private var showBrief = false
    @State private var insightIndex = 0
    @State private var preloadedPrompt = ""
    @State private var heroIconScale: CGFloat = 1.0
    @State private var heroIconRotation: Double = 0
    @State private var thinkingDot = 0

    private let insights = [
        "Your portfolio is up +19% all-time — beating the S&P by 4.2pts",
        "NVDA reports earnings in 3 days — you hold it at +44% gain",
        "AI infrastructure spend is accelerating — sector up 8% this month",
        "Your top position is 41% of portfolio — concentration risk flag",
        "Market volatility is low — historically good for momentum plays",
    ]

    private let suggestedPrompts = [
        "How is my portfolio doing today?",
        "What's the risk in my current positions?",
        "Should I rebalance anything?",
        "What stocks are trending right now?",
        "Explain my biggest winner",
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // ── Hero ─────────────────────────────────────────────────────
                heroSection

                // ── Quick Actions ────────────────────────────────────────────
                quickActions

                // ── AI Insight Card ──────────────────────────────────────────
                aiInsightCard

                // ── Suggested Prompts ────────────────────────────────────────
                suggestedPromptsSection

                // ── Autopilot Preview ────────────────────────────────────────
                autopilotPreview

                Color.clear.frame(height: 80)
            }
            .padding(.horizontal, 16)
        }
        .background(Theme.bg)
        .sheet(isPresented: $showChat) {
            AIFullChatView().environment(appState)
        }
        .sheet(isPresented: $showAutopilot) {
            AutopilotView().environment(appState)
        }
        .sheet(isPresented: $showBrief) {
            DailyBriefView().environment(appState)
        }
    }

    // MARK: - Hero

    var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Richer multi-stop mesh gradient
            Theme.aiHeroGradient
                .clipShape(RoundedRectangle(cornerRadius: 28))

            // Decorative glowing blobs
            Circle()
                .fill(.white.opacity(0.05))
                .frame(width: 240, height: 240)
                .blur(radius: 30)
                .offset(x: 160, y: -60)
            Circle()
                .fill(Color(hex: "#8B72F8").opacity(0.20))
                .frame(width: 140, height: 140)
                .blur(radius: 20)
                .offset(x: 220, y: 50)
            Circle()
                .fill(.white.opacity(0.03))
                .frame(width: 80, height: 80)
                .offset(x: 40, y: -80)

            // Animated brain icon top-right
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 80, height: 80)
                        Circle()
                            .fill(.white.opacity(0.06))
                            .frame(width: 60, height: 60)
                            .scaleEffect(heroIconScale)
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .rotationEffect(.degrees(heroIconRotation))
                            .scaleEffect(heroIconScale)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 24)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(hex: "#C4B5FD"))
                    Text("STALK AI")
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(.white)
                    Text("BETA")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(Color(hex: "#C4B5FD"))
                        .kerning(0.5)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }
                Text("Your personal finance AI")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.70))
                    .lineSpacing(4)

                Button {
                    showChat = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Ask me anything")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(Color(hex: "#5B5BD6"))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.white)
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "#5B5BD6").opacity(0.4), radius: 12, y: 4)
                }
                .padding(.top, 4)
            }
            .padding(22)
        }
        .frame(height: 200)
        .shadow(color: Color(hex: "#2D2B8F").opacity(0.5), radius: 24, y: 8)
        .padding(.top, 12)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                heroIconScale = 1.08
            }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                heroIconRotation = 8
            }
        }
    }

    // MARK: - Quick Actions

    var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK ACTIONS")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(Theme.text3)
                .kerning(1.5)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AIActionCard(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "AI Chat",
                    subtitle: "Ask about your portfolio",
                    color: Color(hex: "#5B5BD6"),
                    action: { showChat = true }
                )
                AIActionCard(
                    icon: "cpu.fill",
                    title: "Autopilot",
                    subtitle: "5 AI strategies live",
                    color: Color(hex: "#7C3AED"),
                    action: { showAutopilot = true }
                )
                AIActionCard(
                    icon: "newspaper.fill",
                    title: "Daily Brief",
                    subtitle: "Today's AI market summary",
                    color: Color(hex: "#0A84FF"),
                    action: { showBrief = true }
                )
                AIActionCard(
                    icon: "chart.bar.xaxis.ascending",
                    title: "Copy Trade",
                    subtitle: "Mirror top investors",
                    color: Color(hex: "#00C45A"),
                    action: { showAutopilot = true }
                )
            }
        }
    }

    // MARK: - AI Insight Card

    var aiInsightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI INSIGHT")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(Theme.text3)
                .kerning(1.5)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(hex: "#5B5BD6"), Color(hex: "#8B72F8")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 38, height: 38)
                            .shadow(color: Color(hex: "#5B5BD6").opacity(0.55), radius: 8, y: 2)
                        Image(systemName: "sparkles")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("STALK AI")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.text)
                        // Animated "thinking" dots
                        HStack(spacing: 3) {
                            Text("Thinking")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.gain)
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .fill(Theme.gain)
                                    .frame(width: 4, height: 4)
                                    .opacity(thinkingDot == i ? 1.0 : 0.25)
                                    .scaleEffect(thinkingDot == i ? 1.2 : 0.9)
                                    .animation(.easeInOut(duration: 0.3), value: thinkingDot)
                            }
                        }
                    }
                    Spacer()
                    HStack(spacing: 3) {
                        ForEach(0..<insights.count, id: \.self) { i in
                            Capsule()
                                .fill(i == insightIndex ? Color(hex: "#5B5BD6") : Theme.border)
                                .frame(width: i == insightIndex ? 14 : 5, height: 5)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: insightIndex)
                        }
                    }
                }

                Text(insights[insightIndex])
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.text)
                    .lineSpacing(4)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(insightIndex)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: insightIndex)

                Button {
                    showChat = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Ask AI for more")
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Color(hex: "#5B5BD6"))
                }
            }
            .padding(16)
            .background(
                ZStack {
                    Theme.card
                    LinearGradient(
                        colors: [Color(hex: "#5B5BD6").opacity(0.05), Color.clear],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "#8B72F8").opacity(0.70),
                                Color(hex: "#5B5BD6").opacity(0.45),
                                Color(hex: "#9C8FF5").opacity(0.15),
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color(hex: "#5B5BD6").opacity(0.20), radius: 18, y: 6)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                withAnimation {
                    insightIndex = (insightIndex + 1) % insights.count
                }
            }
            // Thinking dots pulse
            Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { _ in
                withAnimation {
                    thinkingDot = (thinkingDot + 1) % 3
                }
            }
        }
    }

    // MARK: - Suggested Prompts

    var suggestedPromptsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TRY ASKING")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(Theme.text3)
                .kerning(1.5)

            VStack(spacing: 8) {
                ForEach(Array(suggestedPrompts.enumerated()), id: \.offset) { index, prompt in
                    PromptRow(prompt: prompt, index: index) {
                        preloadedPrompt = prompt
                        showChat = true
                    }
                }
            }
        }
    }

    // MARK: - Autopilot Preview

    var autopilotPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI STRATEGIES")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(Theme.text3)
                    .kerning(1.5)
                Spacer()
                Button { showAutopilot = true } label: {
                    Text("See all →")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(hex: "#5B5BD6"))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(AI_STRATEGIES.prefix(3))) { strategy in
                        Button { showAutopilot = true } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                // Header row
                                HStack(spacing: 8) {
                                    PremiumIconView(symbol: strategy.icon, colors: strategy.iconColors, size: 36, iconSize: 16)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(strategy.name)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(Theme.text)
                                        // Risk pill — solid color bg + white text
                                        Text(strategy.risk.rawValue)
                                            .font(.system(size: 9, weight: .black))
                                            .foregroundStyle(.white)
                                            .kerning(0.3)
                                            .padding(.horizontal, 6).padding(.vertical, 3)
                                            .background(strategy.risk.color)
                                            .clipShape(Capsule())
                                    }
                                    Spacer()
                                }

                                // Mini sparkline bars (YTD visual proxy)
                                let bars: [CGFloat] = [0.3, 0.55, 0.4, 0.7, 0.6, 0.85, CGFloat(min(max(strategy.perf.ytd / 70.0, 0.1), 1.0))]
                                HStack(alignment: .bottom, spacing: 3) {
                                    ForEach(Array(bars.enumerated()), id: \.offset) { i, h in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(
                                                i == bars.count - 1
                                                    ? (strategy.perf.ytd >= 0 ? Theme.gain : Theme.loss)
                                                    : Theme.accent.opacity(0.35)
                                            )
                                            .frame(width: 8, height: max(h * 28, 4))
                                    }
                                }
                                .frame(height: 28)

                                Divider().opacity(0.4)

                                HStack(spacing: 0) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("YTD")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(Theme.text3)
                                            .kerning(0.5)
                                        Text(strategy.perf.ytd >= 0 ? "+\(String(format: "%.1f", strategy.perf.ytd))%" : "\(String(format: "%.1f", strategy.perf.ytd))%")
                                            .font(.system(size: 17, weight: .black))
                                            .foregroundStyle(strategy.perf.ytd >= 0 ? Theme.gain : Theme.loss)
                                            .contentTransition(.numericText())
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("AUM")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(Theme.text3)
                                            .kerning(0.5)
                                        Text(strategy.aum)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(Theme.text2)
                                    }
                                }
                            }
                            .padding(16)
                            .frame(width: 200)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        LinearGradient(
                                            colors: [strategy.risk.color.opacity(0.30), Theme.border],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: strategy.risk.color.opacity(0.15), radius: 12, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
}

// MARK: - Prompt Row

struct PromptRow: View {
    let prompt: String
    let index: Int
    let action: () -> Void

    @State private var isPressed = false

    // Cycle through a few accent tints for variety
    private var accentColor: Color {
        let palette: [Color] = [
            Color(hex: "#5B5BD6"),
            Color(hex: "#7C3AED"),
            Color(hex: "#0A84FF"),
            Color(hex: "#00C45A"),
            Color(hex: "#8B72F8"),
        ]
        return palette[index % palette.count]
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // Left accent border stripe
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.3)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 3)
                    .clipShape(Capsule())
                    .padding(.vertical, 8)

                HStack(spacing: 12) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(accentColor)
                        .frame(width: 20)
                    Text(prompt)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(3)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(accentColor.opacity(0.7))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 13)
            }
            .background(
                isPressed
                    ? accentColor.opacity(0.08)
                    : Theme.card
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isPressed ? accentColor.opacity(0.35) : Theme.border,
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.85), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation { isPressed = pressing }
        }, perform: {})
    }
}

// MARK: - AI Action Card

struct AIActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.22), color.opacity(0.12)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                            .shadow(color: color.opacity(0.35), radius: 8, y: 3)
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(color)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(color.opacity(0.55))
                        .padding(6)
                        .background(color.opacity(0.10))
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                        .lineLimit(2)
                        .lineSpacing(3)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.30), color.opacity(0.08)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: color.opacity(0.18), radius: 14, y: 5)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}
