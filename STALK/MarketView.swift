import SwiftUI
import Combine

private let INDEX_SF: [String: (symbol: String, color: Color)] = [
    "SPY": ("chart.bar.fill",        Color(hex: "#3B82F6")),
    "QQQ": ("cpu.fill",              Color(hex: "#8B5CF6")),
    "DIA": ("building.columns.fill", Color(hex: "#22C55E")),
    "IWM": ("chart.pie.fill",        Color(hex: "#F97316")),
]

struct MarketView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void
    @State private var now = Date()
    @State private var showScreener = false
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var marketStatus: MarketStatus { MarketCalendar.status(at: now) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Bloomberg-style nav bar header
                HStack(spacing: 10) {
                    Text("MARKETS")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Theme.text)
                        .kerning(0.5)
                    Spacer()
                    HStack(spacing: 6) {
                        Circle().fill(marketStatus.dotColor).frame(width: 7, height: 7)
                            .overlay(
                                Circle().fill(marketStatus.dotColor.opacity(0.3))
                                    .frame(width: 13, height: 13)
                                    .opacity(marketStatus.isLive ? 1 : 0)
                            )
                        Text(marketStatus.label)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(marketStatus.dotColor)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(marketStatus.dotColor.opacity(0.10))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(marketStatus.dotColor.opacity(0.25), lineWidth: 1))
                }
                .padding(.horizontal, 16)
                .padding(.top, 52)
                .padding(.bottom, 16)

                // Watchlist tab teaser
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        appState.selectedTab = .watchlist
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "list.star")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color(hex: "#F59E0B"))
                        Text("My Watchlists")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.text2)
                        Text("\(appState.userWatchlists.count) lists · \(appState.watchlist.count) symbols")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.text4)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color(hex: "#F59E0B"))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                    .padding(.horizontal, 14)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)

                // Stock screener entry
                Button { showScreener = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.accent)
                        Text("Stock Screener")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.text2)
                        Text("Filter by sector, P/E, momentum")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.text4)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                    .padding(.horizontal, 14)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 16)

                // Indices — compact Bloomberg rows
                marketSectionLabel("Indices")
                IndexCompactList(appState: appState, onTicker: onTicker)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)

                // Fear & Greed gauge
                marketSectionLabel("Fear & Greed Index")
                FearGreedGaugeCard()
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)

                // Top Movers grid
                marketSectionLabel("Top Movers")
                TopMoversGrid(onTicker: onTicker)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)

                // Sector Chips (horizontal scroll)
                marketSectionLabel("Sectors")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(SECTORS, id: \.etf) { sector in
                            SectorChip(sector: sector, quote: appState.marketQuotes[sector.etf], onTap: { onTicker(sector.etf) })
                        }
                    }
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 20)

                // Sector Heat Map — taller tiles
                marketSectionLabel("Sector Heat Map")
                SectorHeatMapView(onTicker: onTicker)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)

                // Trending Tickers Feed
                marketSectionLabel("Trending · Social Buzz")
                TrendingTickersFeedView(onTicker: onTicker)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)

                // Classic Trending
                marketSectionLabel("Trending")
                VStack(spacing: 8) {
                    ForEach(TRENDING_TICKERS, id: \.self) { ticker in
                        if let q = appState.marketQuotes[ticker] {
                            MarketRow(name: ticker, subtitle: q.name, quote: q, onTap: { onTicker(ticker) })
                        } else {
                            MarketRowSkeleton()
                        }
                    }
                }
                .padding(.horizontal, 14)

                Color.clear.frame(height: 100)
            }
        }
        .background(Theme.bg)
        .task { await appState.refreshMarket() }
        .refreshable { await appState.refreshMarket() }
        .onReceive(timer) { now = $0 }
        .sheet(isPresented: $showScreener) {
            ScreenerSheet(onTicker: onTicker)
        }
    }

    func marketSectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .black))
            .foregroundStyle(Theme.text3)
            .textCase(.uppercase)
            .kerning(2.5)
            .padding(.horizontal, 14)
            .padding(.bottom, 9)
    }
}

// MARK: - Index Compact List (Bloomberg rows)

struct IndexCompactList: View {
    let appState: AppState
    let onTicker: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(INDEX_TICKERS.enumerated()), id: \.element) { i, ticker in
                Button { onTicker(ticker) } label: {
                    HStack(spacing: 12) {
                        // Icon + name
                        let sfEntry = INDEX_SF[ticker] ?? ("chart.bar.fill", Theme.accent)
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(sfEntry.color.opacity(0.15))
                                .frame(width: 28, height: 28)
                            Image(systemName: sfEntry.symbol)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(sfEntry.color)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text(INDEX_NAMES[ticker] ?? ticker)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text(ticker)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Theme.text3)
                        }
                        Spacer()
                        if let q = appState.marketQuotes[ticker] {
                            HStack(spacing: 8) {
                                Text(q.price.fmtPrice())
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                    .monospacedDigit()
                                Text(q.changePercent.fmtPct())
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(q.isUp ? Theme.gain : Theme.loss)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background((q.isUp ? Theme.gain : Theme.loss).opacity(0.14))
                                    .clipShape(Capsule())
                            }
                        } else {
                            VStack(alignment: .trailing, spacing: 4) {
                                RoundedRectangle(cornerRadius: 3).fill(Theme.bg2).frame(width: 54, height: 12)
                                RoundedRectangle(cornerRadius: 3).fill(Theme.bg2).frame(width: 36, height: 10)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
                .buttonStyle(.plain)

                if i < INDEX_TICKERS.count - 1 {
                    Rectangle()
                        .fill(Theme.border)
                        .frame(height: 1)
                        .padding(.leading, 56)
                }
            }
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
    }
}

// MARK: - Top Movers Grid

private let topMovers: [(ticker: String, change: Double, icon: String, iconColor: Color)] = [
    ("NVDA", 4.2,  "cpu.fill",              Color(hex: "#8B5CF6")),
    ("GME",  8.1,  "gamecontroller.fill",   Color(hex: "#22C55E")),
    ("TSLA", -2.8, "bolt.car.circle.fill",  Color(hex: "#3B82F6")),
    ("AAPL", 1.2,  "applelogo",             Color(hex: "#6B7280")),
    ("META", 2.1,  "person.2.fill",         Color(hex: "#3B82F6")),
    ("PLTR", 5.3,  "waveform.path.ecg",     Color(hex: "#F97316")),
    ("AMD",  1.8,  "memorychip.fill",       Color(hex: "#EF4444")),
    ("AMZN", -0.9, "shippingbox.fill",      Color(hex: "#F59E0B")),
]

struct TopMoversGrid: View {
    let onTicker: (String) -> Void
    let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(topMovers, id: \.ticker) { mover in
                Button { onTicker(mover.ticker) } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(mover.iconColor.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: mover.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(mover.iconColor)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(mover.ticker)
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(Theme.text)
                            Text(mover.change >= 0 ? "+\(String(format: "%.1f", mover.change))%" : "\(String(format: "%.1f", mover.change))%")
                                .font(.system(size: 16, weight: .black))
                                .foregroundStyle(mover.change >= 0 ? Theme.gain : Theme.loss)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .frame(height: 70)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(
                        mover.change >= 0 ? Theme.gain.opacity(0.30) : Theme.loss.opacity(0.30),
                        lineWidth: 1.5
                    ))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(mover.ticker), \(mover.change >= 0 ? "up" : "down") \(String(format: "%.1f", abs(mover.change))) percent today")
            }
        }
    }
}

// MARK: - Sector Chip

struct SectorChip: View {
    let sector: SectorInfo
    let quote: Quote?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(sector.icon)
                    .font(.system(size: 18))
                Text(sector.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.text2)
                Text(sector.etf)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.text3)
                if let q = quote {
                    Text(q.changePercent.fmtPct())
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(q.isUp ? Theme.gain : Theme.loss)
                } else {
                    Text("—")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(Theme.text3)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Market Row

struct MarketRow: View {
    let name: String
    let subtitle: String
    let quote: Quote
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(quote.price.fmtPrice())
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text(quote.changePercent.fmtPct())
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(quote.isUp ? Theme.gain : Theme.loss)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
            .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
        }
        .buttonStyle(.plain)
    }
}

struct MarketRowSkeleton: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4).fill(Theme.bg2).frame(width: 80, height: 14)
                RoundedRectangle(cornerRadius: 4).fill(Theme.bg2).frame(width: 50, height: 11)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                RoundedRectangle(cornerRadius: 4).fill(Theme.bg2).frame(width: 60, height: 14)
                RoundedRectangle(cornerRadius: 4).fill(Theme.bg2).frame(width: 40, height: 12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
    }
}

// MARK: - Sector Heat Map

struct SectorTile: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let change: Double
    let icon: String
}

private let heatMapSectors: [SectorTile] = [
    SectorTile(name: "Technology",      symbol: "XLK",  change: 1.8,  icon: "cpu"),
    SectorTile(name: "Energy",          symbol: "XLE",  change: 2.3,  icon: "flame"),
    SectorTile(name: "Healthcare",      symbol: "XLV",  change: -0.4, icon: "heart"),
    SectorTile(name: "Financials",      symbol: "XLF",  change: 0.9,  icon: "building.columns"),
    SectorTile(name: "Industrials",     symbol: "XLI",  change: 0.2,  icon: "gear"),
    SectorTile(name: "Consumer Disc.",  symbol: "XLY",  change: -1.1, icon: "cart"),
    SectorTile(name: "Comm. Services",  symbol: "XLC",  change: 1.4,  icon: "antenna.radiowaves.left.and.right"),
    SectorTile(name: "Utilities",       symbol: "XLU",  change: -0.7, icon: "bolt.fill"),
    SectorTile(name: "Real Estate",     symbol: "XLRE", change: -0.3, icon: "house"),
    SectorTile(name: "Materials",       symbol: "XLB",  change: 0.5,  icon: "cube"),
    SectorTile(name: "Cons. Staples",   symbol: "XLP",  change: -0.2, icon: "basket"),
]

struct SectorHeatMapView: View {
    let onTicker: (String) -> Void
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    func tileColor(_ change: Double) -> Color {
        let gain = Color(hex: "#00D26A")
        let loss = Color(hex: "#FF4757")
        let flat = Color(hex: "#1A1A2E")
        if change >= 3.0  { return Color(hex: "#00C853") }
        if change >= 1.5  { return gain }
        if change >= 0.5  { return gain.opacity(0.55) }
        if change > -0.5  { return flat }
        if change >= -1.5 { return loss.opacity(0.55) }
        if change >= -3.0 { return loss }
        return Color(hex: "#CC0000")
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(heatMapSectors) { tile in
                Button { onTicker(tile.symbol) } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(tileColor(tile.change))

                    // Nano banana glow for strongly positive sectors
                    if tile.change >= 1.5 {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                RadialGradient(
                                    colors: [Theme.nanoBanana.opacity(tile.change >= 3.0 ? 0.30 : 0.18), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 55
                                )
                            )
                    } else if tile.change > 0 {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "#00D26A").opacity(0.18), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                    }

                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            tile.change >= 1.5
                                ? Theme.nanoBanana.opacity(0.35)
                                : Color.white.opacity(tile.change > 0 ? 0.15 : 0.06),
                            lineWidth: 1
                        )

                    VStack(spacing: 5) {
                        Image(systemName: tile.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.90))

                        Text(tile.name)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)

                        Text(tile.change.fmtPct())
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(tile.change >= 1.5 ? Theme.nanoBanana : .white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 12)
                }
                .frame(minHeight: 100)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(tile.name), \(tile.change.fmtPct()) today, opens \(tile.symbol)")
            }
        }
    }
}

// MARK: - Fear & Greed Gauge

struct FearGreedGaugeCard: View {
    // Mock composite score 0–100
    let score: Double = 72

    var label: String {
        switch score {
        case ..<25:  return "Extreme Fear"
        case ..<45:  return "Fear"
        case ..<55:  return "Neutral"
        case ..<75:  return "Greed"
        default:     return "Extreme Greed"
        }
    }

    var scoreColor: Color {
        switch score {
        case ..<25:  return Color(hex: "#FF4757")
        case ..<45:  return Color(hex: "#F97316")
        case ..<55:  return Color(hex: "#F5A623")
        case ..<75:  return Color(hex: "#84CC16")
        default:     return Color(hex: "#00D26A")
        }
    }

    @State private var animatedScore: Double = 0

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                // Track — top semicircle
                Circle()
                    .trim(from: 0.5, to: 1.0)
                    .stroke(Theme.bg3, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .frame(width: 160, height: 160)

                // Colored arc fear→greed
                Circle()
                    .trim(from: 0.5, to: 0.5 + animatedScore / 200)
                    .stroke(
                        AngularGradient(
                            colors: [Color(hex: "#FF4757"), Color(hex: "#F97316"),
                                     Color(hex: "#F5A623"), Color(hex: "#84CC16"), Color(hex: "#00D26A")],
                            center: .center,
                            startAngle: .degrees(180),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)

                VStack(spacing: 2) {
                    Text("\(Int(score))")
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(Theme.text)
                        .monospacedDigit()
                    Text(label.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(scoreColor)
                        .kerning(1.5)
                }
                .offset(y: -26)
            }
            .frame(width: 190, height: 190)
            .frame(height: 106, alignment: .top)
            .clipped()
            .frame(maxWidth: .infinity)

            HStack {
                Text("EXTREME FEAR")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color(hex: "#FF4757").opacity(0.8))
                Spacer()
                Text("EXTREME GREED")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color(hex: "#00D26A").opacity(0.8))
            }
            .padding(.horizontal, 20)

            Rectangle().fill(Theme.border).frame(height: 1)

            HStack(spacing: 0) {
                fgStat("Momentum", "Greed")
                fgStat("Volatility", "Neutral")
                fgStat("P/C Ratio", "Greed")
                fgStat("Breadth", "Fear")
            }
        }
        .padding(.vertical, 16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                animatedScore = score
            }
        }
    }

    func fgStat(_ name: String, _ value: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(value == "Fear" ? Theme.loss : value == "Neutral" ? Theme.gold : Theme.gain)
            Text(name.uppercased())
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(Theme.text3)
                .kerning(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Trending Tickers Feed

struct TrendingTicker: Identifiable {
    let id = UUID()
    let ticker: String
    let name: String
    let change: Double
    let mentions: Int
    let reason: String
}

private let trendingTickersData: [TrendingTicker] = [
    TrendingTicker(ticker: "NVDA", name: "NVIDIA",       change: 4.2,  mentions: 24300, reason: "Earnings beat + upgrade"),
    TrendingTicker(ticker: "TSLA", name: "Tesla",        change: -2.1, mentions: 18700, reason: "Delivery miss concerns"),
    TrendingTicker(ticker: "PLTR", name: "Palantir",     change: 3.8,  mentions: 12400, reason: "Government contract news"),
    TrendingTicker(ticker: "GME",  name: "GameStop",     change: 6.3,  mentions: 9800,  reason: "Options flow spike"),
    TrendingTicker(ticker: "AMD",  name: "AMD",          change: 1.9,  mentions: 8100,  reason: "Analyst upgrade"),
    TrendingTicker(ticker: "ARM",  name: "ARM Holdings", change: 2.7,  mentions: 6200,  reason: "AI chip demand"),
]

struct TrendingTickersFeedView: View {
    let onTicker: (String) -> Void

    func mentionLabel(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fK mentions", Double(count) / 1000.0)
        }
        return "\(count) mentions"
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(trendingTickersData.enumerated()), id: \.element.id) { i, item in
                Button { onTicker(item.ticker) } label: {
                    HStack(spacing: 12) {
                        // Rank badge — nano banana for #1
                        Text("#\(i + 1)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(i == 0 ? Theme.nanoBanana : Theme.text3)
                            .frame(width: 24)

                        // Ticker + name
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.ticker)
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(Theme.text)
                            Text(item.name)
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.text3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Reason pill
                        Text(item.reason)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Theme.accent.opacity(0.12))
                            .clipShape(Capsule())
                            .lineLimit(1)

                        // Mentions + change
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(item.change.fmtPct())
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(item.change >= 0 ? Theme.gain : Theme.loss)
                            Text(mentionLabel(item.mentions))
                                .font(.system(size: 9))
                                .foregroundStyle(Theme.text3)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                }
                .buttonStyle(.plain)

                if i < trendingTickersData.count - 1 {
                    Divider()
                        .padding(.leading, 50)
                }
            }
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
    }
}

// MARK: - Stock Screener (TradingView-style)

struct ScreenerStock: Identifiable {
    let id = UUID()
    let ticker: String
    let name: String
    let sector: String
    let price: Double
    let changePct: Double
    let mktCap: Double        // dollars
    let volume: Double        // shares
    let relVolume: Double     // vs 30d avg
    let pe: Double            // 0 = unprofitable
    let eps: Double
    let divYield: Double      // %
    let beta: Double
    let rsi: Double
    let perfWeek: Double
    let perfMonth: Double
    let perfYTD: Double
    let from52High: Double    // % below 52w high (negative)
    let rating: String        // Strong Buy / Buy / Neutral / Sell
}

private let SCREENER_UNIVERSE: [ScreenerStock] = [
    ScreenerStock(ticker: "NVDA", name: "NVIDIA",        sector: "Tech",       price: 172.40, changePct: 4.2,  mktCap: 4_200e9, volume: 312e6, relVolume: 1.8, pe: 51.2,  eps: 3.37, divYield: 0.02, beta: 1.68, rsi: 71, perfWeek: 5.8,  perfMonth: 12.4, perfYTD: 28.2,  from52High: -2.1,  rating: "Strong Buy"),
    ScreenerStock(ticker: "AAPL", name: "Apple",         sector: "Tech",       price: 214.30, changePct: 1.2,  mktCap: 3_300e9, volume: 58e6,  relVolume: 0.9, pe: 32.4,  eps: 6.61, divYield: 0.44, beta: 1.24, rsi: 58, perfWeek: 2.1,  perfMonth: 4.8,  perfYTD: 11.3,  from52High: -4.8,  rating: "Buy"),
    ScreenerStock(ticker: "MSFT", name: "Microsoft",     sector: "Tech",       price: 448.10, changePct: 0.8,  mktCap: 3_350e9, volume: 21e6,  relVolume: 0.7, pe: 36.1,  eps: 12.41, divYield: 0.72, beta: 0.92, rsi: 54, perfWeek: 1.4,  perfMonth: 3.2,  perfYTD: 9.8,   from52High: -6.2,  rating: "Strong Buy"),
    ScreenerStock(ticker: "GOOGL", name: "Alphabet",     sector: "Tech",       price: 186.20, changePct: 1.6,  mktCap: 2_300e9, volume: 28e6,  relVolume: 1.1, pe: 24.8,  eps: 7.51, divYield: 0.43, beta: 1.05, rsi: 61, perfWeek: 3.2,  perfMonth: 6.1,  perfYTD: 14.6,  from52High: -3.4,  rating: "Buy"),
    ScreenerStock(ticker: "META", name: "Meta",          sector: "Tech",       price: 642.80, changePct: 2.1,  mktCap: 1_630e9, volume: 14e6,  relVolume: 1.0, pe: 28.4,  eps: 22.63, divYield: 0.31, beta: 1.21, rsi: 64, perfWeek: 3.8,  perfMonth: 8.2,  perfYTD: 18.9,  from52High: -1.8,  rating: "Buy"),
    ScreenerStock(ticker: "AMD",  name: "AMD",           sector: "Tech",       price: 162.80, changePct: 1.8,  mktCap: 263e9,   volume: 48e6,  relVolume: 1.4, pe: 45.3,  eps: 3.59, divYield: 0,    beta: 1.62, rsi: 62, perfWeek: 4.1,  perfMonth: 9.6,  perfYTD: 22.4,  from52High: -8.4,  rating: "Buy"),
    ScreenerStock(ticker: "PLTR", name: "Palantir",      sector: "Tech",       price: 88.40,  changePct: 5.3,  mktCap: 200e9,   volume: 92e6,  relVolume: 3.8, pe: 210.0, eps: 0.42, divYield: 0,    beta: 2.71, rsi: 76, perfWeek: 9.2,  perfMonth: 18.4, perfYTD: 46.2,  from52High: -0.8,  rating: "Neutral"),
    ScreenerStock(ticker: "INTC", name: "Intel",         sector: "Tech",       price: 24.60,  changePct: -1.4, mktCap: 105e9,   volume: 68e6,  relVolume: 1.2, pe: 0,     eps: -1.24, divYield: 1.9, beta: 1.08, rsi: 34, perfWeek: -3.2, perfMonth: -8.4, perfYTD: -18.6, from52High: -48.2, rating: "Sell"),
    ScreenerStock(ticker: "XOM",  name: "Exxon Mobil",   sector: "Energy",     price: 118.20, changePct: 2.3,  mktCap: 520e9,   volume: 18e6,  relVolume: 1.2, pe: 13.8,  eps: 8.57, divYield: 3.3,  beta: 0.88, rsi: 63, perfWeek: 3.4,  perfMonth: 6.8,  perfYTD: 12.8,  from52High: -2.4,  rating: "Buy"),
    ScreenerStock(ticker: "CVX",  name: "Chevron",       sector: "Energy",     price: 162.50, changePct: 1.9,  mktCap: 290e9,   volume: 9e6,   relVolume: 1.1, pe: 14.6,  eps: 11.13, divYield: 4.1, beta: 0.92, rsi: 59, perfWeek: 2.8,  perfMonth: 5.2,  perfYTD: 9.4,   from52High: -4.1,  rating: "Buy"),
    ScreenerStock(ticker: "OXY",  name: "Occidental",    sector: "Energy",     price: 52.80,  changePct: 3.1,  mktCap: 47e9,    volume: 22e6,  relVolume: 1.6, pe: 12.1,  eps: 4.36, divYield: 1.7,  beta: 1.42, rsi: 66, perfWeek: 4.6,  perfMonth: 8.9,  perfYTD: 6.2,   from52High: -12.4, rating: "Neutral"),
    ScreenerStock(ticker: "JPM",  name: "JPMorgan",      sector: "Finance",    price: 224.60, changePct: 0.9,  mktCap: 640e9,   volume: 8e6,   relVolume: 0.8, pe: 12.4,  eps: 18.11, divYield: 2.1, beta: 1.10, rsi: 56, perfWeek: 1.2,  perfMonth: 2.8,  perfYTD: 8.6,   from52High: -3.8,  rating: "Buy"),
    ScreenerStock(ticker: "GS",   name: "Goldman Sachs", sector: "Finance",    price: 512.30, changePct: 1.1,  mktCap: 165e9,   volume: 2e6,   relVolume: 0.9, pe: 15.2,  eps: 33.70, divYield: 2.3, beta: 1.35, rsi: 58, perfWeek: 1.8,  perfMonth: 4.1,  perfYTD: 13.2,  from52High: -2.9,  rating: "Buy"),
    ScreenerStock(ticker: "BAC",  name: "Bank of America", sector: "Finance",  price: 42.10,  changePct: 0.4,  mktCap: 330e9,   volume: 32e6,  relVolume: 0.7, pe: 13.1,  eps: 3.21, divYield: 2.4,  beta: 1.32, rsi: 51, perfWeek: 0.8,  perfMonth: 1.9,  perfYTD: 5.4,   from52High: -6.8,  rating: "Neutral"),
    ScreenerStock(ticker: "SOFI", name: "SoFi",          sector: "Finance",    price: 14.80,  changePct: 3.1,  mktCap: 16e9,    volume: 46e6,  relVolume: 2.2, pe: 38.0,  eps: 0.39, divYield: 0,    beta: 1.86, rsi: 68, perfWeek: 6.2,  perfMonth: 11.8, perfYTD: 24.6,  from52High: -8.9,  rating: "Buy"),
    ScreenerStock(ticker: "HOOD", name: "Robinhood",     sector: "Finance",    price: 42.60,  changePct: 4.8,  mktCap: 38e9,    volume: 34e6,  relVolume: 2.9, pe: 41.2,  eps: 1.03, divYield: 0,    beta: 2.12, rsi: 72, perfWeek: 8.4,  perfMonth: 16.2, perfYTD: 38.4,  from52High: -1.2,  rating: "Buy"),
    ScreenerStock(ticker: "LLY",  name: "Eli Lilly",     sector: "Healthcare", price: 884.20, changePct: -0.4, mktCap: 840e9,   volume: 3e6,   relVolume: 0.8, pe: 62.8,  eps: 14.08, divYield: 0.68, beta: 0.42, rsi: 46, perfWeek: -1.2, perfMonth: 2.4,  perfYTD: 16.8,  from52High: -8.2,  rating: "Strong Buy"),
    ScreenerStock(ticker: "UNH",  name: "UnitedHealth",  sector: "Healthcare", price: 512.40, changePct: -1.1, mktCap: 470e9,   volume: 4e6,   relVolume: 1.0, pe: 18.9,  eps: 27.11, divYield: 1.6, beta: 0.58, rsi: 38, perfWeek: -2.4, perfMonth: -4.8, perfYTD: -8.2,  from52High: -18.4, rating: "Buy"),
    ScreenerStock(ticker: "MRNA", name: "Moderna",       sector: "Healthcare", price: 42.10,  changePct: 6.8,  mktCap: 16e9,    volume: 28e6,  relVolume: 4.1, pe: 0,     eps: -9.28, divYield: 0,   beta: 1.74, rsi: 64, perfWeek: 12.4, perfMonth: 8.6,  perfYTD: -12.4, from52High: -68.2, rating: "Neutral"),
    ScreenerStock(ticker: "PFE",  name: "Pfizer",        sector: "Healthcare", price: 28.40,  changePct: 0.2,  mktCap: 160e9,   volume: 38e6,  relVolume: 0.9, pe: 17.4,  eps: 1.63, divYield: 5.9,  beta: 0.62, rsi: 44, perfWeek: 0.4,  perfMonth: -1.2, perfYTD: 2.1,   from52High: -14.2, rating: "Neutral"),
    ScreenerStock(ticker: "TSLA", name: "Tesla",         sector: "Consumer",   price: 248.60, changePct: -2.8, mktCap: 790e9,   volume: 88e6,  relVolume: 1.6, pe: 68.2,  eps: 3.65, divYield: 0,    beta: 2.29, rsi: 41, perfWeek: -4.2, perfMonth: -8.4, perfYTD: -14.2, from52High: -38.4, rating: "Neutral"),
    ScreenerStock(ticker: "AMZN", name: "Amazon",        sector: "Consumer",   price: 218.40, changePct: -0.9, mktCap: 2_280e9, volume: 32e6,  relVolume: 0.9, pe: 42.1,  eps: 5.19, divYield: 0,    beta: 1.14, rsi: 47, perfWeek: -1.4, perfMonth: 2.1,  perfYTD: 8.9,   from52High: -7.8,  rating: "Strong Buy"),
    ScreenerStock(ticker: "GME",  name: "GameStop",      sector: "Consumer",   price: 28.90,  changePct: 8.1,  mktCap: 12e9,    volume: 42e6,  relVolume: 6.2, pe: 0,     eps: 0.08, divYield: 0,    beta: 2.84, rsi: 78, perfWeek: 14.2, perfMonth: 22.6, perfYTD: 31.2,  from52High: -22.4, rating: "Sell"),
    ScreenerStock(ticker: "HD",   name: "Home Depot",    sector: "Consumer",   price: 386.20, changePct: 0.6,  mktCap: 380e9,   volume: 3e6,   relVolume: 0.8, pe: 24.6,  eps: 15.70, divYield: 2.4, beta: 0.96, rsi: 52, perfWeek: 1.1,  perfMonth: 3.4,  perfYTD: 6.8,   from52High: -5.2,  rating: "Buy"),
    ScreenerStock(ticker: "KO",   name: "Coca-Cola",     sector: "Consumer",   price: 68.40,  changePct: 0.3,  mktCap: 295e9,   volume: 12e6,  relVolume: 0.7, pe: 26.2,  eps: 2.61, divYield: 2.9,  beta: 0.58, rsi: 55, perfWeek: 0.6,  perfMonth: 2.2,  perfYTD: 9.2,   from52High: -1.4,  rating: "Buy"),
    ScreenerStock(ticker: "BA",   name: "Boeing",        sector: "Industrial", price: 186.40, changePct: 1.4,  mktCap: 115e9,   volume: 8e6,   relVolume: 1.1, pe: 0,     eps: -4.22, divYield: 0,   beta: 1.52, rsi: 57, perfWeek: 2.4,  perfMonth: 6.2,  perfYTD: 4.8,   from52High: -16.8, rating: "Neutral"),
    ScreenerStock(ticker: "CAT",  name: "Caterpillar",   sector: "Industrial", price: 384.60, changePct: 0.8,  mktCap: 185e9,   volume: 2e6,   relVolume: 0.9, pe: 17.8,  eps: 21.61, divYield: 1.5, beta: 1.08, rsi: 60, perfWeek: 1.6,  perfMonth: 4.4,  perfYTD: 12.1,  from52High: -3.2,  rating: "Buy"),
    ScreenerStock(ticker: "RKLB", name: "Rocket Lab",    sector: "Industrial", price: 28.20,  changePct: 5.9,  mktCap: 14e9,    volume: 24e6,  relVolume: 3.2, pe: 0,     eps: -0.38, divYield: 0,   beta: 2.18, rsi: 74, perfWeek: 11.2, perfMonth: 19.8, perfYTD: 52.4,  from52High: -4.2,  rating: "Buy"),
]

// MARK: Screener columns (customizable, TradingView-style)

enum ScreenerColumn: String, CaseIterable, Identifiable {
    case price, change, mktCap, volume, relVol, pe, eps, divYield, beta, rsi, perfW, perfM, perfYTD, high52, rating
    var id: String { rawValue }

    var label: String {
        switch self {
        case .price: return "PRICE";     case .change: return "CHG %";   case .mktCap: return "MKT CAP"
        case .volume: return "VOL";      case .relVol: return "REL VOL"; case .pe: return "P/E"
        case .eps: return "EPS";         case .divYield: return "DIV %"; case .beta: return "BETA"
        case .rsi: return "RSI";         case .perfW: return "PERF W";   case .perfM: return "PERF 1M"
        case .perfYTD: return "PERF YTD"; case .high52: return "52W HI";  case .rating: return "RATING"
        }
    }

    var width: CGFloat {
        switch self {
        case .mktCap, .volume, .perfYTD: return 82
        case .rating: return 96
        default: return 72
        }
    }

    func sortValue(_ s: ScreenerStock) -> Double {
        switch self {
        case .price: return s.price;       case .change: return s.changePct; case .mktCap: return s.mktCap
        case .volume: return s.volume;     case .relVol: return s.relVolume; case .pe: return s.pe
        case .eps: return s.eps;           case .divYield: return s.divYield; case .beta: return s.beta
        case .rsi: return s.rsi;           case .perfW: return s.perfWeek;   case .perfM: return s.perfMonth
        case .perfYTD: return s.perfYTD;   case .high52: return s.from52High
        case .rating: return ["Strong Buy": 4.0, "Buy": 3.0, "Neutral": 2.0, "Sell": 1.0][s.rating] ?? 0
        }
    }

    func text(_ s: ScreenerStock) -> String {
        switch self {
        case .price:    return s.price.fmtPrice()
        case .change:   return s.changePct.fmtPct()
        case .mktCap:   return s.mktCap.fmtCompact()
        case .volume:   return s.volume >= 1e6 ? String(format: "%.0fM", s.volume / 1e6) : String(format: "%.0fK", s.volume / 1e3)
        case .relVol:   return String(format: "%.1f×", s.relVolume)
        case .pe:       return s.pe > 0 ? String(format: "%.1f", s.pe) : "—"
        case .eps:      return String(format: "%.2f", s.eps)
        case .divYield: return s.divYield > 0 ? String(format: "%.1f%%", s.divYield) : "—"
        case .beta:     return String(format: "%.2f", s.beta)
        case .rsi:      return String(format: "%.0f", s.rsi)
        case .perfW:    return s.perfWeek.fmtPct()
        case .perfM:    return s.perfMonth.fmtPct()
        case .perfYTD:  return s.perfYTD.fmtPct()
        case .high52:   return String(format: "%.1f%%", s.from52High)
        case .rating:   return s.rating
        }
    }

    func color(_ s: ScreenerStock) -> Color {
        switch self {
        case .change:  return s.changePct >= 0 ? Theme.gain : Theme.loss
        case .relVol:  return s.relVolume >= 2 ? Theme.gold : Theme.text
        case .rsi:     return s.rsi >= 70 ? Theme.loss : s.rsi <= 30 ? Theme.gain : Theme.text
        case .perfW:   return s.perfWeek >= 0 ? Theme.gain : Theme.loss
        case .perfM:   return s.perfMonth >= 0 ? Theme.gain : Theme.loss
        case .perfYTD: return s.perfYTD >= 0 ? Theme.gain : Theme.loss
        case .high52:  return s.from52High > -5 ? Theme.gain : Theme.text
        case .rating:
            switch s.rating {
            case "Strong Buy": return Theme.gain
            case "Buy":        return Theme.gain.opacity(0.75)
            case "Sell":       return Theme.loss
            default:           return Theme.text3
            }
        default: return Theme.text
        }
    }
}

// MARK: Screener filters (dropdown menus, TradingView-style)

struct ScreenerFilterDef {
    let name: String
    let options: [String]
    let test: (ScreenerStock, String) -> Bool
}

private let SCREENER_FILTERS: [ScreenerFilterDef] = [
    ScreenerFilterDef(name: "Market Cap", options: ["Any", "Mega > $200B", "Large $10–200B", "Mid $2–10B", "Small < $2B"]) { s, o in
        switch o {
        case "Mega > $200B":   return s.mktCap > 200e9
        case "Large $10–200B": return s.mktCap >= 10e9 && s.mktCap <= 200e9
        case "Mid $2–10B":     return s.mktCap >= 2e9 && s.mktCap < 10e9
        case "Small < $2B":    return s.mktCap < 2e9
        default: return true
        }
    },
    ScreenerFilterDef(name: "Price", options: ["Any", "Under $20", "$20–100", "$100–300", "Over $300"]) { s, o in
        switch o {
        case "Under $20":  return s.price < 20
        case "$20–100":    return s.price >= 20 && s.price <= 100
        case "$100–300":   return s.price > 100 && s.price <= 300
        case "Over $300":  return s.price > 300
        default: return true
        }
    },
    ScreenerFilterDef(name: "Change %", options: ["Any", "Up > 3%", "Up", "Down", "Down > 3%"]) { s, o in
        switch o {
        case "Up > 3%":   return s.changePct > 3
        case "Up":        return s.changePct > 0
        case "Down":      return s.changePct < 0
        case "Down > 3%": return s.changePct < -3
        default: return true
        }
    },
    ScreenerFilterDef(name: "Volume", options: ["Any", "Over 50M", "Over 20M", "Over 5M"]) { s, o in
        switch o {
        case "Over 50M": return s.volume > 50e6
        case "Over 20M": return s.volume > 20e6
        case "Over 5M":  return s.volume > 5e6
        default: return true
        }
    },
    ScreenerFilterDef(name: "Rel Volume", options: ["Any", "Over 3×", "Over 1.5×", "Below 1×"]) { s, o in
        switch o {
        case "Over 3×":   return s.relVolume > 3
        case "Over 1.5×": return s.relVolume > 1.5
        case "Below 1×":  return s.relVolume < 1
        default: return true
        }
    },
    ScreenerFilterDef(name: "P/E", options: ["Any", "Under 15", "15–30", "Over 30", "Profitable", "Unprofitable"]) { s, o in
        switch o {
        case "Under 15":     return s.pe > 0 && s.pe < 15
        case "15–30":        return s.pe >= 15 && s.pe <= 30
        case "Over 30":      return s.pe > 30
        case "Profitable":   return s.eps > 0
        case "Unprofitable": return s.eps <= 0
        default: return true
        }
    },
    ScreenerFilterDef(name: "Div Yield", options: ["Any", "Over 4%", "Over 2%", "Pays Dividend", "None"]) { s, o in
        switch o {
        case "Over 4%":       return s.divYield > 4
        case "Over 2%":       return s.divYield > 2
        case "Pays Dividend": return s.divYield > 0
        case "None":          return s.divYield == 0
        default: return true
        }
    },
    ScreenerFilterDef(name: "RSI", options: ["Any", "Oversold < 30", "30–70", "Overbought > 70"]) { s, o in
        switch o {
        case "Oversold < 30":    return s.rsi < 30
        case "30–70":            return s.rsi >= 30 && s.rsi <= 70
        case "Overbought > 70":  return s.rsi > 70
        default: return true
        }
    },
    ScreenerFilterDef(name: "Beta", options: ["Any", "Low < 1", "1–1.5", "High > 1.5"]) { s, o in
        switch o {
        case "Low < 1":    return s.beta < 1
        case "1–1.5":      return s.beta >= 1 && s.beta <= 1.5
        case "High > 1.5": return s.beta > 1.5
        default: return true
        }
    },
    ScreenerFilterDef(name: "Rating", options: ["Any", "Strong Buy", "Buy or better", "Neutral", "Sell"]) { s, o in
        switch o {
        case "Strong Buy":    return s.rating == "Strong Buy"
        case "Buy or better": return s.rating == "Strong Buy" || s.rating == "Buy"
        case "Neutral":       return s.rating == "Neutral"
        case "Sell":          return s.rating == "Sell"
        default: return true
        }
    },
    ScreenerFilterDef(name: "52W High", options: ["Any", "Near high (< 5%)", "Down 5–20%", "Down > 20%"]) { s, o in
        switch o {
        case "Near high (< 5%)": return s.from52High > -5
        case "Down 5–20%":       return s.from52High <= -5 && s.from52High >= -20
        case "Down > 20%":       return s.from52High < -20
        default: return true
        }
    },
]

// MARK: Screener presets

private let SCREENER_PRESETS: [(name: String, icon: String, filters: [String: String], sort: ScreenerColumn, asc: Bool)] = [
    ("Top Gainers",   "flame.fill",                ["Change %": "Up > 3%"],            .change,  false),
    ("Top Losers",    "arrow.down.right",          ["Change %": "Down > 3%"],          .change,  true),
    ("Most Active",   "waveform",                  ["Volume": "Over 20M"],             .volume,  false),
    ("Vol Spikes",    "bolt.fill",                 ["Rel Volume": "Over 1.5×"],        .relVol,  false),
    ("52W Highs",     "arrow.up.to.line",          ["52W High": "Near high (< 5%)"],   .high52,  false),
    ("Oversold",      "arrow.down.heart",          ["RSI": "Oversold < 30"],           .rsi,     true),
    ("Overbought",    "thermometer.high",          ["RSI": "Overbought > 70"],         .rsi,     false),
    ("Dividend",      "banknote",                  ["Div Yield": "Over 2%"],           .divYield, false),
    ("Value",         "tag",                       ["P/E": "Under 15"],                .pe,      true),
    ("Mega Caps",     "building.2",                ["Market Cap": "Mega > $200B"],     .mktCap,  false),
]

// MARK: Screener sheet

struct ScreenerSheet: View {
    @Environment(\.dismiss) var dismiss
    let onTicker: (String) -> Void

    @State private var sector = "All"
    @State private var filterSelections: [String: String] = [:]
    @State private var visibleColumns: [ScreenerColumn] = [.price, .change, .mktCap, .volume, .pe, .rsi, .rating]
    @State private var sortColumn: ScreenerColumn = .change
    @State private var sortAscending = false
    @State private var showColumnPicker = false
    @State private var activePreset: String? = nil

    let sectors = ["All", "Tech", "Energy", "Finance", "Healthcare", "Consumer", "Industrial"]

    var results: [ScreenerStock] {
        SCREENER_UNIVERSE
            .filter { s in
                guard sector == "All" || s.sector == sector else { return false }
                for f in SCREENER_FILTERS {
                    let sel = filterSelections[f.name] ?? "Any"
                    if sel != "Any" && !f.test(s, sel) { return false }
                }
                return true
            }
            .sorted {
                sortAscending
                    ? sortColumn.sortValue($0) < sortColumn.sortValue($1)
                    : sortColumn.sortValue($0) > sortColumn.sortValue($1)
            }
    }

    var activeFilterCount: Int {
        filterSelections.values.filter { $0 != "Any" }.count + (sector == "All" ? 0 : 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            presetsRow
            filterMenusRow
            sectorRow
            columnControlRow
            if showColumnPicker { columnPicker }
            Rectangle().fill(Theme.border).frame(height: 1)
            table
        }
        .background(Theme.bg)
        .presentationDetents([.large])
    }

    // MARK: header

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Stock Screener")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Theme.text)
                Text("\(results.count) matches · \(activeFilterCount) filters active")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
            }
            Spacer()
            if activeFilterCount > 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        filterSelections = [:]; sector = "All"; activePreset = nil
                    }
                } label: {
                    Text("Reset")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.loss)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Theme.lossBg)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.text2)
                    .frame(width: 32, height: 32)
                    .background(Theme.bg2)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 22)
        .padding(.bottom, 12)
    }

    // MARK: presets

    var presetsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SCREENER_PRESETS, id: \.name) { preset in
                    let isActive = activePreset == preset.name
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            if isActive {
                                activePreset = nil
                                filterSelections = [:]
                            } else {
                                activePreset = preset.name
                                filterSelections = preset.filters
                                sortColumn = preset.sort
                                sortAscending = preset.asc
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: preset.icon)
                                .font(.system(size: 10, weight: .semibold))
                            Text(preset.name)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(isActive ? .white : Theme.text2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isActive ? Theme.accent : Theme.card)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(isActive ? Color.clear : Theme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.bottom, 10)
    }

    // MARK: filter dropdowns

    var filterMenusRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SCREENER_FILTERS, id: \.name) { f in
                    let sel = filterSelections[f.name] ?? "Any"
                    let isSet = sel != "Any"
                    Menu {
                        ForEach(f.options, id: \.self) { opt in
                            Button {
                                filterSelections[f.name] = opt
                                activePreset = nil
                            } label: {
                                if opt == sel { Label(opt, systemImage: "checkmark") }
                                else { Text(opt) }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(isSet ? "\(f.name): \(sel)" : f.name)
                                .font(.system(size: 11, weight: .bold))
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 8, weight: .bold))
                        }
                        .foregroundStyle(isSet ? Theme.accent : Theme.text3)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(isSet ? Theme.accentBg : Theme.bg2)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(isSet ? Theme.accent.opacity(0.4) : Theme.border, lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.bottom, 8)
    }

    // MARK: sector chips

    var sectorRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(sectors, id: \.self) { s in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { sector = s }
                    } label: {
                        Text(s)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(sector == s ? .white : Theme.text3)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(sector == s ? Theme.accent : Theme.card)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(sector == s ? Color.clear : Theme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.bottom, 8)
    }

    // MARK: column customizer

    var columnControlRow: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showColumnPicker.toggle() }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "rectangle.split.3x1")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Columns · \(visibleColumns.count)")
                        .font(.system(size: 11, weight: .bold))
                    Image(systemName: showColumnPicker ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundStyle(Theme.accent)
            }
            .buttonStyle(.plain)
            Spacer()
            HStack(spacing: 4) {
                Text("Sort:")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.text4)
                Text("\(sortColumn.label) \(sortAscending ? "↑" : "↓")")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.text3)
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 8)
    }

    var columnPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(ScreenerColumn.allCases) { col in
                    let isOn = visibleColumns.contains(col)
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if isOn { visibleColumns.removeAll { $0 == col } }
                            else { visibleColumns.append(col) }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isOn ? "checkmark" : "plus")
                                .font(.system(size: 8, weight: .black))
                            Text(col.label)
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(isOn ? Theme.accent : Theme.text3)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isOn ? Theme.accentBg : Theme.bg2)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(isOn ? Theme.accent.opacity(0.4) : Theme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.bottom, 8)
    }

    // MARK: table — pinned symbol column + horizontally scrolling stats

    private let rowHeight: CGFloat = 52
    private let headerHeight: CGFloat = 30

    var table: some View {
        ScrollView(showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                // Pinned symbol column
                VStack(spacing: 0) {
                    Text("SYMBOL")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(0.8)
                        .frame(width: 96, height: headerHeight, alignment: .leading)
                        .padding(.leading, 16)
                        .background(Theme.bg2)
                    ForEach(results) { s in
                        Button {
                            dismiss()
                            onTicker(s.ticker)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(s.ticker)
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundStyle(Theme.text)
                                Text(s.name)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.text3)
                                    .lineLimit(1)
                            }
                            .frame(width: 96, height: rowHeight, alignment: .leading)
                            .padding(.leading, 16)
                        }
                        .buttonStyle(.plain)
                        .overlay(Rectangle().fill(Theme.border).frame(height: 0.5), alignment: .bottom)
                    }
                }
                .background(Theme.bg)
                .overlay(Rectangle().fill(Theme.border).frame(width: 1), alignment: .trailing)

                // Scrollable stat columns
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Sortable header
                        HStack(spacing: 0) {
                            ForEach(visibleColumns) { col in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        if sortColumn == col { sortAscending.toggle() }
                                        else { sortColumn = col; sortAscending = false }
                                    }
                                } label: {
                                    HStack(spacing: 2) {
                                        Text(col.label)
                                            .font(.system(size: 9, weight: .black))
                                            .kerning(0.5)
                                        if sortColumn == col {
                                            Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                                                .font(.system(size: 7, weight: .black))
                                        }
                                    }
                                    .foregroundStyle(sortColumn == col ? Theme.accent : Theme.text3)
                                    .frame(width: col.width, height: headerHeight, alignment: .trailing)
                                    .padding(.trailing, 8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .background(Theme.bg2)

                        // Data rows
                        ForEach(results) { s in
                            HStack(spacing: 0) {
                                ForEach(visibleColumns) { col in
                                    Text(col.text(s))
                                        .font(.system(size: 12, weight: col == .rating ? .bold : .semibold))
                                        .foregroundStyle(col.color(s))
                                        .monospacedDigit()
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .frame(width: col.width, height: rowHeight, alignment: .trailing)
                                        .padding(.trailing, 8)
                                }
                            }
                            .overlay(Rectangle().fill(Theme.border).frame(height: 0.5), alignment: .bottom)
                        }
                    }
                }
            }
            Color.clear.frame(height: 30)
        }
    }
}
