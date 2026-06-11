import SwiftUI
import StoreKit
import Combine

struct ForYouView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void
    @State private var selectedGainer: WorldGainer? = nil
    @State private var showPremium = false
    @State private var selectedTab: ForYouTab = .forYou

    enum ForYouTab: String, CaseIterable {
        case forYou = "For You"
        case markets = "Markets"
        case news    = "News"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // TikTok-style segmented header
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(ForYouTab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    selectedTab = tab
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    Text(tab.rawValue)
                                        .font(.system(size: 15, weight: selectedTab == tab ? .black : .semibold))
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
                    .padding(.top, 52)
                    .padding(.bottom, 0)

                    Rectangle()
                        .fill(Theme.border)
                        .frame(height: 1)
                }
                .background(Theme.bg)
                .padding(.bottom, 14)

                switch selectedTab {
                case .forYou:
                    forYouContent()
                case .markets:
                    marketsContent()
                case .news:
                    newsContent()
                }

                Color.clear.frame(height: 100)
            }
        }
        .background(Theme.bg)
        .sheet(item: $selectedGainer) { gainer in
            CopyPortfolioSheet(gainer: gainer)
        }
        .sheet(isPresented: $showPremium) {
            PremiumSheet()
        }
    }

    // MARK: - For You Content

    @ViewBuilder
    func forYouContent() -> some View {
        // Today's Summary card — always first
        TodaySummaryCard(appState: appState, onOpenBrief: { appState.showDailyBrief = true })
            .padding(.horizontal, 14)
            .padding(.bottom, 12)

        // Alert strip
        HStack(spacing: 10) {
            Text("🔔 3 of your stocks report earnings this week")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.gold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("View") {}
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#D97706"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.gold.opacity(0.10))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.gold.opacity(0.30), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 14)
        .padding(.bottom, 10)

        // AI Market Context Card
        AIMarketContextCard(onOpenBrief: { appState.showDailyBrief = true })
            .padding(.horizontal, 14)
            .padding(.bottom, 10)

        // Earnings Calendar Card
        sectionLabel("📅 Earnings This Week")
        EarningsCalendarCard(userTickers: Set(appState.positions.map(\.ticker)), onTicker: onTicker)
            .padding(.horizontal, 14)
            .padding(.bottom, 6)

        hotOnSTALKSection()
        missedOpportunitiesSection()

        sectionLabel("🌍 Today's Top Portfolios · Copy & Invest")
        worldGainersSection()

        sectionLabel("📊 Earnings · Beat / Miss / Guidance")
        earningsSection()

        sectionLabel("📈 Analyst Moves")
        analystSection()

        sectionLabel("🏦 Insider Buys")
        insiderSection()

        sectionLabel("🇺🇸 Trump Watch")
        trumpSection()

        sectionLabel("🐋 Whale Alerts · Options Flow")
        PremiumLockedCard(icon: "🐋", title: "Whale Alerts", subtitle: "See where the big money is flowing in real-time.") { showPremium = true }
            .padding(.horizontal, 14)
            .padding(.bottom, 9)

        sectionLabel("📉 Short Squeeze Radar")
        PremiumLockedCard(icon: "📉", title: "Short Squeeze Radar", subtitle: "Spot the next GME before it happens. Upgrade to Pro.") { showPremium = true }
            .padding(.horizontal, 14)
            .padding(.bottom, 9)
    }

    // MARK: - Markets Tab (curated market summary)

    @ViewBuilder
    func marketsContent() -> some View {
        sectionLabel("📊 Index Snapshot")

        VStack(spacing: 0) {
            let indices: [(ticker: String, name: String, icon: String, change: Double)] = [
                ("SPY", "S&P 500",    "🇺🇸",  1.2),
                ("QQQ", "NASDAQ 100", "💻",   2.1),
                ("DIA", "Dow Jones",  "🏦",   0.8),
                ("IWM", "Russell 2K", "🏗️", -0.4),
            ]
            ForEach(Array(indices.enumerated()), id: \.element.ticker) { i, idx in
                let q = appState.marketQuotes[idx.ticker]
                HStack(spacing: 12) {
                    Text(idx.icon).font(.system(size: 16)).frame(width: 26)
                    Text(idx.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(q?.price.fmtPrice() ?? "—")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.text)
                        .monospacedDigit()
                    let displayChange = q?.changePercent ?? idx.change
                    Text(displayChange.fmtPct())
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(displayChange >= 0 ? Theme.gain : Theme.loss)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                if i < indices.count - 1 {
                    Rectangle().fill(Theme.border).frame(height: 1).padding(.leading, 54)
                }
            }
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
        .padding(.horizontal, 14)
        .padding(.bottom, 20)

        sectionLabel("🔥 Trending · Social Buzz")
        TrendingTickersFeedView(onTicker: onTicker)
            .padding(.horizontal, 14)
            .padding(.bottom, 20)

        sectionLabel("⚡ Top Movers")
        TopMoversGrid(onTicker: onTicker)
            .padding(.horizontal, 14)
            .padding(.bottom, 20)
    }

    // MARK: - News Tab

    @ViewBuilder
    func newsContent() -> some View {
        sectionLabel("📰 Financial Headlines")

        VStack(spacing: 10) {
            ForEach(mockNewsHeadlines, id: \.id) { item in
                Button { onTicker(item.tickers.first ?? "") } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            ForEach(item.tickers, id: \.self) { t in
                                Text(t)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Theme.accent)
                                    .padding(.horizontal, 7).padding(.vertical, 2)
                                    .background(Theme.accentBg)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            Spacer()
                            Text(item.time)
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                        Text(item.headline)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.text)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(item.source)
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.text3)
                    }
                    .padding(14)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
    }

    // MARK: - Sections

    func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Theme.text3)
            .textCase(.uppercase)
            .kerning(1.3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
            .padding(.top, 22)
    }

    func hotOnSTALKSection() -> some View {
        let hot: [(ticker: String, adds: Int, pct: Double, icon: String)] = [
            ("NVDA", 1243, 4.2, "🔥"),
            ("TSLA", 891,  2.1, "⚡"),
            ("META", 734, -0.8, "📱"),
            ("PLTR", 612,  6.7, "🤖"),
            ("AAPL", 504,  0.9, "🍎"),
        ]
        return VStack(alignment: .leading, spacing: 0) {
            sectionLabel("🔥 Hot on STALK This Week")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(hot, id: \.ticker) { item in
                        Button { onTicker(item.ticker) } label: {
                            ZStack(alignment: .bottomLeading) {
                                // Gradient overlay for depth
                                LinearGradient(
                                    colors: [
                                        (item.pct >= 0 ? Theme.gain : Theme.loss).opacity(0.18),
                                        Theme.card
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )

                                VStack(alignment: .leading, spacing: 0) {
                                    // Top row: icon + change
                                    HStack(alignment: .top) {
                                        Text(item.icon)
                                            .font(.system(size: 26))
                                            .frame(width: 40, height: 40)
                                            .background((item.pct >= 0 ? Theme.gain : Theme.loss).opacity(0.15))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        Spacer()
                                        Text(item.pct.fmtPct())
                                            .font(.system(size: 15, weight: .black))
                                            .foregroundStyle(item.pct >= 0 ? Theme.gain : Theme.loss)
                                            .padding(.horizontal, 10).padding(.vertical, 5)
                                            .background((item.pct >= 0 ? Theme.gain : Theme.loss).opacity(0.12))
                                            .clipShape(Capsule())
                                    }

                                    Spacer()

                                    // Ticker — big
                                    Text(item.ticker)
                                        .font(.system(size: 24, weight: .black))
                                        .foregroundStyle(Theme.text)

                                    // Social proof
                                    Text("\(item.adds.formatted())")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Theme.accent)
                                    Text("users added this week")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(Theme.text3)
                                }
                                .padding(16)
                            }
                            .frame(width: 148, height: 160)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke((item.pct >= 0 ? Theme.gain : Theme.loss).opacity(0.20), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
            }
        }
    }

    func missedOpportunitiesSection() -> some View {
        let missed: [(ticker: String, gain: Double, days: Int, desc: String)] = [
            ("NVDA", 247, 180, "AI chip supercycle — up 247% in 6 months"),
            ("PLTR", 89,  90,  "Government AI contracts drove massive run"),
            ("ARM",  72,  60,  "IPO pop + AI tailwind since September"),
            ("SMCI", 61,  45,  "Data center build-out beneficiary"),
        ]
        return VStack(alignment: .leading, spacing: 0) {
            sectionLabel("😬 Missed Opportunities")
            VStack(spacing: 9) {
                ForEach(missed, id: \.ticker) { item in
                    Button { onTicker(item.ticker) } label: {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(item.ticker)
                                        .font(.system(size: 15, weight: .black))
                                        .foregroundStyle(Theme.text)
                                    Text("not in your portfolio")
                                        .font(.system(size: 10))
                                        .foregroundStyle(Theme.text3)
                                }
                                Text(item.desc)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.text2)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("+\(String(format: "%.0f", item.gain))%")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundStyle(Theme.gain)
                                Text("\(item.days)d")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.text3)
                            }
                        }
                        .padding(14)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Theme.gain.opacity(0.25), lineWidth: 1)
                        )
                        .overlay(alignment: .leading) {
                            Rectangle().fill(Theme.gain).frame(width: 3)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                .padding(.vertical, 6)
                        }
                        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
        }
    }

    func worldGainersSection() -> some View {
        VStack(spacing: 10) {
            ForEach(Array(WORLD_GAINERS.enumerated()), id: \.element.id) { i, gainer in
                Button { selectedGainer = gainer } label: {
                    HStack(spacing: 12) {
                        Text("#\(gainer.rank)")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Theme.text3)
                            .frame(width: 20)

                        Circle()
                            .fill(gainer.color)
                            .frame(width: 42, height: 42)
                            .overlay(
                                Text(gainer.initial)
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundStyle(.white)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(gainer.name) \(gainer.flag)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text(gainer.holdings.prefix(3).map(\.ticker).joined(separator: " · "))
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.text3)
                            Text("\(gainer.followers.formatted()) followers · \(gainer.value)")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("+\(String(format: "%.1f", gainer.todayReturn))%")
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(Theme.gain)
                            Text("YTD +\(String(format: "%.0f", gainer.ytd))%")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                            Text("Copy →")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .padding(14)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
    }

    func earningsSection() -> some View {
        VStack(spacing: 10) {
            ForEach(EARNINGS) { e in
                EarningsCard(report: e, onTicker: onTicker)
            }
        }
        .padding(.horizontal, 14)
    }

    func analystSection() -> some View {
        VStack(spacing: 8) {
            ForEach(ANALYST_MOVES) { move in
                Button { onTicker(move.ticker) } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(move.firm)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text(move.action + " from " + move.fromRating)
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.text3)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(move.ticker)
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Theme.accent)
                            Text(move.priceTarget)
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.text3)
                            Text(move.changeLabel)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(move.isUpgrade ? Theme.gain : Theme.loss)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 13)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
                    .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
    }

    func insiderSection() -> some View {
        VStack(spacing: 9) {
            ForEach(INSIDER_BUYS) { buy in
                Button { onTicker(buy.ticker) } label: {
                    VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 4) {
                                    Text(buy.name)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(Theme.text)
                                    Text(buy.role)
                                        .font(.system(size: 11))
                                        .foregroundStyle(Theme.text3)
                                }
                                HStack(spacing: 5) {
                                    Text(buy.company)
                                        .font(.system(size: 11))
                                        .foregroundStyle(Theme.text3)
                                    Text(buy.ticker)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Theme.accent)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 1)
                                        .background(Color(hex: "#EDEDFF"))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(buy.value)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                Text(buy.shares + " shares")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.text3)
                            }
                        }
                        .padding(.bottom, 9)

                        Divider()

                        HStack {
                            Text(buy.sentiment)
                                .font(.system(size: 12, weight: .bold))
                            Spacer()
                            Text(buy.date)
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                        .padding(.top, 9)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
                    .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
    }

    func trumpSection() -> some View {
        VStack(spacing: 9) {
            ForEach(POLITICAL_TWEETS) { tweet in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "#E63946"), Color(hex: "#C1121F")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 38, height: 38)
                            .overlay(Text("T").font(.system(size: 16, weight: .black)).foregroundStyle(.white))

                        VStack(alignment: .leading, spacing: 1) {
                            Text(tweet.name)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text("\(tweet.handle) · \(tweet.time)")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                    }

                    Text("\"\(tweet.text)\"")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.text2)
                        .italic()
                        .lineSpacing(2)

                    HStack {
                        HStack(spacing: 5) {
                            ForEach(tweet.tickers, id: \.self) { t in
                                Button { onTicker(t) } label: {
                                    Text(t)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Theme.accent)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2)
                                        .background(Color(hex: "#EDEDFF"))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        Spacer()
                        Text(tweet.impact.fmtPct())
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(tweet.impact >= 0 ? Theme.gain : Theme.loss)
                    }
                }
                .padding(14)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Theme.border, lineWidth: 1)
                )
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color(hex: "#E63946"))
                        .frame(width: 3)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .padding(.vertical, 4)
                }
                .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                .padding(.horizontal, 14)
            }
        }
    }
}

// MARK: - Mock News Data

struct MockNewsItem: Identifiable {
    let id = UUID()
    let headline: String
    let tickers: [String]
    let source: String
    let time: String
}

private let mockNewsHeadlines: [MockNewsItem] = [
    MockNewsItem(headline: "Fed holds rates steady, Powell warns inflation remains too high for cuts", tickers: ["SPY", "QQQ"], source: "Bloomberg", time: "2h ago"),
    MockNewsItem(headline: "NVIDIA reports record data center revenue, beats EPS by 18% — shares surge after-hours", tickers: ["NVDA"], source: "Reuters", time: "3h ago"),
    MockNewsItem(headline: "Apple eyes generative AI features for iOS 19, targets on-device model", tickers: ["AAPL"], source: "WSJ", time: "4h ago"),
    MockNewsItem(headline: "Tesla delivery numbers disappoint, Musk blames supply chain — analysts cut targets", tickers: ["TSLA"], source: "FT", time: "5h ago"),
    MockNewsItem(headline: "Meta's Llama 4 challenges GPT-4, open-source AI war heats up", tickers: ["META"], source: "TechCrunch", time: "6h ago"),
    MockNewsItem(headline: "Palantir wins $480M Pentagon AI contract — stock up 5% pre-market", tickers: ["PLTR"], source: "MarketWatch", time: "7h ago"),
    MockNewsItem(headline: "CPI report tomorrow: economists expect 3.1% — higher would rattle rate-cut bets", tickers: ["SPY", "DIA"], source: "Bloomberg", time: "8h ago"),
    MockNewsItem(headline: "Amazon Web Services accelerates AI infra spend, $15B capex upgrade planned", tickers: ["AMZN"], source: "CNBC", time: "9h ago"),
]

// MARK: - Today's Summary Card

struct TodaySummaryCard: View {
    let appState: AppState
    let onOpenBrief: () -> Void

    private var summaryText: String {
        let positions = appState.positions
        if positions.isEmpty {
            return "Markets opened mixed today as investors weigh Fed commentary against strong tech earnings. NVDA and PLTR led gains while energy names lagged — a classic risk-on rotation playing out in real time."
        }
        let tickers = positions.prefix(2).map(\.ticker).joined(separator: " and ")
        let totalPnl = appState.todayPnlPct
        let direction = totalPnl >= 0 ? "up" : "down"
        return "Your portfolio is \(direction) \(String(format: "%.2f", abs(totalPnl)))% today, led by movement in \(tickers). Tech momentum is carrying the session — semis and AI names are outperforming while bond yields tick higher on Fed hold."
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#0D0D1A"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#5B5BD6").opacity(0.6), Color(hex: "#7B6FEF").opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text("📰")
                        .font(.system(size: 16))
                    Text("TODAY'S SUMMARY")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(1.5)
                    Spacer()
                    // Live pill
                    HStack(spacing: 4) {
                        Circle().fill(Color(hex: "#00D26A")).frame(width: 5, height: 5)
                        Text("AI")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Color(hex: "#00D26A"))
                            .kerning(0.8)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color(hex: "#00D26A").opacity(0.10))
                    .clipShape(Capsule())
                }

                Text(summaryText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    onOpenBrief()
                } label: {
                    HStack(spacing: 5) {
                        Text("Full Daily Brief")
                            .font(.system(size: 12, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Color(hex: "#7B6FEF"))
                }
            }
            .padding(18)
        }
    }
}

// MARK: - Earnings Card

struct EarningsCard: View {
    let report: EarningsReport
    let onTicker: (String) -> Void

    var body: some View {
        Button { onTicker(report.ticker) } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(report.company)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.text)
                        Text(report.ticker)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.accent)
                    }
                    Spacer()
                    Text(report.time)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.text3)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Theme.bg2)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                // Grid
                HStack(spacing: 1) {
                    earningsCell("EPS", report.eps)
                    earningsCell("Revenue", report.rev)
                    guidanceCell()
                }
                .background(Theme.border)
                .clipShape(RoundedRectangle(cornerRadius: 0))

                // Reactions
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(report.reactions, id: \.self) { r in
                            Text(r)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.text2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Theme.bg)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border, lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
        }
        .buttonStyle(.plain)
    }

    func earningsCell(_ label: String, _ cell: EarningsReport.EarningsCell) -> some View {
        let hasBeat = cell.actual != nil
        return VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(0.8)
            Text(hasBeat ? cell.actual! : cell.estimate)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.text)
            if hasBeat, let beat = cell.beat, let surprise = cell.surprise {
                Text("\(beat ? "✓ Beat " : "✗ Miss ")\(surprise)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(beat ? Theme.gain : Theme.loss)
            } else {
                Text("Est.")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.text3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(hasBeat ? (cell.beat == true ? Theme.gainBg : Theme.lossBg) : Theme.card)
    }

    func guidanceCell() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Guidance")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(0.8)
            Text(report.guidanceText)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.text)
            Text(report.guidance == "raised" ? "⬆ Raised" : report.guidance == "lowered" ? "⬇ Lowered" : "➡ Met")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(report.guidance == "raised" ? Theme.gain : report.guidance == "lowered" ? Theme.loss : Theme.gold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Theme.card)
    }
}

// MARK: - Premium Locked

struct PremiumLockedCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let onUnlock: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 14).fill(Theme.bg2).frame(height: 54)
                }
            }
            .blur(radius: 6)

            VStack(spacing: 8) {
                Text(icon).font(.system(size: 28))
                Text(title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(Theme.text)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text3)
                    .multilineTextAlignment(.center)
                Button("Unlock with Pro") {
                    onUnlock()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(18)
            .background(.white.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Theme.accent.opacity(0.18), radius: 16, y: 4)
            .padding(20)
        }
    }
}

// MARK: - Copy Portfolio Sheet

struct CopyPortfolioSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    let gainer: WorldGainer
    @State private var amount: String = "1000"

    var ytdPct: Double { gainer.ytd / 100 }
    var projectedReturn: Double { (Double(amount) ?? 0) * ytdPct }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack(spacing: 14) {
                        Circle()
                            .fill(gainer.color)
                            .frame(width: 56, height: 56)
                            .overlay(Text(gainer.initial).font(.system(size: 22, weight: .black)).foregroundStyle(.white))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(gainer.name) \(gainer.flag)")
                                .font(.system(size: 19, weight: .black))
                                .foregroundStyle(Theme.text)
                            Text(gainer.bio)
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.text3)
                        }
                    }

                    // Stats
                    HStack(spacing: 8) {
                        statCard("+\(String(format: "%.1f", gainer.todayReturn))%", "Today", Theme.gainBg)
                        statCard("+\(String(format: "%.0f", gainer.ytd))%", "YTD", Color(hex: "#EDEDFF"))
                        statCard(gainer.followers.formatted(), "Followers", Theme.bg2)
                    }

                    // Holdings
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Portfolio Value")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.text3)
                                .textCase(.uppercase)
                            Spacer()
                            Text(gainer.value)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.accent)
                        }
                        ForEach(gainer.holdings, id: \.ticker) { h in
                            HStack(spacing: 10) {
                                Text(h.ticker)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(Theme.text)
                                    .frame(width: 48, alignment: .leading)
                                GeometryReader { geo in
                                    RoundedRectangle(cornerRadius: 3).fill(Theme.bg2)
                                        .overlay(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(Theme.accentGradient)
                                                .frame(width: geo.size.width * CGFloat(h.weight) / 100)
                                        }
                                }
                                .frame(height: 6)
                                Text("\(h.weight)%")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Theme.accent)
                                    .frame(width: 36, alignment: .trailing)
                            }
                        }
                    }
                    .padding(14)
                    .background(Theme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Amount input
                    ZStack {
                        LinearGradient(colors: [Color(hex: "#1E1B4B"), Color(hex: "#2D2B6B")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("💰 How much do you want to invest?")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white.opacity(0.7))
                                .textCase(.uppercase)

                            HStack(spacing: 8) {
                                ForEach(["100", "500", "1000", "5000"], id: \.self) { v in
                                    let n = Double(v) ?? 0
                                    let label = n >= 1000 ? "$\(Int(n/1000))K" : "$\(Int(n))"
                                    Button(label) {
                                        amount = v
                                    }
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(.white.opacity(0.1))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.15), lineWidth: 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }

                            HStack(spacing: 8) {
                                Text("$")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.6))
                                TextField("1000", text: $amount)
                                    #if os(iOS)
                                    .keyboardType(.numberPad)
                                    #endif
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                    .tint(.white)
                            }
                            .padding(12)
                            .background(.white.opacity(0.1))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.15), lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                            Text("Funds distributed proportionally across holdings")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(18)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Projected return
                    HStack {
                        Text("📈 If YTD performance repeats")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.gain)
                        Spacer()
                        Text("+$\(Int(projectedReturn).formatted())")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(Theme.gain)
                    }
                    .padding(12)
                    .background(Theme.gainBg)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Button {
                        copyPortfolio()
                        dismiss()
                    } label: {
                        Text("🚀 Copy This Portfolio")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Theme.accentGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    Button("Cancel") { dismiss() }
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.text3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .padding(18)
            }
            .background(Theme.bg)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    func statCard(_ value: String, _ label: String, _ bg: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Theme.text)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    func copyPortfolio() {
        let amt = Double(amount) ?? 0
        Task {
            for h in gainer.holdings {
                let invest = amt * Double(h.weight) / 100
                guard invest > 5, !appState.positions.contains(where: { $0.ticker == h.ticker }) else { continue }
                if let q = try? await QuoteService.fetchQuote(h.ticker) {
                    appState.quotes[h.ticker] = q
                    let shares = invest / q.price
                    appState.addPosition(Position(ticker: h.ticker, shares: shares, avgCost: q.price))
                }
            }
            await appState.refreshPortfolio()
        }
    }
}

// MARK: - AI Market Context Card

struct AIMarketContextCard: View {
    let onOpenBrief: () -> Void

    private let insights: [String] = [
        "**Fed held rates** at 5.25–5.50%. Powell signaled no cuts until inflation is sustainably below 3%. Growth stocks are pricing in higher-for-longer — watch your tech exposure.",
        "**NVDA earnings beat** consensus by 18%. Analyst upgrades are flowing in. Semiconductor sector up 3.2% — if you own any AI/chip names, today is your day.",
        "**CPI tomorrow at 8:30 AM ET.** Consensus: 3.1%. A surprise above 3.3% likely triggers a sell-off. Consensus below 2.9% could spike tech 2–3%. This is the week's key catalyst.",
        "**Retail sentiment turning bearish.** Reddit WallStreetBets short interest in S&P ETFs up 34% this week. Contrarian signal: retail gets it wrong ~60% of the time. Could be a buy signal.",
    ]

    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Background with indigo gradient border
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#0D0D1A"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#4B4ACF").opacity(0.7), Color(hex: "#7B6FEF").opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(spacing: 10) {
                    Text("🤖")
                        .font(.system(size: 18))
                    Text("AI Market Context")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Spacer()
                    // LIVE pill
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: "#00D26A"))
                            .frame(width: 6, height: 6)
                        Text("LIVE")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Color(hex: "#00D26A"))
                            .kerning(0.8)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#00D26A").opacity(0.12))
                    .clipShape(Capsule())
                }
                .padding(.bottom, 14)

                // Insight body — animated horizontal slide
                GeometryReader { geo in
                    let plainText = insights[currentIndex]
                        .replacingOccurrences(of: "**", with: "")
                    Text(plainText)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.text2)
                        .lineSpacing(4)
                        .frame(width: geo.size.width, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .offset(x: dragOffset)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
                }
                .frame(height: 72)
                .clipped()
                .padding(.bottom, 14)

                // Footer: dots + button
                HStack {
                    // Page dots
                    HStack(spacing: 5) {
                        ForEach(0..<insights.count, id: \.self) { i in
                            Circle()
                                .fill(i == currentIndex ? Color(hex: "#7B6FEF") : Color.white.opacity(0.2))
                                .frame(width: i == currentIndex ? 8 : 5, height: i == currentIndex ? 8 : 5)
                                .animation(.spring(response: 0.3), value: currentIndex)
                        }
                    }

                    Spacer()

                    Button {
                        onOpenBrief()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Full Analysis")
                                .font(.system(size: 12, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(Color(hex: "#7B6FEF"))
                    }
                }
            }
            .padding(18)
        }
        .onReceive(timer) { _ in
            advanceInsight()
        }
    }

    func advanceInsight() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            dragOffset = -20
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentIndex = (currentIndex + 1) % insights.count
            dragOffset = 20
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                dragOffset = 0
            }
        }
    }
}

// MARK: - Earnings Calendar Card

struct EarningsEvent: Identifiable {
    let id = UUID()
    let ticker: String
    let company: String
    let date: String
    let timing: String
    let epsEst: String
    let epsPrev: String
}

private let upcomingEarnings: [EarningsEvent] = [
    EarningsEvent(ticker: "AAPL", company: "Apple",     date: "Mon Jun 10", timing: "After Market",  epsEst: "$1.34 est", epsPrev: "$1.26 prev"),
    EarningsEvent(ticker: "NVDA", company: "NVIDIA",    date: "Tue Jun 11", timing: "After Market",  epsEst: "$5.81 est", epsPrev: "$4.02 prev"),
    EarningsEvent(ticker: "MSFT", company: "Microsoft", date: "Wed Jun 12", timing: "After Market",  epsEst: "$3.10 est", epsPrev: "$2.93 prev"),
    EarningsEvent(ticker: "META", company: "Meta",      date: "Thu Jun 13", timing: "After Market",  epsEst: "$4.75 est", epsPrev: "$4.39 prev"),
    EarningsEvent(ticker: "TSLA", company: "Tesla",     date: "Fri Jun 14", timing: "Before Market", epsEst: "$0.62 est", epsPrev: "$0.45 prev"),
]

struct EarningsCalendarCard: View {
    let userTickers: Set<String>
    let onTicker: (String) -> Void

    var sortedEvents: [EarningsEvent] {
        // User-owned positions first
        upcomingEarnings.sorted { a, b in
            let aOwned = userTickers.contains(a.ticker)
            let bOwned = userTickers.contains(b.ticker)
            if aOwned != bOwned { return aOwned }
            return false
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(sortedEvents) { event in
                let isOwned = userTickers.contains(event.ticker)
                Button { onTicker(event.ticker) } label: {
                    HStack(spacing: 12) {
                        // Ticker badge
                        Text(event.ticker)
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(isOwned ? Theme.gold : Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(minWidth: 50)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(event.company)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                if isOwned {
                                    Text("YOUR STOCK")
                                        .font(.system(size: 8, weight: .black))
                                        .foregroundStyle(Theme.gold)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(Theme.gold.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                            Text("\(event.date) · \(event.timing)")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(event.epsEst)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.text)
                            Text(event.epsPrev)
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(isOwned ? Theme.gold.opacity(0.06) : Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isOwned ? Theme.gold.opacity(0.3) : Theme.border, lineWidth: isOwned ? 1.5 : 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Premium Sheet

struct PremiumSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    @State private var selectedPlan: String = "annual"
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var showSuccess = false

    let features: [(String, String, String)] = [
        ("🐋", "Whale Alerts",            "See $1M+ options trades live"),
        ("🤖", "AI Analysis (Unlimited)", "Real AI answers about your stocks"),
        ("📉", "Short Squeeze Radar",     "Spot the next GME early"),
        ("🔔", "Unlimited Price Alerts",  "Set as many thresholds as you want"),
        ("🎨", "Premium Themes",          "Gold & Midnight — exclusive styles"),
    ]

    var monthlyProduct: Product? {
        appState.storeKitProducts.first { $0.id == "com.itamar.stalk.pro.monthly" }
    }
    var annualProduct: Product? {
        appState.storeKitProducts.first { $0.id == "com.itamar.stalk.pro.annual" }
    }
    var monthlyPrice: String { monthlyProduct?.displayPrice ?? "$6.99" }
    var annualPrice:  String { annualProduct?.displayPrice  ?? "$49.99" }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Dark gradient header
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        colors: [Color(hex: "#1A0B3B"), Color(hex: "#2D1B69"), Color(hex: "#4A2C8F")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )

                    VStack(spacing: 10) {
                        Text("🚀")
                            .font(.system(size: 44))
                            .padding(.top, 48)

                        Text("STALK Pro")
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(.white)

                        Text("Trade smarter. Stay obsessed.")
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.bottom, 28)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 32, height: 32)
                            .background(.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .padding(.top, 52)
                    .padding(.trailing, 20)
                }

                // Feature list
                VStack(spacing: 0) {
                    ForEach(features, id: \.0) { icon, title, sub in
                        HStack(spacing: 14) {
                            Text(icon)
                                .font(.system(size: 22))
                                .frame(width: 40, height: 40)
                                .background(Color(hex: "#7B6FEF").opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.text)
                                Text(sub)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.text3)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color(hex: "#7B6FEF"))
                        }
                        .padding(.vertical, 12)
                        if icon != features.last!.0 {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 8)

                // Plan selector
                VStack(spacing: 10) {
                    // Annual plan (pre-selected)
                    Button { selectedPlan = "annual" } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text("Annual")
                                        .font(.system(size: 16, weight: .black))
                                        .foregroundStyle(Theme.text)
                                    Text("BEST VALUE")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2)
                                        .background(Color(hex: "#7B6FEF"))
                                        .clipShape(Capsule())
                                }
                                Text("\(annualPrice)/yr · \(annualMonthlyPrice)/mo · Save 40%")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.text3)
                            }
                            Spacer()
                            Image(systemName: selectedPlan == "annual" ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundStyle(selectedPlan == "annual" ? Color(hex: "#7B6FEF") : Theme.text3)
                        }
                        .padding(16)
                        .background(selectedPlan == "annual" ? Color(hex: "#7B6FEF").opacity(0.08) : Theme.bg2)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedPlan == "annual" ? Color(hex: "#7B6FEF") : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)

                    // Monthly plan
                    Button { selectedPlan = "monthly" } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Monthly")
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundStyle(Theme.text)
                                Text("Billed monthly, cancel anytime")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.text3)
                            }
                            Spacer()
                            Text("\(monthlyPrice)/mo")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.text3)
                            Image(systemName: selectedPlan == "monthly" ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundStyle(selectedPlan == "monthly" ? Color(hex: "#7B6FEF") : Theme.text3)
                        }
                        .padding(16)
                        .background(selectedPlan == "monthly" ? Color(hex: "#7B6FEF").opacity(0.08) : Theme.bg2)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedPlan == "monthly" ? Color(hex: "#7B6FEF") : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // CTA Button
                Button {
                    isPurchasing = true
                    Task {
                        let productID = selectedPlan == "annual"
                            ? "com.itamar.stalk.pro.annual"
                            : "com.itamar.stalk.pro.monthly"
                        if let product = appState.storeKitProducts.first(where: { $0.id == productID }) {
                            let success = await appState.purchaseProduct(product)
                            if success {
                                showSuccess = true
                                try? await Task.sleep(for: .seconds(1.2))
                                dismiss()
                            } else {
                                showError = true
                            }
                        } else {
                            // Products not loaded yet — surface error
                            showError = true
                        }
                        isPurchasing = false
                    }
                } label: {
                    Group {
                        if isPurchasing {
                            ProgressView().tint(.white)
                        } else {
                            Text("Start 7-Day Free Trial")
                                .font(.system(size: 17, weight: .black))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#5B5BD6"), Color(hex: "#7B6FEF")],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color(hex: "#7B6FEF").opacity(0.4), radius: 12, y: 4)
                }
                .disabled(isPurchasing)
                .padding(.horizontal, 22)
                .padding(.top, 8)

                // Subtext under CTA
                Text("Then \(selectedPlan == "annual" ? "\(annualPrice)/yr" : "\(monthlyPrice)/mo") · Cancel anytime")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text3)
                    .padding(.top, 6)

                // Restore + Maybe later
                HStack(spacing: 24) {
                    Button("Restore Purchases") {
                        Task { await appState.restorePurchases() }
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text3)

                    Button("Maybe later") { dismiss() }
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.text3)
                }
                .padding(.top, 12)

                // Trust signals
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.text3)
                    Text("256-bit encryption · App Store verified")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                }
                .padding(.top, 8)

                // Legal footer (required by App Store)
                Text("7-day free trial. Payment charged to your Apple ID at end of trial. Cancel anytime in Settings > Subscriptions. Subscription auto-renews unless cancelled at least 24 hours before the end of the current period.")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.text3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
            }
        }
        .background(Theme.bg)
        .alert("Purchase Failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Something went wrong. Please try again.")
        }
        .alert("STALK Pro Activated!", isPresented: $showSuccess) {
            Button("Let's go!", role: .cancel) {}
        } message: {
            Text("Enjoy your 7-day trial. Welcome to the pro side.")
        }
    }

    var annualMonthlyPrice: String {
        if let p = annualProduct {
            // Approximate monthly equivalent — Decimal arithmetic, format as string
            let val = (p.price as NSDecimalNumber).doubleValue / 12
            return "$\(String(format: "%.2f", val))"
        }
        return "$4.16"
    }
}
