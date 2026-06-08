import SwiftUI
import Combine

struct AIFullChatView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var messages: [ChatMessage] = ChatMessage.initialMessages
    @State private var input = ""
    @State private var isThinking = false
    @FocusState private var inputFocused: Bool
    @State private var showPaywall = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                header()
                chatArea()
                proGateHint()
                inputBar()
            }
        }
        .background(Color(hex: "#0F0A1E"))
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showPaywall) {
            PremiumSheet()
        }
    }

    // Subtle "1 question remaining" hint
    @ViewBuilder
    func proGateHint() -> some View {
        if !appState.settings.isPro && appState.settings.aiMessagesUsed == 2 {
            Text("1 free question remaining — Upgrade for unlimited AI analysis")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#7B6FEF").opacity(0.25))
        }
    }

    // MARK: - Header

    func header() -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1A0B3B"), Color(hex: "#2D1B69"), Color(hex: "#4A2C8F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 14) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }

                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(hex: "#7B6FEF"), Color(hex: "#5B5BD6")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .frame(width: 44, height: 44)
                            Text("🤖")
                                .font(.system(size: 22))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text("STALK AI")
                                    .font(.system(size: 17, weight: .black))
                                    .foregroundStyle(.white)
                                Text("PRO")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2)
                                    .background(Color(hex: "#7B6FEF").opacity(0.6))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            HStack(spacing: 4) {
                                Circle().fill(Color(hex: "#34D399")).frame(width: 6, height: 6)
                                Text("Online · Analyzing your portfolio")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }

                    Spacer()

                    Button {
                        messages = ChatMessage.initialMessages
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 52)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 130)
    }

    // MARK: - Chat Area

    func chatArea() -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Quick actions
                    if messages.count <= 2 {
                        quickActions()
                    }

                    ForEach(messages) { msg in
                        ChatBubble(message: msg)
                            .id(msg.id)
                    }

                    if isThinking {
                        ThinkingBubble()
                            .id("thinking")
                    }

                    Color.clear.frame(height: 90).id("bottom")
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .onChange(of: messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: isThinking) { _, _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Quick Actions

    func quickActions() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick questions")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .textCase(.uppercase)
                .kerning(1.3)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickPrompts, id: \.self) { prompt in
                        Button {
                            sendMessage(prompt)
                        } label: {
                            Text(prompt)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.85))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(.white.opacity(0.08))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    let quickPrompts = [
        "How is my portfolio doing?",
        "What's my biggest winner?",
        "Am I diversified?",
        "Any risks I should know?",
        "Best stock to add now?"
    ]

    // MARK: - Input Bar

    func inputBar() -> some View {
        VStack(spacing: 0) {
            Divider().overlay(Color.white.opacity(0.08))
            HStack(spacing: 12) {
                TextField("Ask anything about your portfolio...", text: $input, axis: .vertical)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .tint(Color(hex: "#7B6FEF"))
                    .lineLimit(1...4)
                    .focused($inputFocused)
                    .onSubmit { sendCurrentInput() }

                Button {
                    sendCurrentInput()
                } label: {
                    Image(systemName: input.isEmpty ? "waveform" : "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(input.isEmpty ? .white.opacity(0.4) : .white)
                        .frame(width: 38, height: 38)
                        .background(input.isEmpty ? Color.white.opacity(0.08) : Color(hex: "#5B5BD6"))
                        .clipShape(Circle())
                }
                .disabled(input.isEmpty || isThinking)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "#1A0B3B"))
            .padding(.bottom, safeAreaBottom)
        }
    }

    var safeAreaBottom: CGFloat {
        #if os(iOS)
        (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0)
        #else
        0
        #endif
    }

    // MARK: - Actions

    func sendCurrentInput() {
        guard !input.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        sendMessage(input)
    }

    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !isThinking else { return }

        // Pro gate: 3 free messages lifetime
        if !appState.settings.isPro {
            if appState.settings.aiMessagesUsed >= 3 {
                showPaywall = true
                return
            }
            appState.settings.aiMessagesUsed += 1
            appState.saveSettings()
        }

        messages.append(.init(role: .user, text: trimmed))
        input = ""
        isThinking = true
        Task {
            try? await Task.sleep(for: .seconds(Double.random(in: 1.2...2.5)))
            let reply = generateReply(to: trimmed, appState: appState)
            messages.append(.init(role: .ai, text: reply))
            isThinking = false
        }
    }

    func generateReply(to query: String, appState: AppState) -> String {
        let q = query.lowercased()
        let totalVal = appState.totalValue
        let pnl = appState.totalPnl
        let pnlPct = appState.totalPnlPct
        let positions = appState.positions

        if q.contains("portfolio") || q.contains("doing") || q.contains("how") {
            if positions.isEmpty {
                return "Your portfolio is empty. Add some positions and I'll analyze them for you! 📊"
            }
            let sign = pnl >= 0 ? "up" : "down"
            return "Your portfolio is \(sign) \(String(format: "%.1f", abs(pnlPct)))% overall (\(pnl.fmtPrice())). You hold \(positions.count) position\(positions.count == 1 ? "" : "s") worth \(totalVal.fmtPrice()) total. \(pnl >= 0 ? "You're in profit — great job! 🚀" : "Market conditions are tough, but long-term investors stay patient. 💪")"
        }

        if q.contains("winner") || q.contains("best") && q.contains("stock") {
            if positions.isEmpty { return "Add some positions first and I'll find your biggest winners! 🏆" }
            let best = positions.max(by: { a, b in
                let pa = appState.quotes[a.ticker]?.changePercent ?? 0
                let pb = appState.quotes[b.ticker]?.changePercent ?? 0
                return pa < pb
            })
            if let b = best {
                let pct = appState.quotes[b.ticker]?.changePercent ?? 0
                return "Your best performer today is **\(b.ticker)** with \(pct.fmtPct()) change. \(pct > 0 ? "Nice gain! 🔥" : "Hang in there, it'll bounce back.")"
            }
        }

        if q.contains("diversif") {
            if positions.isEmpty { return "You don't have any positions yet. Diversification starts when you add at least 5–10 different stocks across sectors! 🎯" }
            let count = positions.count
            if count < 3 {
                return "With only \(count) position\(count == 1 ? "" : "s"), you're quite concentrated. Consider spreading across 5–10 different sectors to reduce risk. 📊"
            } else if count < 7 {
                return "You have \(count) positions — decent start! For better diversification, aim for 8–15 positions across different sectors like tech, healthcare, finance, and energy. 💡"
            } else {
                return "With \(count) positions, you're well-diversified! Just make sure no single position exceeds 20% of your portfolio. ✅"
            }
        }

        if q.contains("risk") {
            if positions.isEmpty { return "No positions to analyze yet! Once you add stocks, I'll assess your risk profile. 🛡️" }
            return "Key risks to watch: 1) Concentration risk if any stock > 20% of portfolio, 2) Sector overlap (holding too many stocks in the same industry), and 3) Macro risks like interest rate changes. I recommend reviewing your allocation monthly. 🎯"
        }

        if q.contains("add") || q.contains("buy") {
            return "Based on current market trends, strong picks include: **NVDA** (AI infrastructure boom), **BRK.B** (value/stability), **VTI** (broad market ETF). Always do your own research and never invest more than you can afford to lose. 📈"
        }

        let replies = [
            "That's a great question! Based on your portfolio data, I'd recommend reviewing your position sizes and ensuring no single stock exceeds 20% of your total value. 💼",
            "I'm analyzing your portfolio patterns... Diversification looks key here. Consider adding exposure to different sectors. 📊",
            "Great insight! The market is always full of opportunities for patient investors. Stay focused on fundamentals. 🎯",
            "Based on current market conditions, maintaining a balanced approach between growth and value stocks is wise. 💡",
            "Your portfolio health score depends on diversification, position sizing, and your investment timeline. Tell me more about your goals! 🚀"
        ]
        return replies.randomElement() ?? replies[0]
    }
}

// MARK: - Models

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let text: String
    let timestamp = Date()

    enum Role { case user, ai }

    static let initialMessages: [ChatMessage] = [
        .init(role: .ai, text: "Hey! I'm STALK AI, your personal portfolio analyst. 👋\n\nI can help you understand your investments, spot risks, and find opportunities. What would you like to know?")
    ]
}

// MARK: - Chat Bubble

struct ChatBubble: View {
    let message: ChatMessage

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if isUser { Spacer(minLength: 60) }

            if !isUser {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "#7B6FEF"), Color(hex: "#5B5BD6")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 32, height: 32)
                    Text("🤖").font(.system(size: 15))
                }
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isUser ? .white : .white.opacity(0.9))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if isUser {
                                AnyView(LinearGradient(
                                    colors: [Color(hex: "#5B5BD6"), Color(hex: "#7B6FEF")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                            } else {
                                AnyView(Color.white.opacity(0.07))
                            }
                        }
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: isUser ? 20 : 20)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(isUser ? 0 : 0.08), lineWidth: 1)
                    )

                Text(timeString(message.timestamp))
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.3))
            }

            if !isUser { Spacer(minLength: 60) }
        }
    }

    func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

// MARK: - Thinking Bubble

struct ThinkingBubble: View {
    @State private var dots = 0
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(hex: "#7B6FEF"), Color(hex: "#5B5BD6")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 32, height: 32)
                Text("🤖").font(.system(size: 15))
            }

            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.white.opacity(dots == i ? 0.8 : 0.25))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: dots)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))

            Spacer(minLength: 60)
        }
        .onReceive(timer) { _ in
            dots = (dots + 1) % 3
        }
    }
}
