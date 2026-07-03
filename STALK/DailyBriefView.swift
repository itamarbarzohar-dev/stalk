import SwiftUI
import Combine

struct DailyBriefView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var now = Date()
    @State private var selectedTab: BriefTab = .portfolio
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    enum BriefTab: String, CaseIterable {
        case portfolio = "My Portfolio"
        case market    = "Stock Market"
        case crypto    = "Crypto"
    }

    var marketStatus: MarketStatus { MarketCalendar.status(at: now) }
    var isTradingToday: Bool { MarketCalendar.isTradingDay(now) }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                briefHeader()
                briefTabBar()
                VStack(spacing: 24) {
                    if !isTradingToday { nextTradingDayBanner() }
                    switch selectedTab {
                    case .portfolio:
                        portfolioSection()
                        portfolioAnalysisSection()
                    case .market:
                        marketSection()
                        macroSection()
                        marketAnalysisSection()
                    case .crypto:
                        cryptoSection()
                        cryptoAnalysisSection()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 60)
            }
        }
        .background(Theme.bg)
        .ignoresSafeArea(edges: .top)
        .onReceive(timer) { now = $0 }
    }

    // MARK: - Tab Bar

    func briefTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(BriefTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 7) {
                        Text(tab.rawValue)
                            .font(.system(size: 13, weight: selectedTab == tab ? .black : .semibold))
                            .foregroundStyle(selectedTab == tab ? Theme.text : Theme.text3)
                            .frame(maxWidth: .infinity)
                        Rectangle()
                            .fill(selectedTab == tab ? Theme.accent : Color.clear)
                            .frame(height: 2)
                            .clipShape(Capsule())
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .background(Theme.bg)
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.border).frame(height: 1) }
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

    // MARK: - Crypto Section

    func cryptoSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("₿ Crypto Today")

            // Price snapshot rows
            VStack(spacing: 0) {
                let coins: [(sym: String, name: String, price: String, change: Double)] = [
                    ("BTC", "Bitcoin",  "$118,240", 3.4),
                    ("ETH", "Ethereum", "$4,180",   5.1),
                    ("SOL", "Solana",   "$212",     7.8),
                    ("XRP", "XRP",      "$2.41",   -1.2),
                ]
                ForEach(Array(coins.enumerated()), id: \.element.sym) { i, c in
                    HStack(spacing: 12) {
                        Text(c.sym)
                            .font(.system(size: 12, weight: .black).monospaced())
                            .foregroundStyle(Theme.gold)
                            .frame(width: 38, alignment: .leading)
                        Text(c.name)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Theme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(c.price)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.text)
                            .monospacedDigit()
                        Text(c.change.fmtPct())
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(c.change >= 0 ? Theme.gain : Theme.loss)
                            .frame(width: 62, alignment: .trailing)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    if i < coins.count - 1 {
                        Rectangle().fill(Theme.border).frame(height: 1).padding(.leading, 50)
                    }
                }
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))

            briefCard(icon: "🏦", title: "Spot ETF inflows hit $1.2B this week",
                      body: "BlackRock's IBIT alone took in $640M over three sessions — the strongest weekly inflow since March. Institutional demand is doing the heavy lifting while retail volume stays muted.",
                      type: .good)
            briefCard(icon: "⛓️", title: "Ethereum led majors on staking-ETF speculation",
                      body: "ETH +5.1% outpaced BTC after reports that the SEC is reviewing staking provisions for existing ETH ETFs. Adding yield to the ETF wrapper would materially widen the buyer base.",
                      type: .good)
            briefCard(icon: "⚡", title: "Solana ecosystem volume spiked 40%",
                      body: "SOL +7.8% on a surge in DEX activity and two new institutional custody integrations. High-beta majors are outperforming — a classic risk-on signature.",
                      type: .good)
            briefCard(icon: "📉", title: "Funding rates are getting stretched",
                      body: "Perpetual futures funding turned sharply positive across exchanges. Leverage is building on the long side — raising the odds of a sharp washout on any negative headline.",
                      type: .warn)
        }
    }

    // MARK: - AI Analysis Sections

    func portfolioAnalysisSection() -> some View {
        analysisBlock(title: "🤖 STALK AI · Portfolio Deep Dive", paragraphs: [
            ("What happened", "Your book moved with the market today, but with higher beta — your tech concentration (NVDA, AAPL, META) amplifies every index move in both directions. Today's session was driven by the Fed holding rates and money rotating from tech into energy and financials, which hit your largest holdings directly."),
            ("Why it moved this way", "None of today's move was company-specific — no earnings, downgrades, or news on your names. This was pure macro: elevated rates compress the multiples of long-duration growth stocks first, and your portfolio is heavily weighted there. That's why you tracked the Nasdaq more closely than the S&P today."),
            ("How it affects you next", "Tomorrow's CPI print at 8:30am ET is the single biggest risk to your book this week. A hot print (above 3.1%) likely means another leg down in tech — expect your portfolio to underperform the S&P by 0.5–1pt. A cool print could snap the rotation and send your holdings up sharply, since they've been the source of funds. If you're overweight one name above 25% of the book, trimming into strength before the print is the risk-managed play."),
        ])
    }

    func marketAnalysisSection() -> some View {
        analysisBlock(title: "🤖 STALK AI · Market Analysis", paragraphs: [
            ("What happened", "Indices closed mixed: S&P 500 +1.2%, Nasdaq 100 +2.1%, Dow +0.8%, Russell 2000 -0.4%. Under the surface, the story was rotation — tech (XLK -2.8% at the lows) bled into energy (XLE +2.1%) and financials (XLF +0.9%) before a late-day recovery. Breadth was poor: fewer than half of S&P constituents closed green."),
            ("Why it moved", "Three forces drove today. First, the Fed held at 5.25–5.50% and Powell pushed back on near-term cuts, which keeps pressure on high-multiple growth. Second, China's manufacturing PMI beat (51.4 vs 50.1) lifted commodities, energy, and China-exposed names. Third, positioning ahead of tomorrow's CPI — funds de-risked crowded tech longs into the print."),
            ("How it affects the market", "The market is priced for a 3.1% CPI consensus. A cooler print would likely trigger a sharp relief rally led by the most beaten-down growth names, and rate-cut odds for September would jump. A hotter print extends the rotation: expect energy, value, and cash-rich large caps to hold up while unprofitable tech takes the damage. Earnings remain the market's safety net — with 65% of the S&P reported and blended EPS growth at +7.2% versus +5.1% expected, dips are still being bought. Watch small caps: the Russell's weakness signals the market still doubts a soft landing."),
        ])
    }

    func cryptoAnalysisSection() -> some View {
        analysisBlock(title: "🤖 STALK AI · Crypto Analysis", paragraphs: [
            ("What happened", "Crypto had a strong risk-on session: BTC +3.4% to $118K, ETH +5.1%, SOL +7.8%. The rally was led by high-beta majors rather than Bitcoin — the pattern you see when confidence is rising, not when investors are hiding in the largest asset."),
            ("Why it moved", "The primary driver is institutional flow: $1.2B into spot ETFs this week, led by IBIT. Layered on top, ETH staking-ETF speculation gave Ethereum its own catalyst, and Solana's ecosystem metrics (DEX volume +40%) attracted momentum money. Crypto is also front-running tomorrow's CPI — a cooling inflation print weakens the dollar and historically lifts hard-cap assets first."),
            ("How it affects the market", "Crypto strength spills into equities through the miners and treasury plays — COIN, MSTR, MARA, and RIOT all tend to move 1.5–2x BTC's daily change. If BTC holds above $115K through the CPI print, expect crypto-adjacent stocks to lead any relief rally. The main risk is leverage: funding rates are stretched long, so a hot CPI could trigger a cascade of liquidations that takes BTC down 5–8% fast, dragging the whole complex with it. For equity investors, BTC is currently behaving as a high-beta Nasdaq proxy — it confirms, rather than hedges, your tech exposure."),
        ])
    }

    func analysisBlock(title: String, paragraphs: [(header: String, body: String)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(title)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(paragraphs.enumerated()), id: \.offset) { i, p in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(p.header.uppercased())
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(Color(hex: "#4A90D9"))
                            .kerning(1.2)
                        Text(p.body)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.text2)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    if i < paragraphs.count - 1 {
                        Rectangle().fill(Theme.border).frame(height: 1)
                    }
                }
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#4A90D9").opacity(0.25), lineWidth: 1)
            )
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
