import SwiftUI
import Charts

// MARK: - Supporting Types

enum StockTab: String, CaseIterable {
    case overview, earnings, sentiment, fundamentals, financials, news

    var label: String {
        switch self {
        case .overview:     return "Overview"
        case .earnings:     return "Earnings"
        case .sentiment:    return "Sentiment"
        case .fundamentals: return "Fundamentals"
        case .financials:   return "Financials"
        case .news:         return "News"
        }
    }
    var icon: String {
        switch self {
        case .overview:     return "chart.line.uptrend.xyaxis"
        case .earnings:     return "calendar.badge.clock"
        case .sentiment:    return "brain.head.profile"
        case .fundamentals: return "building.columns"
        case .financials:   return "dollarsign.circle"
        case .news:         return "newspaper"
        }
    }
}

struct EarningsBeat: Identifiable {
    var id = UUID()
    let quarter: String
    let epsActual: Double
    let epsEstimate: Double
    let revActual: Double
    let revEstimate: Double
    var beatEPS: Bool { epsActual >= epsEstimate }
    var beatRev: Bool { revActual >= revEstimate }
    var epsSurprise: Double { epsEstimate > 0 ? ((epsActual - epsEstimate) / epsEstimate) * 100 : 0 }
}

struct StockNewsItem: Identifiable {
    var id = UUID()
    let headline: String
    let source: String
    let timeAgo: String
    let sentiment: String
    let summary: String
}

struct FinancialBar: Identifiable {
    var id = UUID()
    let quarter: String
    let revenue: Double
    let eps: Double
    let netMargin: Double
}

// MARK: - Main View

struct StockChartView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    let ticker: String
    @State private var range = "1mo"
    @State private var chartData: [ChartPoint] = []
    @State private var isLoading = false
    @State private var error = false
    @State private var activeTab: StockTab = .overview

    let ranges = [("1M", "1mo"), ("3M", "3mo"), ("6M", "6mo"), ("1Y", "1y")]

    var quote: Quote? { appState.quotes[ticker] }

    // MARK: - Mock Data

    private var companyName: String {
        ["NVDA": "NVIDIA Corporation", "AAPL": "Apple Inc.", "TSLA": "Tesla, Inc.",
         "META": "Meta Platforms", "MSFT": "Microsoft Corporation",
         "GOOGL": "Alphabet Inc.", "AMZN": "Amazon.com Inc."][ticker] ?? ticker
    }

    private var companyDescription: String {
        let d: [String: String] = [
            "NVDA": "NVIDIA designs graphics processing units (GPUs) for gaming and professional markets, as well as system-on-chip units for mobile computing and automotive markets. The company has pivoted to become the dominant infrastructure provider for AI training and inference.",
            "AAPL": "Apple designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. Services including the App Store, Apple Music, iCloud, and Apple TV+ are a growing share of revenue.",
            "TSLA": "Tesla designs, develops, manufactures, leases, and sells electric vehicles, energy generation and storage systems, and related services. The company operates Gigafactories globally and is developing Full Self-Driving technology.",
            "META": "Meta Platforms operates social media platforms including Facebook, Instagram, and WhatsApp, used by 3.2B+ people daily. The company is investing heavily in AI and the metaverse through its Reality Labs division.",
        ]
        return d[ticker] ?? "A publicly traded company listed on US exchanges. View real-time price data, earnings history, and analyst coverage below."
    }

    private var nextEarnings: (date: String, daysAway: Int, estimate: String) {
        let e: [String: (String, Int, String)] = [
            "NVDA": ("Aug 27, 2026", 65, "$0.89 EPS"),
            "AAPL": ("Jul 31, 2026", 38, "$1.43 EPS"),
            "TSLA": ("Jul 23, 2026", 30, "$0.61 EPS"),
            "META": ("Jul 30, 2026", 37, "$5.24 EPS"),
            "MSFT": ("Jul 29, 2026", 36, "$3.21 EPS"),
        ]
        return e[ticker] ?? ("Sep 15, 2026", 84, "—")
    }

    private var earningsHistory: [EarningsBeat] {
        let h: [String: [EarningsBeat]] = [
            "NVDA": [
                EarningsBeat(quarter: "Q4 '25", epsActual: 0.89, epsEstimate: 0.84, revActual: 39.3, revEstimate: 38.1),
                EarningsBeat(quarter: "Q3 '25", epsActual: 0.81, epsEstimate: 0.74, revActual: 35.1, revEstimate: 33.8),
                EarningsBeat(quarter: "Q2 '25", epsActual: 0.68, epsEstimate: 0.64, revActual: 30.0, revEstimate: 28.7),
                EarningsBeat(quarter: "Q1 '25", epsActual: 0.61, epsEstimate: 0.56, revActual: 26.0, revEstimate: 24.6),
            ],
            "AAPL": [
                EarningsBeat(quarter: "Q4 '25", epsActual: 1.64, epsEstimate: 1.60, revActual: 124.3, revEstimate: 123.1),
                EarningsBeat(quarter: "Q3 '25", epsActual: 1.53, epsEstimate: 1.49, revActual: 117.2, revEstimate: 116.5),
                EarningsBeat(quarter: "Q2 '25", epsActual: 2.40, epsEstimate: 2.35, revActual: 95.4, revEstimate: 94.0),
                EarningsBeat(quarter: "Q1 '25", epsActual: 2.18, epsEstimate: 2.09, revActual: 91.8, revEstimate: 90.2),
            ],
            "TSLA": [
                EarningsBeat(quarter: "Q4 '25", epsActual: 0.73, epsEstimate: 0.76, revActual: 25.7, revEstimate: 27.2),
                EarningsBeat(quarter: "Q3 '25", epsActual: 0.72, epsEstimate: 0.58, revActual: 25.2, revEstimate: 24.0),
                EarningsBeat(quarter: "Q2 '25", epsActual: 0.40, epsEstimate: 0.43, revActual: 22.7, revEstimate: 23.4),
                EarningsBeat(quarter: "Q1 '25", epsActual: 0.27, epsEstimate: 0.39, revActual: 19.3, revEstimate: 21.4),
            ],
            "META": [
                EarningsBeat(quarter: "Q4 '25", epsActual: 8.02, epsEstimate: 6.76, revActual: 48.4, revEstimate: 47.0),
                EarningsBeat(quarter: "Q3 '25", epsActual: 6.03, epsEstimate: 5.25, revActual: 40.6, revEstimate: 40.3),
                EarningsBeat(quarter: "Q2 '25", epsActual: 5.16, epsEstimate: 4.73, revActual: 39.1, revEstimate: 38.3),
                EarningsBeat(quarter: "Q1 '25", epsActual: 4.71, epsEstimate: 4.32, revActual: 36.5, revEstimate: 36.2),
            ],
        ]
        return h[ticker] ?? [
            EarningsBeat(quarter: "Q4 '25", epsActual: 1.20, epsEstimate: 1.10, revActual: 8.4, revEstimate: 8.1),
            EarningsBeat(quarter: "Q3 '25", epsActual: 1.05, epsEstimate: 1.08, revActual: 7.9, revEstimate: 8.0),
            EarningsBeat(quarter: "Q2 '25", epsActual: 0.98, epsEstimate: 0.95, revActual: 7.5, revEstimate: 7.3),
            EarningsBeat(quarter: "Q1 '25", epsActual: 0.91, epsEstimate: 0.89, revActual: 7.1, revEstimate: 7.0),
        ]
    }

    private var financialBars: [FinancialBar] {
        let f: [String: [FinancialBar]] = [
            "NVDA": [
                FinancialBar(quarter: "Q1'24", revenue: 7.2,  eps: 0.08, netMargin: 14.9),
                FinancialBar(quarter: "Q2'24", revenue: 13.5, eps: 0.27, netMargin: 55.2),
                FinancialBar(quarter: "Q3'24", revenue: 18.1, eps: 0.40, netMargin: 56.1),
                FinancialBar(quarter: "Q4'24", revenue: 22.1, eps: 0.49, netMargin: 57.4),
                FinancialBar(quarter: "Q1'25", revenue: 26.0, eps: 0.61, netMargin: 57.8),
                FinancialBar(quarter: "Q2'25", revenue: 30.0, eps: 0.68, netMargin: 58.1),
                FinancialBar(quarter: "Q3'25", revenue: 35.1, eps: 0.81, netMargin: 58.4),
                FinancialBar(quarter: "Q4'25", revenue: 39.3, eps: 0.89, netMargin: 57.9),
            ],
            "AAPL": [
                FinancialBar(quarter: "Q1'24", revenue: 119.6, eps: 2.18, netMargin: 26.4),
                FinancialBar(quarter: "Q2'24", revenue: 90.8,  eps: 1.53, netMargin: 24.3),
                FinancialBar(quarter: "Q3'24", revenue: 85.8,  eps: 1.40, netMargin: 21.6),
                FinancialBar(quarter: "Q4'24", revenue: 94.9,  eps: 1.64, netMargin: 23.9),
                FinancialBar(quarter: "Q1'25", revenue: 124.3, eps: 2.40, netMargin: 26.7),
                FinancialBar(quarter: "Q2'25", revenue: 95.4,  eps: 1.53, netMargin: 24.8),
                FinancialBar(quarter: "Q3'25", revenue: 91.8,  eps: 1.64, netMargin: 25.1),
                FinancialBar(quarter: "Q4'25", revenue: 124.3, eps: 1.64, netMargin: 27.1),
            ],
        ]
        return f[ticker] ?? [
            FinancialBar(quarter: "Q1'24", revenue: 5.1, eps: 0.82, netMargin: 18.2),
            FinancialBar(quarter: "Q2'24", revenue: 5.4, eps: 0.88, netMargin: 19.1),
            FinancialBar(quarter: "Q3'24", revenue: 5.8, eps: 0.91, netMargin: 19.8),
            FinancialBar(quarter: "Q4'24", revenue: 6.2, eps: 0.97, netMargin: 20.4),
            FinancialBar(quarter: "Q1'25", revenue: 6.6, eps: 1.02, netMargin: 21.0),
            FinancialBar(quarter: "Q2'25", revenue: 7.0, eps: 1.10, netMargin: 21.8),
            FinancialBar(quarter: "Q3'25", revenue: 7.5, eps: 1.18, netMargin: 22.1),
            FinancialBar(quarter: "Q4'25", revenue: 8.1, eps: 1.24, netMargin: 22.9),
        ]
    }

    private var newsItems: [StockNewsItem] {
        let n: [String: [StockNewsItem]] = [
            "NVDA": [
                StockNewsItem(headline: "NVIDIA's Blackwell Ultra chips see unprecedented demand from hyperscalers", source: "Bloomberg", timeAgo: "2h ago", sentiment: "Bullish", summary: "Amazon, Microsoft, and Google are placing orders for Blackwell Ultra GPUs at a record pace, with lead times extending into 2027."),
                StockNewsItem(headline: "Jensen Huang: 'We are at the iPhone moment for AI'", source: "CNBC", timeAgo: "5h ago", sentiment: "Bullish", summary: "NVIDIA CEO speaks at Computex about the transition from software to physical AI and robotics as the next frontier."),
                StockNewsItem(headline: "China export restrictions could dent NVDA revenue by $15B", source: "Reuters", timeAgo: "1d ago", sentiment: "Bearish", summary: "New BIS rules targeting H20 chips to China may reduce fiscal year 2026 revenue estimates according to analyst models."),
                StockNewsItem(headline: "NVIDIA acquires Run:ai to bolster GPU cluster management", source: "WSJ", timeAgo: "2d ago", sentiment: "Neutral", summary: "The $700M acquisition strengthens NVIDIA's software stack for enterprise AI deployments."),
                StockNewsItem(headline: "Goldman raises NVDA price target to $165", source: "Seeking Alpha", timeAgo: "3d ago", sentiment: "Bullish", summary: "Goldman Sachs analysts cite margin expansion and growing software revenue as key drivers for the increased target."),
            ],
            "AAPL": [
                StockNewsItem(headline: "Apple Intelligence adoption reaches 40% of eligible iPhone users", source: "9to5Mac", timeAgo: "3h ago", sentiment: "Bullish", summary: "Apple's AI features are driving upgrade cycles with users citing Siri improvements and writing tools as top reasons."),
                StockNewsItem(headline: "Apple Vision Pro 2 rumored for Q1 2027 launch with lower price", source: "MacRumors", timeAgo: "6h ago", sentiment: "Neutral", summary: "Supply chain sources suggest a $2,499 entry price and improved battery life for the next generation headset."),
                StockNewsItem(headline: "EU fines Apple €1.8B over App Store anti-competitive practices", source: "FT", timeAgo: "1d ago", sentiment: "Bearish", summary: "The European Commission ruling requires Apple to allow third-party app stores in the EU, threatening Services revenue."),
                StockNewsItem(headline: "Warren Buffett's Berkshire increases Apple stake to 6%", source: "Bloomberg", timeAgo: "4d ago", sentiment: "Bullish", summary: "Berkshire Hathaway disclosed increased Apple holdings in its latest 13F filing despite earlier reduction speculation."),
            ],
            "TSLA": [
                StockNewsItem(headline: "Tesla Robotaxi network officially launches in Austin with 50 vehicles", source: "Reuters", timeAgo: "1h ago", sentiment: "Bullish", summary: "The long-awaited commercial robotaxi launch marks a pivotal moment for Tesla's autonomous ambitions."),
                StockNewsItem(headline: "BYD outsells Tesla globally for third consecutive quarter", source: "Bloomberg", timeAgo: "4h ago", sentiment: "Bearish", summary: "Chinese EV giant BYD delivered 1.2M vehicles vs Tesla's 0.97M in Q1 2026, widening the global market share gap."),
                StockNewsItem(headline: "Tesla Optimus robot to begin factory work at Gigafactory Texas", source: "CNBC", timeAgo: "2d ago", sentiment: "Bullish", summary: "Elon Musk says Optimus robots will handle 'boring, repetitive' assembly tasks starting Q3, with 1,000 units deployed."),
            ],
            "META": [
                StockNewsItem(headline: "Meta's Llama 4 tops all open-source benchmarks, rivals GPT-4o", source: "TechCrunch", timeAgo: "2h ago", sentiment: "Bullish", summary: "The latest Llama release shows Meta closing the gap with proprietary models while keeping it open source."),
                StockNewsItem(headline: "Instagram crosses 3 billion monthly active users", source: "Meta IR", timeAgo: "1d ago", sentiment: "Bullish", summary: "Threads and Instagram Reels are driving user growth with time-spent metrics up 8% quarter-over-quarter."),
                StockNewsItem(headline: "FTC antitrust case against Meta heads to trial in September", source: "WSJ", timeAgo: "3d ago", sentiment: "Bearish", summary: "The government's case to force Meta to divest Instagram and WhatsApp will be heard by a federal judge this fall."),
            ],
        ]
        return n[ticker] ?? [
            StockNewsItem(headline: "\(ticker) reports strong quarterly results, beats estimates", source: "Reuters", timeAgo: "1d ago", sentiment: "Bullish", summary: "The company reported earnings per share that exceeded analyst consensus estimates for the fourth consecutive quarter."),
            StockNewsItem(headline: "Analyst upgrades \(ticker) to Buy with new price target", source: "Bloomberg", timeAgo: "2d ago", sentiment: "Bullish", summary: "A leading Wall Street firm raised its rating citing improving fundamentals and market position."),
            StockNewsItem(headline: "\(ticker) announces share buyback program worth $2B", source: "CNBC", timeAgo: "5d ago", sentiment: "Bullish", summary: "The board authorized a new repurchase program signaling management confidence in the stock's intrinsic value."),
        ]
    }

    private var aiAnalysis: (text: String, sentiment: String) {
        let s: [String: (String, String)] = [
            "NVDA": ("NVDA is executing near-perfectly on the AI infrastructure wave. Data center revenue grew 427% YoY and shows no sign of decelerating as hyperscalers race to build out GPU clusters. Valuation is rich but justified by the monopoly-like position in AI training. Near-term risk is China export restrictions.", "Bullish"),
            "AAPL": ("Apple's Services segment is the new growth engine, representing 22% of revenue at 70%+ gross margins. iPhone volumes plateau but ASP expansion offsets unit weakness. Buyback program is one of the largest in history. Key risk: EU regulatory pressure on App Store economics.", "Neutral"),
            "TSLA": ("Tesla faces intensifying competition from BYD globally. FSD monetization remains speculative. Margins have compressed. Robotaxi launch in Austin is the key near-term catalyst — success here could be a major re-rating event. Execution risk remains high.", "Neutral"),
            "META": ("Meta's ad revenue reacceleration and cost discipline drove dramatic margin recovery. Llama open-source strategy is a smart hedge against OpenAI. Reality Labs losses remain elevated. One of the strongest free cash flow generators in big tech.", "Bullish"),
            "MSFT": ("Microsoft's Copilot monetization across Office 365 is the most credible AI monetization story in enterprise software. Azure gaining share vs AWS. Trading at a premium but quality and durability justify it.", "Bullish"),
        ]
        return s[ticker] ?? ("This stock shows strong momentum backed by solid fundamentals. Institutional ownership has been increasing, signaling smart money confidence. Key catalysts include upcoming earnings and macro tailwinds.", "Neutral")
    }

    private var keyStats: [(label: String, value: String)] {
        let s: [String: [(String, String)]] = [
            "NVDA": [("P/E", "38.4x"), ("Mkt Cap", "$2.9T"), ("52W High", "$140.76"), ("52W Low", "$66.25"), ("Beta", "1.63"), ("Short Int.", "0.87%"), ("Div Yield", "0.03%"), ("Inst. Own", "66.4%"), ("Revenue", "$131B"), ("Gross Mgn", "74.6%")],
            "AAPL": [("P/E", "31.2x"), ("Mkt Cap", "$3.4T"), ("52W High", "$236.75"), ("52W Low", "$169.21"), ("Beta", "1.21"), ("Short Int.", "0.72%"), ("Div Yield", "0.44%"), ("Inst. Own", "62.1%"), ("Revenue", "$391B"), ("Gross Mgn", "46.2%")],
            "TSLA": [("P/E", "52.8x"), ("Mkt Cap", "$812B"),  ("52W High", "$414.50"), ("52W Low", "$182.00"), ("Beta", "2.14"), ("Short Int.", "3.12%"), ("Div Yield", "—"),      ("Inst. Own", "43.8%"), ("Revenue", "$97B"),  ("Gross Mgn", "17.9%")],
            "META": [("P/E", "24.7x"), ("Mkt Cap", "$1.4T"), ("52W High", "$638.40"), ("52W Low", "$414.50"), ("Beta", "1.18"), ("Short Int.", "0.61%"), ("Div Yield", "0.32%"), ("Inst. Own", "71.2%"), ("Revenue", "$164B"), ("Gross Mgn", "81.8%")],
        ]
        return s[ticker] ?? [("P/E", "—"), ("Mkt Cap", "—"), ("52W High", "—"), ("52W Low", "—"), ("Beta", "—"), ("Short Int.", "—"), ("Div Yield", "—"), ("Inst. Own", "—"), ("Revenue", "—"), ("Gross Mgn", "—")]
    }

    private var fundamentalRatios: [(label: String, value: String, context: String)] {
        let r: [String: [(String, String, String)]] = [
            "NVDA": [
                ("P/E Ratio", "38.4x", "vs sector avg 28.2x"),
                ("PEG Ratio", "0.48", "Growth-adjusted valuation"),
                ("P/S Ratio", "22.1x", "Price to Sales"),
                ("EV/EBITDA", "32.6x", "Enterprise Value metric"),
                ("ROE", "123.8%", "Return on Equity"),
                ("ROA", "61.2%", "Return on Assets"),
                ("Debt/Equity", "0.41", "Leverage ratio"),
                ("Current Ratio", "4.17", "Liquidity measure"),
            ],
            "AAPL": [
                ("P/E Ratio", "31.2x", "vs sector avg 28.2x"),
                ("PEG Ratio", "2.84", "Growth-adjusted valuation"),
                ("P/S Ratio", "8.7x", "Price to Sales"),
                ("EV/EBITDA", "24.1x", "Enterprise Value metric"),
                ("ROE", "147.2%", "Return on Equity"),
                ("ROA", "30.1%", "Return on Assets"),
                ("Debt/Equity", "1.87", "Leverage ratio"),
                ("Current Ratio", "0.95", "Liquidity measure"),
            ],
        ]
        return r[ticker] ?? [
            ("P/E Ratio", "—", "vs sector avg"), ("PEG Ratio", "—", "Growth-adjusted"),
            ("P/S Ratio", "—", "Price to Sales"), ("EV/EBITDA", "—", "Enterprise Value"),
            ("ROE", "—", "Return on Equity"), ("ROA", "—", "Return on Assets"),
            ("Debt/Equity", "—", "Leverage ratio"), ("Current Ratio", "—", "Liquidity"),
        ]
    }

    private var optionsSentiment: (putCall: Double, label: String, isBullish: Bool, bullPct: Int) {
        let d: [String: (Double, String, Bool, Int)] = [
            "NVDA": (0.48, "Bullish — calls dominating flow", true, 72),
            "AAPL": (0.71, "Neutral — balanced put/call activity", false, 54),
            "TSLA": (1.24, "Bearish — elevated put positioning", false, 41),
            "META": (0.52, "Slightly bullish — more calls than puts", true, 63),
        ]
        return d[ticker] ?? (0.85, "Neutral options flow", false, 50)
    }

    private var analysts: [(firm: String, rating: String, pt: String)] {
        [("Goldman", "Buy", "$220"), ("Morgan Stanley", "Overweight", "$215"),
         ("JPMorgan", "Buy", "$225"), ("BofA", "Buy", "$210"), ("Citi", "Neutral", "$185")]
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Theme.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                        // ── Price header ───────────────────────────────────────
                        priceHeader()

                        // ── Sticky tab ruler ───────────────────────────────────
                        Section(header: tabRuler()) {
                            // ── Tab content ────────────────────────────────────
                            Group {
                                switch activeTab {
                                case .overview:     overviewTab()
                                case .earnings:     earningsTab()
                                case .sentiment:    sentimentTab()
                                case .fundamentals: fundamentalsTab()
                                case .financials:   financialsTab()
                                case .news:         newsTab()
                                }
                            }
                            .padding(.bottom, 60)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task { await loadChart() }
        .task(id: ticker) {
            if appState.quotes[ticker] == nil {
                if let q = try? await QuoteService.fetchQuote(ticker) {
                    appState.quotes[ticker] = q
                }
            }
        }
    }

    // MARK: - Price Header

    @ViewBuilder
    private func priceHeader() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Back button
            Button { dismiss() } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                    Text("Back")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(Theme.accent)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(Theme.card)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.border, lineWidth: 1))
            }
            .padding(.top, 56)
            .padding(.bottom, 12)
            .padding(.horizontal, 20)

            // Company info
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(ticker)
                        .font(.system(size: 28, weight: .black))
                        .kerning(-0.5)
                        .foregroundStyle(Theme.text)
                    Text(companyName)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.text3)
                }
                Spacer()
                // Market status pill
                HStack(spacing: 5) {
                    Circle()
                        .fill(Theme.gain)
                        .frame(width: 6, height: 6)
                    Text("Market Open")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.gain)
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Theme.gain.opacity(0.10))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.gain.opacity(0.25), lineWidth: 1))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            // Price
            if let q = quote {
                HStack(alignment: .lastTextBaseline, spacing: 10) {
                    Text("$\(String(format: "%.2f", q.price))")
                        .font(.system(size: 46, weight: .black))
                        .kerning(-1.5)
                        .foregroundStyle(Theme.text)
                        .monospacedDigit()
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(q.change >= 0 ? "+" : "")\(String(format: "%.2f", q.change))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(q.isUp ? Theme.gain : Theme.loss)
                        Text(q.changePercent.fmtPct())
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(q.isUp ? Theme.gain : Theme.loss)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background((q.isUp ? Theme.gain : Theme.loss).opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            }

            Divider()
        }
        .background(Theme.bg)
    }

    // MARK: - Tab Ruler (sticky)

    @ViewBuilder
    private func tabRuler() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(StockTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            activeTab = tab
                        }
                    } label: {
                        VStack(spacing: 6) {
                            HStack(spacing: 5) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 11, weight: .semibold))
                                Text(tab.label)
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundStyle(activeTab == tab ? Theme.accent : Theme.text3)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                            Rectangle()
                                .fill(activeTab == tab ? Theme.accent : Color.clear)
                                .frame(height: 2)
                                .clipShape(Capsule())
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: activeTab)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(Theme.bg)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: - Overview Tab

    @ViewBuilder
    private func overviewTab() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Chart + range picker
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    ForEach(ranges, id: \.0) { label, value in
                        Button(label) {
                            range = value
                            Task { await loadChart() }
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(range == value ? .white : Theme.text3)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(range == value ? Theme.accent : Theme.card)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(range == value ? Theme.accent : Theme.border, lineWidth: 1))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)

                chartBody().padding(.horizontal, 14)
            }
            .padding(.top, 16)

            // Company description
            VStack(alignment: .leading, spacing: 8) {
                sectionLabel("About")
                Text(companyDescription)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(5)
                    .padding(.horizontal, 20)
            }

            // Analyst ratings
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Analyst Ratings")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(analysts, id: \.firm) { a in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(a.firm)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(a.rating == "Buy" || a.rating == "Overweight" ? Theme.gain : a.rating == "Sell" || a.rating == "Underweight" ? Theme.loss : Theme.gold)
                                        .frame(width: 6, height: 6)
                                    Text(a.rating)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(a.rating == "Buy" || a.rating == "Overweight" ? Theme.gain : Theme.text3)
                                }
                                Text("PT \(a.pt)")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundStyle(Theme.nanoBanana)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            // Quick stats 3-up
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Key Stats")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(keyStats.prefix(6), id: \.label) { stat in
                        statCell(stat.label, stat.value)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Earnings Tab

    @ViewBuilder
    private func earningsTab() -> some View {
        let next = nextEarnings
        let history = earningsHistory

        VStack(alignment: .leading, spacing: 20) {
            // Next earnings countdown
            VStack(alignment: .leading, spacing: 14) {
                sectionLabel("Next Earnings")
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(next.date)
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(Theme.text)
                        Text("Estimate: \(next.estimate)")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.text3)
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("\(next.daysAway)")
                            .font(.system(size: 36, weight: .black))
                            .foregroundStyle(Theme.nanoBanana)
                            .monospacedDigit()
                        Text("days away")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.text3)
                            .textCase(.uppercase)
                            .kerning(0.5)
                    }
                }
                .padding(16)
                .background(
                    LinearGradient(colors: [Theme.nanoBananaBg, Theme.bg2], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.nanoBanana.opacity(0.25), lineWidth: 1))
                .padding(.horizontal, 20)
            }
            .padding(.top, 16)

            // Beat/miss summary
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Beat/Miss History — Last 4 Quarters")
                let beats = history.filter { $0.beatEPS }.count
                HStack(spacing: 8) {
                    beatSummaryChip("EPS Beat", "\(beats)/4", beats >= 3 ? Theme.gain : Theme.gold)
                    let revBeats = history.filter { $0.beatRev }.count
                    beatSummaryChip("Rev Beat", "\(revBeats)/4", revBeats >= 3 ? Theme.gain : Theme.gold)
                    beatSummaryChip("Avg Surprise", "+\(String(format: "%.1f", history.map { $0.epsSurprise }.reduce(0,+)/4))%", Theme.accent)
                }
                .padding(.horizontal, 20)
            }

            // Earnings history cards
            VStack(alignment: .leading, spacing: 8) {
                ForEach(history) { item in
                    earningsRow(item)
                }
            }
            .padding(.horizontal, 20)

            // EPS chart
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("EPS: Actual vs Estimate")
                Chart(history) { item in
                    BarMark(
                        x: .value("Quarter", item.quarter),
                        y: .value("EPS", item.epsActual)
                    )
                    .foregroundStyle(Theme.nanoBananaGradient)
                    .cornerRadius(4)

                    PointMark(
                        x: .value("Quarter", item.quarter),
                        y: .value("Estimate", item.epsEstimate)
                    )
                    .foregroundStyle(Theme.text3)
                    .symbolSize(30)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks { v in
                        AxisValueLabel { if let d = v.as(Double.self) { Text("$\(String(format: "%.2f", d))").font(.system(size: 9)).foregroundStyle(Theme.text3) } }
                        AxisGridLine().foregroundStyle(Theme.bg3)
                    }
                }
                .chartXAxis {
                    AxisMarks { v in
                        AxisValueLabel { if let s = v.as(String.self) { Text(s).font(.system(size: 9)).foregroundStyle(Theme.text3) } }
                    }
                }
                .padding(.horizontal, 20)

                HStack(spacing: 14) {
                    HStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 2).fill(Theme.nanoBanana).frame(width: 12, height: 8)
                        Text("Actual EPS").font(.system(size: 10)).foregroundStyle(Theme.text3)
                    }
                    HStack(spacing: 5) {
                        Circle().fill(Theme.text3).frame(width: 7, height: 7)
                        Text("Estimate").font(.system(size: 10)).foregroundStyle(Theme.text3)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Sentiment Tab

    @ViewBuilder
    private func sentimentTab() -> some View {
        let opts = optionsSentiment
        let analysis = aiAnalysis

        VStack(alignment: .leading, spacing: 20) {
            // Bull/bear gauge
            VStack(alignment: .leading, spacing: 12) {
                sectionLabel("Community Sentiment")
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(Theme.gain).frame(width: 8, height: 8)
                            Text("Bull")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.text2)
                            Text("\(opts.bullPct)%")
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(Theme.gain)
                        }
                        HStack(spacing: 6) {
                            Circle().fill(Theme.loss).frame(width: 8, height: 8)
                            Text("Bear")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.text2)
                            Text("\(100 - opts.bullPct)%")
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(Theme.loss)
                        }
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(Theme.bg3, lineWidth: 12)
                            .frame(width: 80, height: 80)
                        Circle()
                            .trim(from: 0, to: CGFloat(opts.bullPct) / 100)
                            .stroke(Theme.gain, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 80, height: 80)
                        Circle()
                            .trim(from: CGFloat(opts.bullPct) / 100, to: 1)
                            .stroke(Theme.loss, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 80, height: 80)
                        Text("\(opts.bullPct)%")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(Theme.text)
                    }
                }
                .padding(16)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // AI analysis
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("AI Analysis")
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.nanoBanana)
                            Text("Powered by Claude")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.text3)
                        }
                        Spacer()
                        sentimentBadge(analysis.sentiment)
                    }
                    Text(analysis.text)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.text2)
                        .lineSpacing(5)
                    Text("Based on public filings, analyst notes & options data")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.text4)
                }
                .padding(16)
                .background(LinearGradient(colors: [Theme.accent.opacity(0.10), Theme.accent.opacity(0.03)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.accent.opacity(0.20), lineWidth: 1))
            }
            .padding(.horizontal, 20)

            // Options sentiment
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Options Flow")
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Put/Call Ratio")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.text2)
                        Spacer()
                        Text(String(format: "%.2f", opts.putCall))
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(opts.isBullish ? Theme.gain : Theme.loss)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6).fill(Theme.loss.opacity(0.25)).frame(height: 14)
                            let callFrac = min(1.0, 1.0 / (1.0 + opts.putCall))
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LinearGradient(colors: [Theme.nanoBanana, Color(hex: "#A8D020")], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * CGFloat(callFrac), height: 14)
                        }
                    }
                    .frame(height: 14)
                    HStack {
                        Label("Calls", systemImage: "arrow.up.circle.fill").font(.system(size: 10, weight: .semibold)).foregroundStyle(Theme.gain)
                        Spacer()
                        Label("Puts", systemImage: "arrow.down.circle.fill").font(.system(size: 10, weight: .semibold)).foregroundStyle(Theme.loss)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: opts.isBullish ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .foregroundStyle(opts.isBullish ? Theme.gain : Theme.loss)
                        Text(opts.label)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(opts.isBullish ? Theme.gain : Theme.loss)
                    }
                }
                .padding(16)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Fundamentals Tab

    @ViewBuilder
    private func fundamentalsTab() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // All key stats
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Price Statistics")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(keyStats, id: \.label) { s in
                        HStack {
                            Text(s.label)
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.text3)
                            Spacer()
                            Text(s.value)
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Theme.text)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 16)

            // Valuation ratios
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Valuation & Ratios")
                VStack(spacing: 0) {
                    ForEach(fundamentalRatios.indices, id: \.self) { i in
                        let r = fundamentalRatios[i]
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(r.label)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Theme.text)
                                Text(r.context)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.text4)
                            }
                            Spacer()
                            Text(r.value)
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(Theme.nanoBanana)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        if i < fundamentalRatios.count - 1 {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Financials Tab

    @ViewBuilder
    private func financialsTab() -> some View {
        let bars = financialBars
        VStack(alignment: .leading, spacing: 20) {
            // Revenue chart
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Quarterly Revenue (Billions)")
                Chart(bars) { b in
                    BarMark(x: .value("Q", b.quarter), y: .value("Rev", b.revenue))
                        .foregroundStyle(Theme.nanoBananaGradient)
                        .cornerRadius(4)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks { v in
                        AxisValueLabel { if let d = v.as(Double.self) { Text("$\(String(format: "%.0f", d))B").font(.system(size: 9)).foregroundStyle(Theme.text3) } }
                        AxisGridLine().foregroundStyle(Theme.bg3)
                    }
                }
                .chartXAxis {
                    AxisMarks { v in
                        AxisValueLabel { if let s = v.as(String.self) { Text(s).font(.system(size: 8)).foregroundStyle(Theme.text3) } }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 16)

            // EPS chart
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Quarterly EPS")
                Chart(bars) { b in
                    LineMark(x: .value("Q", b.quarter), y: .value("EPS", b.eps))
                        .foregroundStyle(Theme.accentGradient)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.catmullRom)
                    AreaMark(x: .value("Q", b.quarter), yStart: .value("base", 0), yEnd: .value("EPS", b.eps))
                        .foregroundStyle(LinearGradient(colors: [Theme.accent.opacity(0.25), .clear], startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.catmullRom)
                }
                .frame(height: 160)
                .chartYAxis {
                    AxisMarks { v in
                        AxisValueLabel { if let d = v.as(Double.self) { Text("$\(String(format: "%.2f", d))").font(.system(size: 9)).foregroundStyle(Theme.text3) } }
                        AxisGridLine().foregroundStyle(Theme.bg3)
                    }
                }
                .chartXAxis {
                    AxisMarks { v in
                        AxisValueLabel { if let s = v.as(String.self) { Text(s).font(.system(size: 8)).foregroundStyle(Theme.text3) } }
                    }
                }
                .padding(.horizontal, 20)
            }

            // Net margin trend
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Net Margin %")
                Chart(bars) { b in
                    LineMark(x: .value("Q", b.quarter), y: .value("Margin", b.netMargin))
                        .foregroundStyle(Theme.gain)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 3]))
                        .interpolationMethod(.catmullRom)
                    PointMark(x: .value("Q", b.quarter), y: .value("Margin", b.netMargin))
                        .foregroundStyle(Theme.gain)
                        .symbolSize(20)
                }
                .frame(height: 130)
                .chartYAxis {
                    AxisMarks { v in
                        AxisValueLabel { if let d = v.as(Double.self) { Text("\(String(format: "%.0f", d))%").font(.system(size: 9)).foregroundStyle(Theme.text3) } }
                        AxisGridLine().foregroundStyle(Theme.bg3)
                    }
                }
                .chartXAxis {
                    AxisMarks { v in
                        AxisValueLabel { if let s = v.as(String.self) { Text(s).font(.system(size: 8)).foregroundStyle(Theme.text3) } }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - News Tab

    @ViewBuilder
    private func newsTab() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Latest News")
                .padding(.top, 16)

            ForEach(newsItems) { item in
                newsCard(item)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Chart

    @ViewBuilder
    private func chartBody() -> some View {
        if isLoading {
            RoundedRectangle(cornerRadius: 12).fill(Theme.bg2).frame(height: 200)
                .overlay(ProgressView().tint(Theme.nanoBanana))
        } else if error || chartData.isEmpty {
            RoundedRectangle(cornerRadius: 12).fill(Theme.bg2).frame(height: 200)
                .overlay(Text("Chart unavailable").font(.system(size: 13)).foregroundStyle(Theme.text3))
        } else {
            Chart(chartData) { point in
                LineMark(x: .value("Index", point.index), y: .value("Price", point.value))
                    .foregroundStyle(Theme.nanoBanana)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .interpolationMethod(.catmullRom)
                AreaMark(x: .value("Index", point.index),
                         yStart: .value("Min", chartData.map(\.value).min() ?? 0),
                         yEnd: .value("Price", point.value))
                    .foregroundStyle(LinearGradient(colors: [Theme.nanoBanana.opacity(0.22), .clear], startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: strideValues()) { value in
                    AxisValueLabel {
                        if let i = value.as(Int.self), i < chartData.count {
                            Text(chartData[i].label).font(.system(size: 10)).foregroundStyle(Theme.text3)
                        }
                    }
                    AxisGridLine().foregroundStyle(Color.clear)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("$\(String(format: "%.0f", v))").font(.system(size: 10)).foregroundStyle(Theme.text3)
                        }
                    }
                    AxisGridLine().foregroundStyle(Theme.bg2)
                }
            }
            .frame(height: 220)
        }
    }

    func strideValues() -> [Int] {
        guard chartData.count > 1 else { return [] }
        let step = max(1, chartData.count / 6)
        return stride(from: 0, to: chartData.count, by: step).map { $0 }
    }

    func loadChart() async {
        isLoading = true; error = false; chartData = []
        do { chartData = try await QuoteService.fetchHistory(ticker, range: range) }
        catch { self.error = true }
        isLoading = false
    }

    // MARK: - Helper Components

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(Theme.text3)
            .textCase(.uppercase)
            .kerning(1.2)
            .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func statCell(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.text4)
                .textCase(.uppercase)
                .kerning(0.3)
            Text(value)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(Theme.text)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
    }

    @ViewBuilder
    private func beatSummaryChip(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 16, weight: .black)).foregroundStyle(color)
            Text(label).font(.system(size: 9, weight: .bold)).foregroundStyle(Theme.text3).textCase(.uppercase).kerning(0.3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.25), lineWidth: 1))
    }

    @ViewBuilder
    private func earningsRow(_ item: EarningsBeat) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(item.quarter)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.text)
                Spacer()
                HStack(spacing: 8) {
                    beatPill("EPS", item.beatEPS)
                    beatPill("Rev", item.beatRev)
                }
            }
            .padding(.horizontal, 14).padding(.top, 12)

            HStack(spacing: 0) {
                earningsMetric("EPS Actual", "$\(String(format: "%.2f", item.epsActual))", Theme.text)
                earningsMetric("Estimate", "$\(String(format: "%.2f", item.epsEstimate))", Theme.text3)
                earningsMetric("Surprise", (item.epsSurprise >= 0 ? "+" : "") + String(format: "%.1f", item.epsSurprise) + "%",
                               item.epsSurprise >= 0 ? Theme.gain : Theme.loss)
                earningsMetric("Revenue", "$\(String(format: "%.1f", item.revActual))B", Theme.nanoBanana)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
    }

    @ViewBuilder
    private func earningsMetric(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 13, weight: .black)).foregroundStyle(color)
            Text(label).font(.system(size: 9)).foregroundStyle(Theme.text4).textCase(.uppercase).kerning(0.2)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func beatPill(_ label: String, _ beat: Bool) -> some View {
        Text(beat ? "\(label) ✓" : "\(label) ✗")
            .font(.system(size: 9, weight: .black))
            .foregroundStyle(beat ? Theme.gain : Theme.loss)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background((beat ? Theme.gain : Theme.loss).opacity(0.12))
            .clipShape(Capsule())
    }

    @ViewBuilder
    private func sentimentBadge(_ sentiment: String) -> some View {
        let color: Color = sentiment == "Bullish" ? Theme.gain : sentiment == "Bearish" ? Theme.loss : Theme.gold
        Text(sentiment)
            .font(.system(size: 10, weight: .black))
            .foregroundStyle(color)
            .padding(.horizontal, 9).padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    @ViewBuilder
    private func newsCard(_ item: StockNewsItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(item.source)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Theme.accentBg)
                    .clipShape(Capsule())
                Spacer()
                Text(item.timeAgo)
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.text4)
                sentimentBadge(item.sentiment)
            }
            Text(item.headline)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.text)
                .lineSpacing(3)
                .lineLimit(3)
            Text(item.summary)
                .font(.system(size: 12))
                .foregroundStyle(Theme.text3)
                .lineSpacing(4)
                .lineLimit(3)
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }
}
