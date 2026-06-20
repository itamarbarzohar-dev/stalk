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
}
