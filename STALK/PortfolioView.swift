import SwiftUI
import Combine

struct PortfolioView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void
    let onAdd: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                PortfolioHero()
                    .padding(.bottom, 8)

                if !appState.positions.isEmpty {
                    AIAgentCard()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 8)

                    PortfolioHealthCard()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 8)

                    VsMarketCard()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 8)

                    VsFriendsCard()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 8)

                    LiveFeedCard()
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
            async let p: () = appState.refreshPortfolio()
            async let m: () = appState.refreshMarket()
            _ = await (p, m)
        }
        .refreshable {
            async let p: () = appState.refreshPortfolio()
            async let m: () = appState.refreshMarket()
            _ = await (p, m)
        }
    }
}

// MARK: - Hero

struct PortfolioHero: View {
    @Environment(AppState.self) var appState
    @State private var now = Date()
    @State private var athPulse = false
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var marketStatus: MarketStatus { MarketCalendar.status(at: now) }
    var isATH: Bool { appState.totalValue > 0 && appState.totalValue >= appState.portfolioATH && appState.portfolioATH > 0 }
    var fromATH: Double { appState.portfolioATH - appState.totalValue }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Top utility bar — settings + daily brief
            HStack(spacing: 10) {
                Text("PORTFOLIO")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Theme.text3)
                    .kerning(2)
                Spacer()
                Button { appState.showDailyBrief = true } label: {
                    HStack(spacing: 5) {
                        Text("📋").font(.system(size: 12))
                        Text("Brief").font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.text2)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Theme.card)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Theme.border, lineWidth: 1))
                }
                Button { appState.showSettings = true } label: {
                    Image(systemName: "gearshape.fill").font(.system(size: 15))
                        .foregroundStyle(Theme.text3)
                        .frame(width: 34, height: 34)
                        .background(Theme.card)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Theme.border, lineWidth: 1))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 52)
            .padding(.bottom, 20)

            // Portfolio value — clean, no gradient box
            VStack(alignment: .leading, spacing: 2) {
                Text(appState.totalValue.fmtPrice())
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(Theme.text)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.totalValue)
                    .minimumScaleFactor(0.45)
                    .lineLimit(1)

                // P&L + market status on one line
                if appState.totalCost > 0 {
                    let isGain = appState.totalPnl >= 0
                    let pnlColor = isGain ? Theme.gain : Theme.loss
                    let pnlSign = isGain ? "+" : ""

                    HStack(spacing: 10) {
                        Text("\(pnlSign)\(appState.totalPnl.fmtPrice()) (\(appState.totalPnlPct.fmtPct())) All-time")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(pnlColor)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.totalPnl)

                        // Market status pill inline
                        HStack(spacing: 5) {
                            Circle().fill(marketStatus.dotColor).frame(width: 6, height: 6)
                                .overlay(
                                    Circle().fill(marketStatus.dotColor.opacity(0.3))
                                        .frame(width: 11, height: 11)
                                        .opacity(marketStatus.isLive ? 1 : 0)
                                )
                            Text(marketStatus.label)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Theme.text3)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Theme.card)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.border, lineWidth: 1))
                    }
                    .padding(.top, 4)

                    // Today P&L + badges
                    HStack(spacing: 8) {
                        let todayIsGain = appState.todayPnl >= 0
                        let todayColor = todayIsGain ? Theme.gain : Theme.loss
                        HStack(spacing: 4) {
                            Text("Today")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.text3)
                            Text(appState.todayPnlPct.fmtPct())
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(todayColor)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(todayColor.opacity(0.10))
                        .clipShape(Capsule())

                        if isATH {
                            HStack(spacing: 4) {
                                Text("🏆")
                                    .font(.system(size: 11))
                                Text("NEW ATH")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundStyle(Theme.gold)
                                    .kerning(0.5)
                            }
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Theme.gold.opacity(0.12))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Theme.gold.opacity(0.3), lineWidth: 1))
                            .scaleEffect(athPulse ? 1.04 : 1.0)
                            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: athPulse)
                            .onAppear { athPulse = true }
                        } else if fromATH > 0 && appState.portfolioATH > 0 {
                            HStack(spacing: 4) {
                                Text("From ATH")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Theme.text3)
                                Text("-\(fromATH.fmtPrice())")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Theme.text2)
                            }
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Theme.card)
                            .clipShape(Capsule())
                        }

                        if appState.streak > 1 {
                            HStack(spacing: 4) {
                                Text("🔥").font(.system(size: 12))
                                Text("\(appState.streak)d").font(.system(size: 12, weight: .black)).foregroundStyle(.white)
                            }
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(LinearGradient(colors: [Color(hex: "#F97316"), Color(hex: "#EA580C")], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            if !appState.positions.isEmpty {
                AllocBar()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 6)
            }
        }
        .background(Theme.bg)
        .onReceive(timer) { now = $0 }
    }
}

// MARK: - Mini Sparkline

struct MiniSparkline: View {
    let points: [Double]  // normalized 0-1 values
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            guard points.count > 1 else { return }
            let step = size.width / CGFloat(points.count - 1)
            var path = Path()
            path.move(to: CGPoint(x: 0, y: size.height * (1 - points[0])))
            for i in 1..<points.count {
                path.addLine(to: CGPoint(x: CGFloat(i) * step, y: size.height * (1 - points[i])))
            }
            ctx.stroke(path, with: .color(color), lineWidth: 1.5)
        }
        .frame(width: 44, height: 22)
    }
}

// Returns a deterministic pseudo-random sparkline seeded from the ticker string
private func sparklinePoints(ticker: String, trending: Bool) -> [Double] {
    var seed = ticker.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
    func nextRand() -> Double {
        seed = seed &* 1664525 &+ 1013904223
        return Double(seed & 0x7FFFFFFF) / Double(0x7FFFFFFF)
    }
    var vals: [Double] = [nextRand()]
    for _ in 1..<8 {
        let delta = (nextRand() - 0.5) * 0.25
        vals.append(max(0.05, min(0.95, vals.last! + delta)))
    }
    // Normalize to 0-1
    let lo = vals.min()!
    let hi = vals.max()!
    let range = max(hi - lo, 0.001)
    return vals.map { ($0 - lo) / range }
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
                ForEach(Array(appState.positions.enumerated()), id: \.element.id) { index, position in
                    PositionCard(position: position, onTap: { onTicker(position.ticker) })
                        .staggerEntrance(index: index)
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
    @State private var showAlertSheet = false
    @State private var showDeleteConfirm = false

    var quote: Quote? { appState.quotes[position.ticker] }
    var price: Double { quote?.price ?? position.avgCost }
    var value: Double { price * position.shares }
    var cost: Double { position.avgCost * position.shares }
    var pnl: Double { value - cost }
    var pnlPct: Double { cost > 0 ? (pnl / cost) * 100 : 0 }
    var isUp: Bool { pnl >= 0 }
    var dayIsUp: Bool { (quote?.change ?? 0) >= 0 }
    var hasAlert: Bool {
        appState.settings.alertThresholds.contains { $0.ticker == position.ticker }
    }

    var body: some View {
        let sparkColor = isUp ? Theme.gain : Theme.loss
        let sparkPoints = sparklinePoints(ticker: position.ticker, trending: isUp)

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

                    if EARNINGS.contains(where: { $0.ticker == position.ticker }) {
                        Text("EARNINGS")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "#F59E0B"))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }

                    if hasAlert {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "#7B6FEF"))
                    }
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

            // Sparkline + price stack
            ZStack(alignment: .trailing) {
                // Subtle sparkline behind numbers
                MiniSparkline(points: sparkPoints, color: sparkColor.opacity(0.55))
                    .offset(x: 0, y: -2)

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
            showDeleteConfirm = true
        } onPressingChanged: { pressing = $0 }
        .contextMenu {
            Button {
                showAlertSheet = true
            } label: {
                Label("Set Price Alert", systemImage: "bell")
            }
            Button(role: .destructive) {
                appState.deletePosition(position)
            } label: {
                Label("Delete Position", systemImage: "trash")
            }
        }
        .confirmationDialog("Delete \(position.ticker)?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                appState.deletePosition(position)
            }
            Button("Set Price Alert") {
                showAlertSheet = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Long-press actions for \(position.ticker)")
        }
        .sheet(isPresented: $showAlertSheet) {
            PriceAlertSheet(position: position)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Price Alert Sheet

struct PriceAlertSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    let position: Position

    @State private var aboveText = ""
    @State private var belowText = ""

    var existingThreshold: PriceAlertThreshold? {
        appState.settings.alertThresholds.first { $0.ticker == position.ticker }
    }

    var currentPrice: Double {
        appState.quotes[position.ticker]?.price ?? position.avgCost
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(Theme.border)
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                // Title
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Price Alerts")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(Theme.text)
                        Text("\(position.ticker) · Current: \(currentPrice.fmtPrice())")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.text3)
                    }
                    Spacer()
                    if existingThreshold != nil {
                        Button {
                            appState.settings.alertThresholds.removeAll { $0.ticker == position.ticker }
                            appState.saveSettings()
                            dismiss()
                        } label: {
                            Text("Clear")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.loss)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

                // Fields
                VStack(spacing: 16) {
                    alertField(
                        icon: "arrow.up.circle.fill",
                        iconColor: Theme.gain,
                        label: "Alert me above",
                        placeholder: "e.g. \(String(format: "%.2f", currentPrice * 1.1))",
                        text: $aboveText
                    )

                    alertField(
                        icon: "arrow.down.circle.fill",
                        iconColor: Theme.loss,
                        label: "Alert me below",
                        placeholder: "e.g. \(String(format: "%.2f", currentPrice * 0.9))",
                        text: $belowText
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Save button
                Button {
                    saveAlerts()
                } label: {
                    Text("Save Alerts")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Theme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .onAppear {
            if let t = existingThreshold {
                aboveText = t.alertAbove.map { String(format: "%.2f", $0) } ?? ""
                belowText = t.alertBelow.map { String(format: "%.2f", $0) } ?? ""
            }
        }
    }

    func alertField(icon: String, iconColor: Color, label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(iconColor)
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.text2)
            }

            HStack(spacing: 10) {
                Text("$")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.text3)
                TextField(placeholder, text: text)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.text)
                    .tint(Theme.accent)
                    .keyboardType(.decimalPad)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.border, lineWidth: 1)
            )
        }
    }

    func saveAlerts() {
        let above = Double(aboveText.replacingOccurrences(of: ",", with: "."))
        let below = Double(belowText.replacingOccurrences(of: ",", with: "."))

        guard above != nil || below != nil else {
            dismiss()
            return
        }

        appState.settings.alertThresholds.removeAll { $0.ticker == position.ticker }
        let threshold = PriceAlertThreshold(ticker: position.ticker, alertAbove: above, alertBelow: below)
        appState.settings.alertThresholds.append(threshold)
        appState.saveSettings()
        dismiss()
    }
}

// MARK: - AI Agent Card

struct AIAgentCard: View {
    @Environment(AppState.self) var appState
    @State private var quickInput = ""
    @State private var aiResponse: String? = nil
    @State private var isThinking = false

    // MARK: Real portfolio analysis

    var healthScore: (grade: String, color: Color) {
        let n = appState.positions.count
        let pnl = appState.totalPnlPct
        var pts = 0
        pts += min(40, n * 5)
        if pnl > 30 { pts += 40 } else if pnl > 15 { pts += 32 } else if pnl > 0 { pts += 20 } else if pnl > -10 { pts += 8 }
        if n > 0 { pts += 20 }
        if pts >= 80 { return ("A", Color(hex: "#4ADE80")) }
        if pts >= 60 { return ("B", Color(hex: "#A3E635")) }
        if pts >= 40 { return ("C", Color(hex: "#FACC15")) }
        return ("D", Color(hex: "#FB923C"))
    }

    func positionPnlPct(_ p: Position) -> Double {
        let price = appState.quotes[p.ticker]?.price ?? p.avgCost
        return p.avgCost > 0 ? ((price - p.avgCost) / p.avgCost) * 100 : 0
    }

    var bestPosition: Position? {
        appState.positions.max { positionPnlPct($0) < positionPnlPct($1) }
    }
    var worstPosition: Position? {
        appState.positions.min { positionPnlPct($0) < positionPnlPct($1) }
    }
    var biggestPosition: (ticker: String, pct: Double)? {
        guard let p = appState.positions.max(by: {
            let va = (appState.quotes[$0.ticker]?.price ?? $0.avgCost) * $0.shares
            let vb = (appState.quotes[$1.ticker]?.price ?? $1.avgCost) * $1.shares
            return va < vb
        }), appState.totalValue > 0 else { return nil }
        let val = (appState.quotes[p.ticker]?.price ?? p.avgCost) * p.shares
        return (p.ticker, val / appState.totalValue * 100)
    }

    // MARK: Body

    var body: some View {
        let hs = healthScore
        let ret = appState.totalPnlPct
        let todayPct = appState.todayPnlPct

        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1A1040"), Color(hex: "#2D1B6E"), Color(hex: "#1A1040")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "#818CF8"), Color(hex: "#C4B5FD")],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 44, height: 44)
                        Text("🤖").font(.system(size: 22))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("STALK AI").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                        Text("Analyzing \(appState.positions.count) position\(appState.positions.count == 1 ? "" : "s") in real-time")
                            .font(.system(size: 11)).foregroundStyle(.white.opacity(0.55))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Circle().fill(Color(hex: "#4ADE80")).frame(width: 7, height: 7)
                        Text("Live").font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "#4ADE80")).textCase(.uppercase).kerning(0.5)
                    }
                }
                .padding(.bottom, 16)

                // Score grid — 2×2 for breathing room
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    scoreCard(value: hs.grade, label: "Health Score", color: hs.color)
                    scoreCard(value: ret.fmtPct(), label: "All-Time Return", color: ret >= 0 ? Color(hex: "#4ADE80") : Color(hex: "#F87171"))
                    scoreCard(value: todayPct.fmtPct(), label: "Today's P&L", color: todayPct >= 0 ? Color(hex: "#4ADE80") : Color(hex: "#F87171"))
                    scoreCard(value: "\(appState.positions.count)", label: "Positions", color: Color(hex: "#818CF8"))
                }
                .padding(.bottom, 16)

                // Real insights based on actual data
                if let best = bestPosition {
                    let pct = positionPnlPct(best)
                    aiInsight(icon: "🚀", tag: "TOP PERFORMER", tagColor: Color(hex: "#4ADE80"),
                              text: "\(best.ticker) leads your portfolio at \(pct.fmtPct()). \(pct > 50 ? "Consider taking partial profits to lock in gains." : "Strong momentum — let winners run.")")
                }

                if let worst = worstPosition, positionPnlPct(worst) < -5 {
                    aiInsight(icon: "⚠️", tag: "WATCH", tagColor: Color(hex: "#FB923C"),
                              text: "\(worst.ticker) is down \(abs(positionPnlPct(worst)).fmtPct()). Review your thesis or set a stop-loss to protect capital.")
                }

                if let big = biggestPosition, big.pct > 30 {
                    aiInsight(icon: "📊", tag: "CONCENTRATION RISK", tagColor: Color(hex: "#FACC15"),
                              text: "\(big.ticker) is \(String(format: "%.0f", big.pct))% of your portfolio. Rebalancing would reduce single-stock risk.")
                } else if appState.positions.count < 5 {
                    aiInsight(icon: "💡", tag: "DIVERSIFY", tagColor: Color(hex: "#818CF8"),
                              text: "You hold \(appState.positions.count) position\(appState.positions.count == 1 ? "" : "s"). Target 8–12 stocks across different sectors to reduce risk.")
                } else {
                    aiInsight(icon: "✅", tag: "WELL DIVERSIFIED", tagColor: Color(hex: "#4ADE80"),
                              text: "\(appState.positions.count) positions across your portfolio. \(ret > 0 ? "Positive returns — stay the course." : "Market is tough. Patient investors are rewarded long-term.")")
                }

                // Quick chat input
                HStack(spacing: 8) {
                    TextField("Ask: 'Should I buy more AAPL?'", text: $quickInput)
                        .font(.system(size: 13)).foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(.white.opacity(0.1))
                        .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 1))
                        .clipShape(Capsule()).tint(.white)
                        .onSubmit { sendQuickAI() }

                    Button { sendQuickAI() } label: {
                        Image(systemName: "arrow.up").font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white).frame(width: 38, height: 38)
                            .background(LinearGradient(colors: [Color(hex: "#818CF8"), Color(hex: "#C4B5FD")],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 14)

                if isThinking {
                    HStack(spacing: 5) {
                        ForEach(0..<3, id: \.self) { _ in Circle().fill(.white.opacity(0.5)).frame(width: 6, height: 6) }
                    }.padding(.top, 8)
                }

                if let response = aiResponse {
                    Text("🤖 \(response)")
                        .font(.system(size: 13)).foregroundStyle(.white.opacity(0.9)).lineSpacing(4)
                        .padding(12).background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14)).padding(.top, 8)
                }

                Button { appState.showAIChat = true } label: {
                    HStack(spacing: 6) {
                        Text("Open Full AI Chat").font(.system(size: 13, weight: .bold))
                        Image(systemName: "arrow.right").font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(.white.opacity(0.7)).frame(maxWidth: .infinity)
                    .padding(.vertical, 12).background(.white.opacity(0.07))
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
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 26, weight: .black))
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.45))
                .textCase(.uppercase)
                .kerning(0.4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(.white.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.1), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    func aiInsight(icon: String, tag: String, tagColor: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon).font(.system(size: 16))
            VStack(alignment: .leading, spacing: 4) {
                Text(tag).font(.system(size: 10, weight: .black)).foregroundStyle(tagColor)
                    .padding(.horizontal, 8).padding(.vertical, 2)
                    .background(tagColor.opacity(0.2)).clipShape(RoundedRectangle(cornerRadius: 8))
                Text(text).font(.system(size: 12, weight: .medium)).foregroundStyle(.white.opacity(0.85)).lineSpacing(2)
            }
        }
        .padding(12).background(.white.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.08), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14)).padding(.bottom, 8)
    }

    func sendQuickAI() {
        guard !quickInput.isEmpty else { return }
        let q = quickInput.lowercased()
        quickInput = ""; isThinking = true; aiResponse = nil
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            isThinking = false
            if q.contains("buy") || q.contains("add") {
                aiResponse = "NVDA, MSFT, and GOOGL show strong momentum. NVDA has an AI catalyst runway through 2026. Always size new positions at 5-10% max."
            } else if q.contains("sell") {
                if let w = worstPosition, positionPnlPct(w) < -10 {
                    aiResponse = "\(w.ticker) is down \(abs(positionPnlPct(w)).fmtPct()). If your thesis changed, cutting losses protects capital. Otherwise hold and review on next earnings."
                } else if let b = bestPosition, positionPnlPct(b) > 50 {
                    aiResponse = "\(bestPosition!.ticker) is up \(positionPnlPct(bestPosition!).fmtPct()). Consider trimming 20-30% to lock in gains while keeping exposure."
                } else {
                    aiResponse = "No strong sell signals. Your portfolio looks healthy. Hold quality positions and let compound growth work."
                }
            } else if q.contains("risk") {
                let conc = biggestPosition?.pct ?? 0
                aiResponse = "Concentration risk: \(conc > 40 ? "HIGH" : conc > 25 ? "MEDIUM" : "LOW") (\(String(format: "%.0f", conc))% in top position). \(appState.positions.count < 5 ? "Add more positions to reduce single-stock risk." : "Good spread across \(appState.positions.count) stocks.")"
            } else if q.contains("best") || q.contains("winner") || q.contains("top") {
                if let b = bestPosition {
                    aiResponse = "\(b.ticker) is your top performer at \(positionPnlPct(b).fmtPct()). Strong conviction play — consider holding unless it exceeds 25% of your portfolio."
                }
            } else {
                aiResponse = "Portfolio value: \(appState.totalValue.fmtPrice()), all-time return: \(appState.totalPnlPct.fmtPct()), today: \(appState.todayPnlPct.fmtPct()). \(appState.totalPnlPct > 0 ? "You're in profit — solid work." : "Markets cycle. Stay patient and avoid panic selling.")"
            }
        }
    }
}

// MARK: - vs Market Card

struct VsMarketCard: View {
    @Environment(AppState.self) var appState
    @State private var period = "1D"

    let indices: [(ticker: String, name: String, icon: String)] = [
        ("SPY", "S&P 500",    "🇺🇸"),
        ("QQQ", "NASDAQ 100", "💻"),
        ("DIA", "Dow Jones",  "🏦"),
    ]

    func myReturn() -> Double {
        switch period {
        case "1D":  return appState.todayPnlPct
        case "1W":  return appState.totalPnlPct * 0.06
        case "1M":  return appState.totalPnlPct * 0.14
        case "YTD": return appState.totalPnlPct
        default:    return appState.totalPnlPct
        }
    }

    func marketReturn(_ ticker: String) -> Double {
        let daily = appState.marketQuotes[ticker]?.changePercent ?? 0
        switch period {
        case "1D":  return daily
        case "1W":  return daily * 5
        case "1M":  return daily * 21
        case "YTD": return daily * 130 * 0.28
        default:    return daily
        }
    }

    var isBeating: Bool {
        let my = myReturn()
        return indices.allSatisfy { my > marketReturn($0.ticker) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("📈 vs Market")
                        .font(.system(size: 15, weight: .bold)).foregroundStyle(Theme.text)
                    Text("How you stack up against major indices")
                        .font(.system(size: 11)).foregroundStyle(Theme.text3)
                }
                Spacer()
                Text(isBeating ? "🔥 Outperforming" : "📊 Tracking")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isBeating ? Theme.gain : Theme.text3)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(isBeating ? Theme.gainBg : Theme.bg2)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 14)

            // Period picker
            HStack(spacing: 6) {
                ForEach(["1D", "1W", "1M", "YTD"], id: \.self) { p in
                    Button(p) { period = p }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(p == period ? .white : Theme.text3)
                        .frame(maxWidth: .infinity).padding(.vertical, 6)
                        .background(p == period ? appState.accentColor : Color.clear)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(p == period ? appState.accentColor : Theme.border, lineWidth: 1.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.bottom, 16)

            // Rows
            let my = myReturn()
            let allVals = ([my] + indices.map { marketReturn($0.ticker) }).map { abs($0) }
            let maxVal = max(allVals.max() ?? 1, 0.01)

            compRow(icon: "💼", name: "My Portfolio", ret: my, color: appState.accentColor, isMe: true, maxVal: maxVal)

            ForEach(indices, id: \.ticker) { idx in
                Divider().padding(.vertical, 10)
                compRow(icon: idx.icon, name: idx.name, ret: marketReturn(idx.ticker),
                        color: Color(hex: "#64748B"), isMe: false, maxVal: maxVal)
            }

            if period != "1D" {
                Text("Non-daily figures are estimated from your all-time return")
                    .font(.system(size: 10)).foregroundStyle(Theme.text3).padding(.top, 12)
            }
        }
        .padding(18)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    func compRow(icon: String, name: String, ret: Double, color: Color, isMe: Bool, maxVal: Double) -> some View {
        HStack(spacing: 10) {
            Text(icon).font(.system(size: 18)).frame(width: 26)
            Text(name)
                .font(.system(size: 13, weight: isMe ? .black : .semibold))
                .foregroundStyle(isMe ? appState.accentColor : Theme.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Theme.bg2).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ret >= 0
                              ? (isMe ? AnyShapeStyle(appState.accentGradient) : AnyShapeStyle(Theme.gain))
                              : AnyShapeStyle(Theme.loss))
                        .frame(width: max(4, geo.size.width * CGFloat(abs(ret) / maxVal)), height: 6)
                }
            }
            .frame(width: 80, height: 6)

            Text(ret.fmtPct())
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(ret >= 0 ? Theme.gain : Theme.loss)
                .frame(width: 58, alignment: .trailing)
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

// MARK: - Live Feed Card

struct LiveFeedCard: View {
    @Environment(AppState.self) var appState
    @State private var visibleCount = 4

    struct FeedEvent: Identifiable {
        let id = UUID()
        let icon: String
        let text: String
        let sub: String
        let accent: Color
    }

    var events: [FeedEvent] {
        var items: [FeedEvent] = []

        // Portfolio-aware events
        let bigMover = appState.positions
            .max { abs(appState.quotes[$0.ticker]?.changePercent ?? 0) < abs(appState.quotes[$1.ticker]?.changePercent ?? 0) }
        if let m = bigMover, let q = appState.quotes[m.ticker] {
            let up = q.changePercent >= 0
            items.append(FeedEvent(icon: up ? "🔥" : "📉",
                text: "\(m.ticker) is your biggest mover today",
                sub: "\(q.changePercent.fmtPct()) · \(up ? "riding the wave" : "dragging today's P&L")",
                accent: up ? Theme.gain : Theme.loss))
        }

        // Social proof
        let socialTickers = [("NVDA", 1243), ("AAPL", 890), ("TSLA", 734), ("META", 612)]
        for p in appState.positions.prefix(2) {
            if let entry = socialTickers.first(where: { $0.0 == p.ticker }) {
                items.append(FeedEvent(icon: "👥",
                    text: "\(entry.1) other STALK users hold \(p.ticker)",
                    sub: "You're in good company",
                    accent: Color(hex: "#8B7CF6")))
            }
        }

        // Market beat
        if appState.todayPnlPct > 0.5 {
            items.append(FeedEvent(icon: "⚡",
                text: "You're beating SPY today",
                sub: "Portfolio +\(appState.todayPnlPct.fmtPct()) vs SPY \((appState.marketQuotes["SPY"]?.changePercent ?? 0).fmtPct())",
                accent: Theme.gain))
        }

        // ATH
        if appState.portfolioATH > 0 && appState.totalValue >= appState.portfolioATH {
            items.append(FeedEvent(icon: "🏆",
                text: "New all-time high!",
                sub: "Portfolio just hit \(appState.totalValue.fmtPrice()) — your best ever",
                accent: Color(hex: "#F59E0B")))
        }

        // Streak
        if appState.streak >= 3 {
            items.append(FeedEvent(icon: "🔥",
                text: "\(appState.streak)-day check-in streak",
                sub: "You're in the top 12% of active STALKers",
                accent: Color(hex: "#F97316")))
        }

        // Static FOMO events
        items.append(FeedEvent(icon: "📢",
            text: "NVDA earnings in 3 days",
            sub: "Options flow showing unusual call volume — traders expect a big move",
            accent: Color(hex: "#6366F1")))
        items.append(FeedEvent(icon: "🤖",
            text: "STALK AI updated your portfolio score",
            sub: "Tap AI Agent above to see your new insights",
            accent: Color(hex: "#5B5BD6")))
        items.append(FeedEvent(icon: "📈",
            text: "Lena V. +2.1% today · Semis on fire",
            sub: "She holds NVDA 40% · AMD 25% · See her portfolio →",
            accent: Color(hex: "#6EE7B7")))

        return items
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("⚡ Live Feed")
                        .font(.system(size: 15, weight: .bold)).foregroundStyle(Theme.text)
                    Text("What's happening in your portfolio right now")
                        .font(.system(size: 11)).foregroundStyle(Theme.text3)
                }
                Spacer()
                Circle().fill(Color(hex: "#22C55E")).frame(width: 8, height: 8)
                    .overlay(Circle().fill(Color(hex: "#22C55E").opacity(0.25)).frame(width: 16, height: 16))
            }
            .padding(.bottom, 14)

            VStack(spacing: 0) {
                ForEach(Array(events.prefix(visibleCount).enumerated()), id: \.element.id) { i, event in
                    HStack(alignment: .top, spacing: 12) {
                        Text(event.icon)
                            .font(.system(size: 18))
                            .frame(width: 32, height: 32)
                            .background(event.accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.text)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.text)
                            Text(event.sub)
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.text3)
                                .lineSpacing(2)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)

                    if i < min(visibleCount, events.count) - 1 {
                        Divider()
                    }
                }
            }

            if visibleCount < events.count {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { visibleCount = events.count }
                } label: {
                    Text("Show more (\(events.count - visibleCount))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                }
            }
        }
        .padding(18)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}

// MARK: - Portfolio Health Card

struct PortfolioHealthCard: View {
    @Environment(AppState.self) var appState

    struct HealthResult {
        let score: Int
        let label: String
        let insights: [String]
    }

    var health: HealthResult {
        var score = 60

        let positions = appState.positions
        let totalValue = appState.totalValue
        guard totalValue > 0 else {
            return HealthResult(score: 60, label: "Good", insights: ["Add more positions to get a full health analysis."])
        }

        var insights: [String] = []

        // --- Diversification ---
        // Penalize if >40% in one stock
        let maxSinglePct = positions.map { p -> Double in
            let v = (appState.quotes[p.ticker]?.price ?? p.avgCost) * p.shares
            return v / totalValue * 100
        }.max() ?? 0

        if maxSinglePct > 50 {
            score -= 20
            if let top = positions.max(by: { (appState.quotes[$0.ticker]?.price ?? $0.avgCost) * $0.shares < (appState.quotes[$1.ticker]?.price ?? $1.avgCost) * $1.shares }) {
                insights.append("\(top.ticker) is \(String(format: "%.0f", maxSinglePct))% of your portfolio — extreme concentration risk.")
            }
        } else if maxSinglePct > 40 {
            score -= 10
            insights.append("Top position is \(String(format: "%.0f", maxSinglePct))% of portfolio. Consider trimming to reduce concentration.")
        }

        // Bonus for 5+ positions
        if positions.count >= 5 {
            score += 10
        }

        // --- Performance vs SPY YTD ---
        let spyReturn = (appState.marketQuotes["SPY"]?.changePercent ?? 0) * 130 * 0.28
        let myReturn = appState.totalPnlPct
        if myReturn > spyReturn {
            score += 10
            insights.append("Outperforming the S&P 500 YTD — excellent work.")
        } else if myReturn < -10 {
            score -= 15
            insights.append("Portfolio is down \(String(format: "%.1f", abs(myReturn)))% — review your holdings and thesis.")
        }

        // --- Volatility: avg daily swing ---
        let avgSwing = positions.map { p -> Double in
            abs(appState.quotes[p.ticker]?.changePercent ?? 0)
        }.reduce(0, +) / Double(max(positions.count, 1))

        if avgSwing > 3 {
            score -= 10
            insights.append("High volatility today: average \(String(format: "%.1f", avgSwing))% swing across positions. Consider hedging.")
        }

        // --- Position sizing: >50% in one ---
        // Already handled above in concentration check

        let clamped = max(0, min(100, score))
        let label: String
        if clamped >= 80 { label = "Excellent" }
        else if clamped >= 50 { label = "Good" }
        else { label = "Needs Attention" }

        // Fill in a default insight if none triggered
        if insights.isEmpty {
            insights.append(positions.count >= 5
                ? "Well diversified across \(positions.count) positions."
                : "Add more positions to diversify your portfolio.")
        }

        return HealthResult(score: clamped, label: label, insights: insights)
    }

    var scoreColor: Color {
        let s = health.score
        if s >= 80 { return Color(hex: "#00D26A") }
        if s >= 50 { return Color(hex: "#F5A623") }
        return Color(hex: "#FF4757")
    }

    var body: some View {
        let result = health
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("💪 Portfolio Health")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text("Personalized score based on your holdings")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                }
                Spacer()
            }
            .padding(.bottom, 18)

            HStack(spacing: 20) {
                // Ring + Score
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Theme.bg2, lineWidth: 10)
                        .frame(width: 90, height: 90)

                    // Filled arc
                    Circle()
                        .trim(from: 0, to: CGFloat(result.score) / 100.0)
                        .stroke(
                            scoreColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: result.score)

                    // Score label
                    VStack(spacing: 1) {
                        Text("\(result.score)")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(scoreColor)
                        Text(result.label)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(Theme.text3)
                            .textCase(.uppercase)
                            .kerning(0.5)
                    }
                }

                // Insights
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(result.insights.prefix(3), id: \.self) { insight in
                        HStack(alignment: .top, spacing: 6) {
                            Circle()
                                .fill(scoreColor)
                                .frame(width: 5, height: 5)
                                .padding(.top, 5)
                            Text(insight)
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.text2)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(18)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border, lineWidth: 1))
        .shadow(color: scoreColor.opacity(0.08), radius: 12, y: 3)
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
