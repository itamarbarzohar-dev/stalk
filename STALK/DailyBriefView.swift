import SwiftUI
import Combine

struct DailyBriefView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var now = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var marketStatus: MarketStatus { MarketCalendar.status(at: now) }
    var isTradingToday: Bool { MarketCalendar.isTradingDay(now) }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                briefHeader()
                VStack(spacing: 24) {
                    if !isTradingToday { nextTradingDayBanner() }
                    portfolioSection()
                    marketSection()
                    macroSection()
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 60)
            }
        }
        .background(Theme.bg)
        .ignoresSafeArea(edges: .top)
        .onReceive(timer) { now = $0 }
    }

    // MARK: - Header

    func briefHeader() -> some View {
        ZStack(alignment: .top) {
            appState.heroGradient
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.top, 52)
                .padding(.bottom, 14)

                Text(todayDateString())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.65))
                    .textCase(.uppercase)
                    .kerning(1.3)

                Text("📋 Daily Brief")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.top, 4)

                // Market status line
                HStack(spacing: 6) {
                    Circle().fill(marketStatus.dotColor).frame(width: 7, height: 7)
                    Text(marketStatus.label + " · " + marketStatus.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 20)
        }
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 32).fill(Theme.bg).frame(height: 32).offset(y: 16)
        }
    }

    func nextTradingDayBanner() -> some View {
        let next = MarketCalendar.nextTradingDay(after: now)
        let open = MarketCalendar.marketOpenDate(on: next)
        let interval = open.timeIntervalSince(now)
        let dayFmt = DateFormatter(); dayFmt.dateFormat = "EEEE, MMMM d"
        return briefCard(
            icon: "📅",
            title: "Markets are closed today",
            body: "Next trading day: \(dayFmt.string(from: next)) · Opens in \(interval.hhmm) at 9:30 AM ET",
            type: .alert
        )
    }

    func todayDateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: now)
    }

    // MARK: - Portfolio Section

    func portfolioSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("📊 Your Portfolio")

            if appState.positions.isEmpty {
                briefCard(icon: "💼", title: "No positions yet",
                          body: "Add stocks to your portfolio to get personalized daily analysis and AI insights.",
                          type: .neutral)
            } else {
                let dayPnl = appState.todayPnl
                let dayPct = appState.todayPnlPct
                let isUp = dayPnl >= 0

                briefCard(
                    icon: isUp ? "📈" : "📉",
                    title: isUp ? "Your portfolio is green today" : "Your portfolio is in the red today",
                    body: isUp
                        ? (abs(dayPct) > 2 ? "Strong alpha today — you're outperforming the broader market. Well played." : "Holding up well, moving roughly with the market. Nothing to act on.")
                        : "Tough session, but this is mostly macro-driven (rate pressure, sector rotation). Not your stock picks.",
                    type: isUp ? .good : .warn
                )

                let movers = appState.positions
                    .filter { abs(appState.quotes[$0.ticker]?.changePercent ?? 0) >= 1 }
                    .sorted { abs(appState.quotes[$0.ticker]?.changePercent ?? 0) > abs(appState.quotes[$1.ticker]?.changePercent ?? 0) }

                if movers.isEmpty {
                    briefCard(icon: "😴", title: "Quiet day for your holdings",
                              body: "None of your stocks moved more than 1% today. Nothing to act on — steady as she goes.",
                              type: .neutral)
                } else {
                    ForEach(movers) { position in
                        if let q = appState.quotes[position.ticker] {
                            PositionBriefCard(position: position, quote: q, totalValue: appState.totalValue)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Market Section

    func marketSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("🌍 What Moved the Market Today")

            briefCard(icon: "🏛️", title: "Fed held rates at 5.25–5.50%",
                      body: "Powell signaled no cuts until inflation is sustainably below 3%. High rates pressure growth stocks with high multiples more than anything else.",
                      type: .warn)
            briefCard(icon: "🔄", title: "Tech → Energy rotation underway",
                      body: "Money moved out of tech (XLK -2.8%) into energy (XLE +2.1%) and financials (XLF +0.9%). Classic defensive rotation when rates stay elevated.",
                      type: .warn)
            briefCard(icon: "💵", title: "CPI report drops tomorrow at 8:30am ET",
                      body: "Consensus expects 3.1%. A hotter print likely triggers a sell-off; a cooler one could spark a sharp tech bounce. Most important event this week.",
                      type: .alert)
            briefCard(icon: "🌏", title: "China PMI surprised to the upside",
                      body: "Manufacturing PMI 51.4 vs 50.1 expected — good news for commodities and stocks with heavy China exposure like AAPL and TSLA.",
                      type: .good)
        }
    }

    // MARK: - Macro Section

    func macroSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("📅 What's Coming This Week")

            briefCard(icon: "📊", title: "Earnings season: mostly beating",
                      body: "65% of S&P 500 has reported. Blended EPS growth is +7.2% — well above the +5.1% estimate. Market rewards beats and punishes misses hard within 24 hours.",
                      type: .good)
            briefCard(icon: "👀", title: "Key events to watch",
                      body: "Tuesday: CPI 8:30am ET · Wednesday: FOMC minutes · Thursday: jobless claims · Friday: consumer sentiment. Any of these can move your portfolio ±2%.",
                      type: .alert)
        }
    }

    // MARK: - Helpers

    func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Theme.text3)
            .textCase(.uppercase)
            .kerning(1.3)
            .padding(.bottom, 2)
    }

    enum BriefCardType { case good, warn, danger, alert, neutral }

    func briefCard(icon: String, title: String, body: String, type t: BriefCardType) -> some View {
        let bg: Color
        let border: Color
        switch t {
        case .good:    bg = Theme.gain.opacity(0.10);   border = Theme.gain.opacity(0.35)
        case .warn:    bg = Theme.gold.opacity(0.10);   border = Theme.gold.opacity(0.35)
        case .danger:  bg = Theme.loss.opacity(0.10);   border = Theme.loss.opacity(0.35)
        case .alert:   bg = Theme.accent.opacity(0.10); border = Theme.accent.opacity(0.35)
        case .neutral: bg = Theme.card;                 border = Theme.border
        }

        return HStack(alignment: .top, spacing: 12) {
            Text(icon).font(.system(size: 20)).frame(width: 28).padding(.top, 1)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.text)
                Text(body)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(3)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(border, lineWidth: 1))
    }
}

// MARK: - Position Brief Card

struct PositionBriefCard: View {
    let position: Position
    let quote: Quote
    let totalValue: Double

    var chgPct: Double { quote.changePercent }
    var dayPnl: Double { quote.change * position.shares }
    var posVal: Double { quote.price * position.shares }
    var allTimeRet: Double {
        position.avgCost > 0 ? ((quote.price - position.avgCost) / position.avgCost) * 100 : 0
    }
    var posPct: Double { totalValue > 0 ? (posVal / totalValue) * 100 : 0 }
    var isUp: Bool { chgPct >= 0 }

    var suggestion: (action: String, text: String, color: Color) {
        if posPct > 25 || allTimeRet > 50 {
            return ("TRIM", "This position has grown large. Taking partial profits (20–30%) locks in gains and rebalances risk.", Color(hex: "#F59E0B"))
        } else if allTimeRet < -10 {
            return ("WATCH", "Down significantly. Reassess your thesis on next earnings — if it's changed, cutting losses protects capital.", Color(hex: "#EF4444"))
        } else if chgPct < -2 && allTimeRet > 0 {
            return ("BUY DIP", "Down today but your all-time return is positive. Could be a good opportunity to add if conviction is high.", Color(hex: "#059669"))
        } else {
            return ("HOLD", "No action needed. Position is healthy — let it work for you.", Color(hex: "#6366F1"))
        }
    }

    var whyMoved: String {
        if chgPct > 5  { return "Very strong day — likely driven by a positive catalyst: earnings beat, analyst upgrade, or sector tailwind." }
        if chgPct > 2  { return "Solid gains driven by sector strength or positive market sentiment. Momentum is with you." }
        if chgPct > 0  { return "Modest gain, moving with the broader market. No significant news catalyst detected." }
        if chgPct > -2 { return "Minor pullback. Normal volatility — nothing to worry about unless this becomes a trend." }
        if chgPct > -5 { return "Meaningful drop, likely sector rotation or macro pressure. Review for any company-specific news." }
        return "Sharp decline. Check for earnings, guidance, or sector-wide news before making any decisions."
    }

    var sector: String {
        let s = ["AAPL":"Tech", "MSFT":"Tech", "GOOGL":"Tech", "NVDA":"AI/Chips", "META":"Social", "AMZN":"E-Commerce",
                 "TSLA":"EV", "JPM":"Finance", "BAC":"Finance", "GS":"Finance", "V":"Finance", "MA":"Finance",
                 "JNJ":"Healthcare", "PFE":"Healthcare", "UNH":"Healthcare", "XOM":"Energy", "CVX":"Energy",
                 "SPY":"ETF", "QQQ":"ETF", "VTI":"ETF"]
        return s[position.ticker] ?? "Stock"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(position.ticker)
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(Theme.text)
                        Text(sector)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.text3)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Theme.bg2)
                            .clipShape(Capsule())
                    }
                    Text("\(String(format: "%.4g", position.shares)) shares · avg \(position.avgCost.fmtPrice()) · \(String(format: "%.0f", posPct))% of portfolio")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(chgPct.fmtPct())
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(isUp ? Theme.gain : Theme.loss)
                    Text("\(dayPnl >= 0 ? "+" : "")\(dayPnl.fmtPrice()) today")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isUp ? Theme.gain : Theme.loss)
                }
            }
            .padding(14)
            .background(isUp ? Theme.gain.opacity(0.10) : Theme.loss.opacity(0.10))

            Divider().overlay(isUp ? Theme.gain.opacity(0.50) : Theme.loss.opacity(0.50))

            // Why it moved
            VStack(alignment: .leading, spacing: 6) {
                Text("🔍 Why it moved")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.text3)
                    .textCase(.uppercase)
                    .kerning(1)
                Text(whyMoved)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(3)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)

            Divider().overlay(isUp ? Theme.gain.opacity(0.50).opacity(0.3) : Theme.loss.opacity(0.50).opacity(0.3))

            // AI suggestion
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("🤖 STALK AI Says")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.text3)
                        .textCase(.uppercase)
                        .kerning(1)
                    Spacer()
                    Text(suggestion.action)
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(suggestion.color)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Text(suggestion.text)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(3)

                HStack(spacing: 4) {
                    Text("All-time:")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                    Text(allTimeRet.fmtPct())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(allTimeRet >= 0 ? Theme.gain : Theme.loss)
                    Text("·")
                        .foregroundStyle(Theme.text3)
                        .font(.system(size: 11))
                    Text("Value: \(posVal.fmtPrice())")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.text2)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(suggestion.color.opacity(0.06))
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isUp ? Theme.gain.opacity(0.50) : Theme.loss.opacity(0.50), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}
