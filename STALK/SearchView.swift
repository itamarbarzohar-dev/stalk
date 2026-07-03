import SwiftUI

struct SearchView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void

    @State private var query = ""
    @State private var searchResult: Quote? = nil
    @State private var notFound = false
    @State private var isSearching = false
    @State private var selectedWatchlist: WatchlistGroup? = nil
    @State private var watchlistQuotes: [String: Quote] = [:]
    @State private var isLoadingWatchlist = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.text3)
                    TextField("Search any ticker...", text: $query)
                        #if os(iOS)
                        .textInputAutocapitalization(.characters)
                        #endif
                        .autocorrectionDisabled()
                        .font(.system(size: 16))
                        .onChange(of: query) { _, v in
                            query = v.uppercased()
                            searchResult = nil
                            notFound = false
                        }
                        .onSubmit { Task { await doSearch() } }
                    if !query.isEmpty {
                        Button { query = ""; searchResult = nil; notFound = false } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Theme.text3)
                        }
                    }
                }
                .padding(14)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1.5))
                .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                .padding(.horizontal, 14)
                .padding(.top, 52)
                .padding(.bottom, 8)

                // Search Results
                if isSearching {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.vertical, 20)
                } else if let q = searchResult {
                    SearchResultCard(quote: q, onChart: { onTicker(q.ticker) }, onAdd: {
                        appState.selectedTab = .portfolio
                    })
                    .padding(.horizontal, 14)
                    .padding(.bottom, 8)
                } else if notFound {
                    Text("\"\(query)\" not found. Check the ticker symbol.")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.text3)
                        .multilineTextAlignment(.center)
                        .padding(40)
                        .frame(maxWidth: .infinity)
                } else if query.isEmpty {
                    // Watchlists
                    if let wl = selectedWatchlist {
                        watchlistDetail(wl)
                    } else {
                        watchlistBrowse()
                    }
                }

                Color.clear.frame(height: 100)
            }
        }
        .background(Theme.bg)
    }

    // MARK: - Watchlist Browse

    func watchlistBrowse() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Browse by Sector")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(1.3)
                .padding(.horizontal, 14)
                .padding(.top, 8)

            ForEach(WATCHLISTS) { wl in
                Button {
                    selectedWatchlist = wl
                    Task { await loadWatchlist(wl) }
                } label: {
                    HStack(spacing: 12) {
                        Text(wl.icon)
                            .font(.system(size: 20))
                            .frame(width: 40, height: 40)
                            .background(wl.color.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(wl.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text(wl.tickers.prefix(5).joined(separator: " · ") + (wl.tickers.count > 5 ? " +more" : ""))
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.text3)
                        }

                        Spacer()

                        if !wl.etf.isEmpty {
                            Button { onTicker(wl.etf) } label: {
                                HStack(spacing: 3) {
                                    Text(wl.etf)
                                        .font(.system(size: 10, weight: .black).monospaced())
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 8, weight: .bold))
                                }
                                .foregroundStyle(wl.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(wl.color.opacity(0.10))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(wl.color.opacity(0.30), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.text3)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 14)
            }
        }
    }

    // MARK: - Watchlist Detail

    func watchlistDetail(_ wl: WatchlistGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button {
                    selectedWatchlist = nil
                    watchlistQuotes = [:]
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.text3)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Theme.bg2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Text(wl.label)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Theme.text)
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)

            if isLoadingWatchlist {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .padding(20)
            } else {
                ForEach(wl.tickers, id: \.self) { ticker in
                    let q = watchlistQuotes[ticker]
                    Button { if let q { onTicker(q.ticker) } } label: {
                        HStack {
                            Circle()
                                .fill(q?.isUp ?? true ? Theme.gain : Theme.loss)
                                .frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(ticker)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                if let q {
                                    Text(q.name)
                                        .font(.system(size: 11))
                                        .foregroundStyle(Theme.text3)
                                }
                            }
                            Spacer()
                            if let q {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(q.price.fmtPrice())
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(Theme.text)
                                    Text(q.changePercent.fmtPct())
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(q.isUp ? Theme.gain : Theme.loss)
                                }
                            } else {
                                ProgressView().scaleEffect(0.7)
                            }

                            Button {
                                appState.selectedTab = .portfolio
                            } label: {
                                Text("+")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Theme.accent)
                                    .frame(width: 32, height: 32)
                                    .background(Theme.bg2)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 14)
                }
            }
        }
    }

    // MARK: - Actions

    func doSearch() async {
        let t = query.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        isSearching = true
        do {
            let q = try await QuoteService.fetchQuote(t)
            appState.quotes[t] = q
            searchResult = q
        } catch {
            notFound = true
        }
        isSearching = false
    }

    func loadWatchlist(_ wl: WatchlistGroup) async {
        isLoadingWatchlist = true
        watchlistQuotes = [:]
        let fetched = await QuoteService.fetchManyQuotes(wl.tickers)
        watchlistQuotes = fetched
        isLoadingWatchlist = false
    }
}

// MARK: - Search Result Card

struct SearchResultCard: View {
    let quote: Quote
    let onChart: () -> Void
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onChart) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(quote.ticker)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.text)
                        Text(quote.name)
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
            }
            .buttonStyle(.plain)

            Divider().padding(.horizontal, 16)

            Button {
                onAdd()
            } label: {
                Text("+ Add to Portfolio")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.accentGradient)
            }
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }
}
