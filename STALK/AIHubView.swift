import SwiftUI

struct AIHubView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void

    @State private var showChat = false
    @State private var showAutopilot = false
    @State private var showBrief = false
    @State private var insightIndex = 0
    @State private var preloadedPrompt = ""

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
            LinearGradient(
                colors: [Color(hex: "#2D2B8F"), Color(hex: "#5B5BD6"), Color(hex: "#9C8FF5")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .frame(height: 160)

            // Decorative circles
            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 200, height: 200)
                .offset(x: 200, y: -40)
            Circle()
                .fill(.white.opacity(0.04))
                .frame(width: 120, height: 120)
                .offset(x: 260, y: 40)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Text("STALK AI")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)
                    Text("BETA")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(Color(hex: "#9C8FF5"))
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }
                Text("Your personal finance AI")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.75))

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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
                }
                .padding(.top, 4)
            }
            .padding(20)
        }
        .padding(.top, 12)
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
                                colors: [Color(hex: "#5B5BD6"), Color(hex: "#9C8FF5")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 36, height: 36)
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("STALK AI")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.text)
                        Text("Live · Updating every 5s")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.gain)
                    }
                    Spacer()
                    HStack(spacing: 3) {
                        ForEach(0..<insights.count, id: \.self) { i in
                            Circle()
                                .fill(i == insightIndex ? Color(hex: "#5B5BD6") : Theme.border)
                                .frame(width: 5, height: 5)
                                .animation(.easeInOut, value: insightIndex)
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
                    Text("Ask AI for more →")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(hex: "#5B5BD6"))
                }
            }
            .padding(16)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#5B5BD6").opacity(0.5), Color(hex: "#9C8FF5").opacity(0.2)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color(hex: "#5B5BD6").opacity(0.08), radius: 12, y: 4)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                withAnimation {
                    insightIndex = (insightIndex + 1) % insights.count
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
                ForEach(suggestedPrompts, id: \.self) { prompt in
                    Button {
                        preloadedPrompt = prompt
                        showChat = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkle")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: "#5B5BD6"))
                                .frame(width: 20)
                            Text(prompt)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Theme.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.text3)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
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
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Text(strategy.emoji)
                                        .font(.system(size: 20))
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(strategy.name)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(Theme.text)
                                        Text(strategy.risk.rawValue)
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(strategy.risk.color)
                                    }
                                }

                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("YTD")
                                            .font(.system(size: 9))
                                            .foregroundStyle(Theme.text3)
                                        Text(strategy.perf.ytd >= 0 ? "+\(String(format: "%.1f", strategy.perf.ytd))%" : "\(String(format: "%.1f", strategy.perf.ytd))%")
                                            .font(.system(size: 15, weight: .black))
                                            .foregroundStyle(strategy.perf.ytd >= 0 ? Theme.gain : Theme.loss)
                                    }
                                    Spacer()
                                    Text("\(strategy.followers / 1000)K following")
                                        .font(.system(size: 10))
                                        .foregroundStyle(Theme.text3)
                                }
                            }
                            .padding(14)
                            .frame(width: 180)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
                            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - AI Action Card

struct AIActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                        .lineLimit(2)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(0.15), lineWidth: 1))
            .shadow(color: color.opacity(0.06), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }
}
