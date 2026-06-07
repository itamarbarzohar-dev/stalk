import SwiftUI

struct PortfolioView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void
    let onAdd: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                PortfolioHero()
                    .padding(.bottom, 12)

                if !appState.positions.isEmpty {
                    AIAgentCard()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 8)

                    VsFriendsCard()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 8)
                }

                PositionsList(onTicker: onTicker)
                    .padding(.horizontal, 14)

                Color.clear.frame(height: 100)
            }
        }
        .background(Theme.bg)
        .overlay(alignment: .bottomLeading) {
            if appState.positions.isEmpty || appState.selectedTab == .portfolio {
                AddFAB(action: onAdd)
                    .padding(.leading, 20)
                    .padding(.bottom, 88)
            }
        }
        .task {
            await appState.refreshPortfolio()
        }
        .refreshable {
            await appState.refreshPortfolio()
        }
    }
}

// MARK: - Hero

struct PortfolioHero: View {
    @Environment(AppState.self) var appState

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#4B4ACF"), Color(hex: "#7B6FEF"), Color(hex: "#B8AAFF")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("STALK")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(.white.opacity(0.9))
                        .kerning(5)

                    Spacer()

                    Text("📋 Daily Brief")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.18))
                        .clipShape(Capsule())

                    Button {
                        appState.showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.18))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 20)

                Text("Total Portfolio Value")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))

                Text(appState.totalValue.fmtPrice())
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.6)

                if appState.totalCost > 0 {
                    HStack(spacing: 8) {
                        let isGain = appState.totalPnl >= 0
                        Text("\(isGain ? "+" : "")$\(String(format: "%.2f", appState.totalPnl))  \(appState.totalPnlPct.fmtPct())")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(isGain ? .white.opacity(0.2) : Color(hex: "#E5534B").opacity(0.35))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 8)

                    HStack(spacing: 12) {
                        pill("Today", appState.todayPnlPct.fmtPct())
                        pill("vs S&P", "+\(String(format: "%.1f", appState.totalPnlPct / 12))% ahead")
                    }
                    .padding(.top, 12)
                }

                if !appState.positions.isEmpty {
                    AllocBar()
                        .padding(.top, 14)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 52)
            .padding(.bottom, 24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
        .overlay(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 32)
                .fill(Theme.bg)
                .frame(height: 32)
                .offset(y: 16)
        }
    }

    func pill(_ label: String, _ value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .foregroundStyle(.white)
                .fontWeight(.bold)
        }
        .font(.system(size: 12, weight: .semibold))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Alloc Bar

struct AllocBar: View {
    @Environment(AppState.self) var appState

    var body: some View {
        let tv = appState.totalValue
        HStack(spacing: 2) {
            ForEach(Array(appState.positions.enumerated()), id: \.element.id) { i, p in
                let price = appState.quotes[p.ticker]?.price ?? p.avgCost
                let pct = tv > 0 ? (price * p.shares / tv) : 0
                Theme.allocColors[i % Theme.allocColors.count]
                    .frame(height: 5)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(x: pct, anchor: .leading)
                    .clipShape(Capsule())
            }
        }
        .frame(height: 5)
    }
}

// MARK: - Positions List

struct PositionsList: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void

    var body: some View {
        if appState.positions.isEmpty {
            VStack(spacing: 12) {
                Text("No positions yet.")
                    .font(.system(size: 16))
                Text("Tap + to add your first stock.")
                    .font(.system(size: 16))
            }
            .foregroundStyle(Theme.text3)
            .padding(60)
            .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: 10) {
                ForEach(appState.positions) { position in
                    PositionCard(position: position, onTap: { onTicker(position.ticker) })
                }

                Text("Long-press a card to delete")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.text3)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - Position Card

struct PositionCard: View {
    @Environment(AppState.self) var appState
    let position: Position
    let onTap: () -> Void
    @State private var pressing = false

    var quote: Quote? { appState.quotes[position.ticker] }
    var price: Double { quote?.price ?? position.avgCost }
    var value: Double { price * position.shares }
    var cost: Double { position.avgCost * position.shares }
    var pnl: Double { value - cost }
    var pnlPct: Double { cost > 0 ? (pnl / cost) * 100 : 0 }
    var isUp: Bool { pnl >= 0 }
    var dayIsUp: Bool { (quote?.change ?? 0) >= 0 }

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(position.ticker)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.text)

                    Text("\(isUp ? "▲" : "▼") \(String(format: "%.1f", abs(pnlPct)))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(isUp ? Theme.gain : Theme.loss)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(isUp ? Theme.gainBg : Theme.lossBg)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                if let name = quote?.name {
                    Text(name)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                }

                Text("\(String(format: "%.4g", position.shares)) shares · avg \(position.avgCost.fmtPrice())")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.accent2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(value.fmtPrice())
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.text)

                Text(pnl.fmtChange())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isUp ? Theme.gain : Theme.loss)

                if let q = quote {
                    Text("Today \(q.changePercent.fmtPct())")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(dayIsUp ? Theme.gain : Theme.loss)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
        .scaleEffect(pressing ? 0.98 : 1)
        .animation(.easeInOut(duration: 0.1), value: pressing)
        .onTapGesture { onTap() }
        .onLongPressGesture(minimumDuration: 0.6) {
            appState.deletePosition(position)
        } onPressingChanged: { pressing = $0 }
    }
}

// MARK: - AI Agent Card

struct AIAgentCard: View {
    @Environment(AppState.self) var appState
    @State private var quickInput = ""
    @State private var aiResponse: String? = nil
    @State private var isThinking = false

    var body: some View {
        let ret = appState.totalPnlPct
        let grade = ret > 30 ? "A" : ret > 15 ? "B" : ret > 0 ? "C" : "D"
        let gradeColor: Color = grade == "A" ? Color(hex: "#4ADE80") : grade == "B" ? Color(hex: "#FACC15") : Color(hex: "#FB923C")

        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1E1B4B"), Color(hex: "#2D2B6B"), Color(hex: "#1E1B4B")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Text("🤖")
                        .font(.system(size: 20))
                        .frame(width: 44, height: 44)
                        .background(
                            LinearGradient(colors: [Color(hex: "#818CF8"), Color(hex: "#C4B5FD")],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 1) {
                        Text("STALK AI")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Analyzing your portfolio in real-time")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.55))
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: "#4ADE80"))
                            .frame(width: 7, height: 7)
                        Text("Live")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "#4ADE80"))
                            .textCase(.uppercase)
                            .kerning(0.5)
                    }
                }
                .padding(.bottom, 16)

                // Score row
                HStack(spacing: 10) {
                    scoreCard(value: grade, label: "Health Score", color: gradeColor)
                    scoreCard(value: "\(ret >= 0 ? "+" : "")\(String(format: "%.1f", ret))%",
                              label: "All Time Return",
                              color: ret >= 0 ? Color(hex: "#4ADE80") : Color(hex: "#F87171"))
                    scoreCard(value: "#2", label: "Friends Rank", color: Color(hex: "#FACC15"))
                }
                .padding(.bottom, 16)

                // Insights
                aiInsight(icon: "💡", tag: "BUY SIGNAL", tagColor: Color(hex: "#4ADE80"),
                          text: "AI detects strong momentum in your top position. Earnings catalyst expected next week.")
                aiInsight(icon: "⚠️", tag: "RISK ALERT", tagColor: Color(hex: "#FB923C"),
                          text: "Portfolio concentration is MEDIUM. Consider diversifying to 8-10 positions.")
                aiInsight(icon: "🏆", tag: "MILESTONE", tagColor: Color(hex: "#FACC15"),
                          text: "You've beaten the S&P 500 by \(String(format: "%.1f", ret / 12))% this year. Top 6% of all STALK investors.")

                // Quick input
                HStack(spacing: 8) {
                    TextField("Ask AI: 'Should I buy more META?'", text: $quickInput)
                        .font(.system(size: 13))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.1))
                        .overlay(
                            Capsule().stroke(.white.opacity(0.15), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                        .tint(.white)
                        .onSubmit { sendQuickAI() }

                    Button { sendQuickAI() } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 38, height: 38)
                            .background(
                                LinearGradient(colors: [Color(hex: "#818CF8"), Color(hex: "#C4B5FD")],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 14)

                if isThinking {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(.white.opacity(0.5))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.top, 8)
                }

                if let response = aiResponse {
                    Text("🤖 \(response)")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineSpacing(4)
                        .padding(12)
                        .background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.top, 8)
                }

                // Open full chat
                Button {
                    appState.showAIChat = true
                } label: {
                    HStack(spacing: 6) {
                        Text("Open Full AI Chat")
                            .font(.system(size: 13, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.1), lineWidth: 1))
                }
                .padding(.top, 12)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    func scoreCard(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)
                .kerning(0.5)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.white.opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.1), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    func aiInsight(icon: String, tag: String, tagColor: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon).font(.system(size: 16))
            VStack(alignment: .leading, spacing: 4) {
                Text(tag)
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(tagColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(tagColor.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(text)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineSpacing(2)
            }
        }
        .padding(12)
        .background(.white.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.08), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.bottom, 8)
    }

    func sendQuickAI() {
        guard !quickInput.isEmpty else { return }
        let q = quickInput.lowercased()
        quickInput = ""
        isThinking = true
        aiResponse = nil
        Task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            isThinking = false
            if q.contains("buy") {
                aiResponse = "NVDA, MSFT, and GOOGL look strong for long-term accumulation. NVDA has AI tailwind catalysts through 2026."
            } else if q.contains("sell") {
                aiResponse = "If your position has exceeded 50%+ gains — taking partial profits (20-30%) reduces drawdown risk while preserving upside."
            } else if q.contains("risk") {
                aiResponse = "Portfolio Risk Score: 7.2/10 (Aggressive). Your concentration creates event risk. Diversifying to 8-10 positions would bring this to 4.5/10."
            } else {
                aiResponse = "Based on your portfolio, you're well-positioned in tech. Consider diversifying into healthcare or energy to reduce sector risk."
            }
        }
    }
}

// MARK: - vs Friends Card

struct VsFriendsCard: View {
    @Environment(AppState.self) var appState
    @State private var period = "YTD"

    let friendsData: [String: [(String, Double)]] = [
        "1D": [("Lena V.", 2.1), ("Alex C.", 1.2), ("Sara K.", -0.3), ("Mike R.", 0.8)],
        "1W": [("Lena V.", 8.4), ("Alex C.", 5.1), ("Sara K.", 3.2), ("Mike R.", 1.9)],
        "1M": [("Lena V.", 14.2), ("Alex C.", 9.8), ("Sara K.", 6.1), ("Mike R.", 3.4)],
        "YTD": [("Lena V.", 41.5), ("Alex C.", 22.1), ("Sara K.", 14.2), ("Mike R.", 7.3)],
        "All": [("Lena V.", 89.2), ("Alex C.", 61.3), ("Sara K.", 38.5), ("Mike R.", 29.1)],
    ]

    let friendColors: [Color] = [
        Color(hex: "#6EE7B7"), Color(hex: "#818CF8"), Color(hex: "#F472B6"), Color(hex: "#FBBF24"),
    ]

    var myReturn: Double {
        let r = appState.totalPnlPct
        switch period {
        case "1D": return r * 0.007
        case "1W": return r * 0.05
        case "1M": return r * 0.12
        case "All": return r * 1.6
        default:   return r
        }
    }

    var allEntries: [(name: String, ret: Double, color: Color, isMe: Bool)] {
        let friends = (friendsData[period] ?? []).enumerated().map { i, f in
            (name: f.0, ret: f.1, color: friendColors[i % friendColors.count], isMe: false)
        }
        return (friends + [(name: "You", ret: myReturn, color: Theme.accent, isMe: true)])
            .sorted { $0.ret > $1.ret }
    }

    var myRank: Int { (allEntries.firstIndex { $0.isMe } ?? 0) + 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("📊 vs Friends")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.text)

                Spacer()

                Text("#\(myRank) \(myRank == 1 ? "👑" : myRank == 2 ? "🥈" : "🥉")")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(myRank == 1 ? LinearGradient(colors: [Color(hex: "#D97706"), Color(hex: "#F59E0B")], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [Color(hex: "#6B7280"), Color(hex: "#9CA3AF")], startPoint: .leading, endPoint: .trailing))
                    .clipShape(Capsule())
            }
            .padding(.bottom, 14)

            // Period picker
            HStack(spacing: 6) {
                ForEach(["1D", "1W", "1M", "YTD", "All"], id: \.self) { p in
                    Button(p) { period = p }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(p == period ? .white : Theme.text3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(p == period ? Theme.accent : Color.clear)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(p == period ? Theme.accent : Theme.border, lineWidth: 1.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.bottom, 14)

            // Leaderboard
            VStack(spacing: 0) {
                ForEach(Array(allEntries.enumerated()), id: \.element.name) { i, entry in
                    HStack(spacing: 10) {
                        Text(i == 0 ? "🥇" : i == 1 ? "🥈" : i == 2 ? "🥉" : "\(i+1)")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(entry.isMe ? Theme.accent : Theme.text3)
                            .frame(width: 24)

                        Circle()
                            .fill(entry.color)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(String(entry.name.prefix(1)))
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundStyle(.white)
                            )

                        Text(entry.name + (entry.isMe ? " ✦" : ""))
                            .font(.system(size: 13, weight: entry.isMe ? .black : .semibold))
                            .foregroundStyle(entry.isMe ? Theme.accent : Theme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        let maxRet = allEntries.map { abs($0.ret) }.max() ?? 1
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Theme.bg2)
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(entry.isMe ? Theme.accentGradient : LinearGradient(colors: [entry.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: max(4, geo.size.width * CGFloat(abs(entry.ret) / maxRet)))
                                }
                        }
                        .frame(width: 80, height: 5)

                        Text("\(entry.ret >= 0 ? "+" : "")\(String(format: "%.1f", entry.ret))%")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(entry.ret >= 0 ? Theme.gain : Theme.loss)
                            .frame(width: 52, alignment: .trailing)
                    }
                    .padding(.vertical, 8)

                    if i < allEntries.count - 1 {
                        Divider()
                            .background(Theme.bg2)
                    }
                }
            }
        }
        .padding(18)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border, lineWidth: 1))
        .shadow(color: Theme.accent.opacity(0.1), radius: 16, y: 4)
    }
}

// MARK: - FAB

struct AddFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Theme.accentGradient)
                .clipShape(Circle())
                .shadow(color: Theme.accent.opacity(0.4), radius: 12, y: 4)
        }
    }
}
