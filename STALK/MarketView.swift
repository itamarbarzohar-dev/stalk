import SwiftUI

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

                // Indices
                Text("Indices")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.text3)
                    .textCase(.uppercase)
                    .kerning(1.3)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 9)

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

                // Trending
                Text("Trending")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.text3)
                    .textCase(.uppercase)
                    .kerning(1.3)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 9)

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
