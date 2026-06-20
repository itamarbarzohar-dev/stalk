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

                // Indices — compact Bloomberg rows
                marketSectionLabel("Indices")
                IndexCompactList(appState: appState, onTicker: onTicker)
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
                SectorHeatMapView()
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
                .accessibilityLabel("\(tile.name), \(tile.change.fmtPct()) today")
            }
        }
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
