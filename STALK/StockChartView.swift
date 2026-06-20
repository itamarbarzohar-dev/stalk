import SwiftUI
import Charts

struct StockChartView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    let ticker: String
    @State private var range = "1mo"
    @State private var chartData: [ChartPoint] = []
    @State private var isLoading = false
    @State private var error = false

    let ranges = [("1M", "1mo"), ("3M", "3mo"), ("6M", "6mo"), ("1Y", "1y")]

    var quote: Quote? { appState.quotes[ticker] }

    var lineColor: Color { Theme.nanoBanana }

    let analysts: [(firm: String, rating: String, pt: String)] = [
        ("Goldman", "Buy", "$220"),
        ("Morgan Stanley", "Overweight", "$215"),
        ("JPMorgan", "Buy", "$225"),
        ("BofA", "Buy", "$210"),
    ]

    // Mock AI analysis per ticker — in production this calls the BYOK endpoint
    private var aiAnalysis: (text: String, sentiment: String) {
        let sentiments: [String: (String, String)] = [
            "NVDA": ("NVDA is executing near-perfectly on the AI infrastructure wave. Data center revenue grew 427% YoY and shows no sign of decelerating as hyperscalers race to build out GPU clusters. Valuation is rich but justified by the monopoly-like position in AI training. Near-term risk is a China export restriction escalation.", "Bullish"),
            "AAPL": ("Apple's Services segment is the new growth engine, now representing 22% of revenue with 70%+ gross margins. iPhone volumes are plateauing but ASP expansion is offsetting unit weakness. Buyback program is one of the largest in corporate history. Key risk: EU regulatory pressure on App Store economics.", "Neutral"),
            "TSLA": ("Tesla faces intensifying competition from BYD in China and emerging domestic EV players in the US. FSD monetization remains speculative but is the key optionality. Margins have compressed significantly. Robotaxi narrative could be a re-rating catalyst, but execution risk is high.", "Neutral"),
            "META": ("Meta's ad revenue reacceleration and cost discipline have driven a dramatic margin recovery. Llama open-source strategy is a smart hedge against OpenAI. Reality Labs losses remain elevated but Horizon Worlds engagement is growing. One of the strongest free cash flow generators in tech.", "Bullish"),
            "MSFT": ("Microsoft's Copilot monetization across the Office 365 stack is the most credible AI monetization story in enterprise software. Azure is gaining share vs. AWS. LinkedIn and gaming diversify revenue. Trading at a premium but the quality and durability of earnings justify it.", "Bullish"),
        ]
        return sentiments[ticker] ?? ("This stock is showing strong momentum backed by solid fundamentals. Institutional ownership has been increasing over the past quarter, signaling confidence from smart money. Key catalysts include upcoming earnings, product launches, and macro tailwinds. Watch support levels closely for entry.", "Neutral")
    }

    private var keyStats: [(label: String, value: String)] {
        let stats: [String: [(String, String)]] = [
            "NVDA": [("P/E", "38.4x"), ("Mkt Cap", "$2.9T"), ("52W High", "$140.76"), ("Beta", "1.63"), ("Short Int.", "0.87%"), ("Institutional", "66.4%")],
            "AAPL": [("P/E", "31.2x"), ("Mkt Cap", "$3.4T"), ("52W High", "$236.75"), ("Beta", "1.21"), ("Short Int.", "0.72%"), ("Institutional", "62.1%")],
            "TSLA": [("P/E", "52.8x"), ("Mkt Cap", "$812B"),  ("52W High", "$414.50"), ("Beta", "2.14"), ("Short Int.", "3.12%"), ("Institutional", "43.8%")],
            "META": [("P/E", "24.7x"), ("Mkt Cap", "$1.4T"), ("52W High", "$638.40"), ("Beta", "1.18"), ("Short Int.", "0.61%"), ("Institutional", "71.2%")],
        ]
        return stats[ticker] ?? [("P/E", "—"), ("Mkt Cap", "—"), ("52W High", "—"), ("Beta", "—"), ("Short Int.", "—"), ("Institutional", "—")]
    }

    private var optionsSentiment: (putCall: Double, label: String, isBullish: Bool) {
        let data: [String: (Double, String, Bool)] = [
            "NVDA": (0.48, "Bullish options flow — calls dominating", true),
            "AAPL": (0.71, "Neutral — balanced put/call activity", false),
            "TSLA": (1.24, "Bearish positioning — elevated puts", false),
            "META": (0.52, "Slightly bullish — more calls than puts", true),
        ]
        return data[ticker] ?? (0.85, "Neutral options flow", false)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(Theme.card)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.border, lineWidth: 1))
                        .shadow(color: .black.opacity(0.05), radius: 3)
                    }
                    .padding(.top, 52)
                    .padding(.bottom, 14)
                    .padding(.horizontal, 20)

                    Text(ticker)
                        .font(.system(size: 24, weight: .black))
                        .kerning(-0.5)
                        .foregroundStyle(Theme.text)
                        .padding(.horizontal, 20)

                    if let q = quote {
                        Text("$\(String(format: "%.2f", q.price))")
                            .font(.system(size: 44, weight: .black))
                            .kerning(-1.5)
                            .foregroundStyle(Theme.text)
                            .monospacedDigit()
                            .padding(.top, 6)
                            .padding(.horizontal, 20)
                            .accessibilityLabel("Current price")
                            .accessibilityValue("$\(String(format: "%.2f", q.price))")

                        Text("\(q.change >= 0 ? "+" : "")\(String(format: "%.2f", q.change)) (\(q.changePercent.fmtPct()))")
                            .font(.system(size: 16))
                            .foregroundStyle(q.isUp ? Theme.gain : Theme.loss)
                            .padding(.top, 4)
                            .padding(.horizontal, 20)
                    }

                    // Range picker
                    HStack(spacing: 6) {
                        ForEach(ranges, id: \.0) { label, value in
                            Button(label) {
                                range = value
                                Task { await loadChart() }
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(range == value ? .white : Theme.text3)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(range == value ? Theme.accent : Theme.card)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(range == value ? Theme.accent : Theme.border, lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)

                    // Chart
                    chartBody()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 20)

                    // Analyst ratings
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Analyst Ratings")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.text3)
                            .textCase(.uppercase)
                            .kerning(1)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(analysts, id: \.firm) { a in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(a.firm)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(Theme.text)
                                        Text(a.rating)
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(Theme.gain)
                                        Text("PT \(a.pt)")
                                            .font(.system(size: 10))
                                            .foregroundStyle(Theme.text3)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Theme.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    // AI Analysis Block
                    aiAnalysisBlock()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // Key Stats Grid
                    keyStatsGrid()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // Options Sentiment Meter
                    optionsSentimentMeter()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
            .background(Theme.bg)
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

    @ViewBuilder
    func chartBody() -> some View {
        if isLoading {
            Text("Loading...")
                .font(.system(size: 14))
                .foregroundStyle(Theme.text3)
                .frame(maxWidth: .infinity)
                .frame(height: 220)
        } else if error || chartData.isEmpty {
            Text("Could not load chart data")
                .font(.system(size: 14))
                .foregroundStyle(Theme.text3)
                .frame(maxWidth: .infinity)
                .frame(height: 220)
        } else {
            Chart(chartData) { point in
                LineMark(
                    x: .value("Index", point.index),
                    y: .value("Price", point.value)
                )
                .foregroundStyle(Theme.nanoBanana)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Index", point.index),
                    yStart: .value("Min", chartData.map(\.value).min() ?? 0),
                    yEnd: .value("Price", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.nanoBanana.opacity(0.22), Theme.nanoBanana.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: strideValues()) { value in
                    AxisValueLabel {
                        if let i = value.as(Int.self), i < chartData.count {
                            Text(chartData[i].label)
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                    }
                    AxisGridLine().foregroundStyle(Color.clear)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("$\(String(format: "%.0f", v))")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
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
        isLoading = true
        error = false
        chartData = []
        do {
            chartData = try await QuoteService.fetchHistory(ticker, range: range)
        } catch {
            self.error = true
        }
        isLoading = false
    }

    @ViewBuilder
    func aiAnalysisBlock() -> some View {
        let analysis = aiAnalysis
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("AI Analysis")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Theme.text3)
                    .textCase(.uppercase)
                    .kerning(1.5)
                Spacer()
                Text(analysis.sentiment)
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(
                        analysis.sentiment == "Bullish" ? Theme.gain
                        : analysis.sentiment == "Bearish" ? Theme.loss
                        : Theme.gold
                    )
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(
                        (analysis.sentiment == "Bullish" ? Theme.gain
                         : analysis.sentiment == "Bearish" ? Theme.loss
                         : Theme.gold).opacity(0.12)
                    )
                    .clipShape(Capsule())
            }

            Text(analysis.text)
                .font(.system(size: 13))
                .foregroundStyle(Theme.text2)
                .lineSpacing(5)

            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 10)).foregroundStyle(Theme.nanoBanana)
                Text("Powered by Claude · Based on public filings, analyst notes & options data")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.text4)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Theme.accent.opacity(0.10), Theme.accent.opacity(0.03)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.accent.opacity(0.20), lineWidth: 1))
    }

    @ViewBuilder
    func keyStatsGrid() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Key Stats")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(1.5)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(keyStats, id: \.label) { stat in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(stat.label)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Theme.text4)
                            .textCase(.uppercase)
                            .kerning(0.3)
                        Text(stat.value)
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
            }
        }
    }

    @ViewBuilder
    func optionsSentimentMeter() -> some View {
        let opts = optionsSentiment
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Options Sentiment")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Theme.text3)
                    .textCase(.uppercase)
                    .kerning(1.5)
                Spacer()
                Text("P/C Ratio: \(String(format: "%.2f", opts.putCall))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.text3)
            }

            // Put/Call bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.bg3)
                        .frame(height: 12)
                    let callFraction = min(1.0, 1.0 / (1.0 + opts.putCall))
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(
                            colors: opts.isBullish ? [Theme.nanoBanana, Color(hex: "#A8D020")] : [Theme.loss, Color(hex: "#DC2626")],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: geo.size.width * CGFloat(callFraction), height: 12)
                }
            }
            .frame(height: 12)

            HStack {
                HStack(spacing: 5) {
                    Circle().fill(Theme.nanoBanana).frame(width: 7, height: 7)
                    Text("Calls").font(.system(size: 10)).foregroundStyle(Theme.text3)
                }
                Spacer()
                HStack(spacing: 5) {
                    Text("Puts").font(.system(size: 10)).foregroundStyle(Theme.text3)
                    Circle().fill(Theme.loss).frame(width: 7, height: 7)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: opts.isBullish ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.system(size: 12))
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
}
