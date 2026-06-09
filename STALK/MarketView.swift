import SwiftUI
import Combine

struct MarketView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Market")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Theme.text)
                    .padding(.horizontal, 16)
                    .padding(.top, 52)
                    .padding(.bottom, 14)

                // Sectors
                Text("Sectors")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.text3)
                    .textCase(.uppercase)
                    .kerning(1.3)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 9)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(SECTORS, id: \.etf) { sector in
                            SectorChip(sector: sector, quote: appState.marketQuotes[sector.etf], onTap: { onTicker(sector.etf) })
                        }
                    }
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 14)

                // Sector Heat Map
                marketSectionLabel("🌡️ Sector Heat Map")
                SectorHeatMapView()
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)

                // Indices
                marketSectionLabel("Indices")

                VStack(spacing: 8) {
                    ForEach(INDEX_TICKERS, id: \.self) { ticker in
                        if let q = appState.marketQuotes[ticker] {
                            MarketRow(name: INDEX_NAMES[ticker] ?? ticker, subtitle: ticker, quote: q, onTap: { onTicker(ticker) })
                        } else {
                            MarketRowSkeleton()
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)

                // Trending Tickers Feed
                marketSectionLabel("🔥 Trending · Social Buzz")
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
    }

    func marketSectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Theme.text3)
            .textCase(.uppercase)
            .kerning(1.3)
            .padding(.horizontal, 14)
            .padding(.bottom, 9)
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
        let flat = Color(hex: "#141420")
        if change > 2.0      { return gain }
        if change >= 0.5     { return gain.opacity(0.40) }
        if change > -0.5     { return flat }
        if change >= -2.0    { return loss.opacity(0.40) }
        return loss
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(heatMapSectors) { tile in
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tileColor(tile.change))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )

                    VStack(spacing: 5) {
                        Image(systemName: tile.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))

                        Text(tile.name)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)

                        Text(tile.change.fmtPct())
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 12)
                }
                .frame(height: 90)
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
                        // Rank badge
                        Text("#\(i + 1)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(Theme.text3)
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
