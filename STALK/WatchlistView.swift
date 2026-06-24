import SwiftUI

let ADD_WATCHLIST_TICKERS: [(ticker: String, name: String)] = [
    ("NVDA", "NVIDIA Corporation"),
    ("AAPL", "Apple Inc."),
    ("TSLA", "Tesla Inc."),
    ("META", "Meta Platforms"),
    ("MSFT", "Microsoft Corporation"),
    ("AMZN", "Amazon.com Inc."),
    ("GOOGL", "Alphabet Inc."),
    ("AMD", "Advanced Micro Devices"),
    ("AVGO", "Broadcom Inc."),
    ("TSM", "Taiwan Semiconductor"),
    ("SMCI", "Super Micro Computer"),
    ("COIN", "Coinbase Global"),
    ("PLTR", "Palantir Technologies"),
    ("MSTR", "MicroStrategy Inc."),
    ("ARM", "ARM Holdings"),
    ("INTC", "Intel Corporation"),
    ("QCOM", "QUALCOMM Inc."),
    ("MU", "Micron Technology"),
    ("NFLX", "Netflix Inc."),
    ("RIVN", "Rivian Automotive"),
    ("SOFI", "SoFi Technologies"),
    ("HOOD", "Robinhood Markets"),
    ("IONQ", "IonQ Inc."),
    ("RKLB", "Rocket Lab USA"),
    ("GME", "GameStop Corp."),
    ("SPY", "SPDR S&P 500 ETF"),
    ("QQQ", "Invesco QQQ Trust"),
    ("GLD", "SPDR Gold Shares"),
    ("JPM", "JPMorgan Chase"),
    ("V", "Visa Inc."),
    ("BRK-B", "Berkshire Hathaway"),
    ("KO", "The Coca-Cola Company"),
    ("LLY", "Eli Lilly and Company"),
    ("MRNA", "Moderna Inc."),
]

struct WatchlistView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var filterText = ""
    @State private var showAddSheet = false
    @State private var expandedID: UUID? = nil

    var filtered: [WatchlistItem] {
        guard !filterText.isEmpty else { return appState.watchlist }
        return appState.watchlist.filter {
            $0.ticker.localizedCaseInsensitiveContains(filterText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                if appState.watchlist.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(filtered) { item in
                                WatchlistItemRow(
                                    item: item,
                                    isExpanded: expandedID == item.id,
                                    onTap: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                                            expandedID = expandedID == item.id ? nil : item.id
                                        }
                                    },
                                    onUpdate: { appState.updateWatchlistItem($0) },
                                    onDelete: { appState.removeFromWatchlist(item.ticker) }
                                )

                                if item.id != filtered.last?.id {
                                    Rectangle()
                                        .fill(Theme.border)
                                        .frame(height: 1)
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
                        .padding(.horizontal, 14)
                        .padding(.top, 8)

                        Color.clear.frame(height: 100)
                    }
                }
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $filterText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search tickers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                            Text("Add")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddToWatchlistSheet()
                    .environment(appState)
            }
        }
    }

    var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.10))
                    .frame(width: 80, height: 80)
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Theme.accent)
            }
            VStack(spacing: 8) {
                Text("Your watchlist is empty")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Theme.text)
                Text("Add stocks you're watching\nto track them here.")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.text3)
                    .multilineTextAlignment(.center)
            }
            Button {
                showAddSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("Add stocks")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 13)
                .background(Theme.accent)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

struct WatchlistItemRow: View {
    let item: WatchlistItem
    let isExpanded: Bool
    let onTap: () -> Void
    let onUpdate: (WatchlistItem) -> Void
    let onDelete: () -> Void

    @State private var editedNote: String = ""
    @State private var editedTags: Set<WatchlistTag> = []

    private let mockPrice: Double = Double.random(in: 50...450)
    private let mockChange: Double = Double.random(in: -5...7)

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.ticker)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Theme.text)
                        Text(companyName(item.ticker))
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.text3)
                            .lineLimit(1)
                    }

                    if !item.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                ForEach(Array(item.tags.prefix(3)), id: \.self) { tag in
                                    HStack(spacing: 3) {
                                        Circle()
                                            .fill(tag.color)
                                            .frame(width: 5, height: 5)
                                        Text(tag.rawValue)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(tag.color)
                                    }
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(tag.color.opacity(0.12))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .frame(maxWidth: 160)
                    } else {
                        Spacer()
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text(mockPrice.fmtPrice())
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Theme.text)
                            .monospacedDigit()
                        HStack(spacing: 3) {
                            Image(systemName: mockChange >= 0 ? "arrow.up" : "arrow.down")
                                .font(.system(size: 9, weight: .black))
                            Text(mockChange.fmtPct())
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(mockChange >= 0 ? Theme.gain : Theme.loss)
                        .monospacedDigit()
                    }
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 72)
            }
            .buttonStyle(.plain)

            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear {
            editedNote = item.note
            editedTags = Set(item.tags)
        }
        .onChange(of: isExpanded) { _, expanded in
            if expanded {
                editedNote = item.note
                editedTags = Set(item.tags)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }

    var expandedContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 8) {
                Text("Why interesting?")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.text3)
                    .textCase(.uppercase)
                    .kerning(1.2)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach([WatchlistTag.earnings, .insider, .revenue], id: \.self) { tag in
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    if editedTags.contains(tag) {
                                        editedTags.remove(tag)
                                    } else {
                                        editedTags.insert(tag)
                                    }
                                }
                                saveEdits()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: tag.icon)
                                        .font(.system(size: 10, weight: .semibold))
                                    Text(tag.rawValue)
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundStyle(editedTags.contains(tag) ? tag.color : Theme.text3)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(editedTags.contains(tag) ? tag.color.opacity(0.18) : Theme.card)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(editedTags.contains(tag) ? tag.color.opacity(0.4) : Theme.border, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Tags")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.text3)
                    .textCase(.uppercase)
                    .kerning(1.2)

                let columns = [GridItem(.adaptive(minimum: 100), spacing: 6)]
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(WatchlistTag.allCases, id: \.self) { tag in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                if editedTags.contains(tag) {
                                    editedTags.remove(tag)
                                } else {
                                    editedTags.insert(tag)
                                }
                            }
                            saveEdits()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: tag.icon)
                                    .font(.system(size: 11, weight: .semibold))
                                Text(tag.rawValue)
                                    .font(.system(size: 12, weight: .semibold))
                                    .lineLimit(1)
                            }
                            .foregroundStyle(editedTags.contains(tag) ? tag.color : Theme.text3)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(editedTags.contains(tag) ? tag.color.opacity(0.18) : Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(editedTags.contains(tag) ? tag.color.opacity(0.4) : Theme.border, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Note")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.text3)
                        .textCase(.uppercase)
                        .kerning(1.2)
                    Spacer()
                    Text("\(editedNote.count)/200")
                        .font(.system(size: 11))
                        .foregroundStyle(editedNote.count > 180 ? Theme.loss : Theme.text4)
                }

                ZStack(alignment: .topLeading) {
                    if editedNote.isEmpty {
                        Text("Note to self...")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.text4)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                    TextEditor(text: $editedNote)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.text)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 64)
                        .onChange(of: editedNote) { _, newVal in
                            if newVal.count > 200 {
                                editedNote = String(newVal.prefix(200))
                            }
                            saveEdits()
                        }
                }
                .padding(10)
                .background(Theme.bg)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Remove from Watchlist")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Theme.loss)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Theme.loss.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.loss.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func saveEdits() {
        var updated = item
        updated.tags = Array(editedTags)
        updated.note = editedNote
        onUpdate(updated)
    }

    private func companyName(_ ticker: String) -> String {
        ADD_WATCHLIST_TICKERS.first(where: { $0.ticker == ticker })?.name ?? ticker
    }
}

struct AddToWatchlistSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var results: [(ticker: String, name: String)] {
        if searchText.isEmpty { return ADD_WATCHLIST_TICKERS }
        return ADD_WATCHLIST_TICKERS.filter {
            $0.ticker.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(results, id: \.ticker) { item in
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Theme.accent.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    Text(String(item.ticker.prefix(2)))
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(Theme.accent)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.ticker)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(Theme.text)
                                    Text(item.name)
                                        .font(.system(size: 12))
                                        .foregroundStyle(Theme.text3)
                                }

                                Spacer()

                                Button {
                                    if appState.isWatched(item.ticker) {
                                        appState.removeFromWatchlist(item.ticker)
                                    } else {
                                        appState.addToWatchlist(item.ticker)
                                    }
                                } label: {
                                    if appState.isWatched(item.ticker) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundStyle(Theme.gain)
                                    } else {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundStyle(Theme.accent)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)

                            if item.ticker != results.last?.ticker {
                                Rectangle()
                                    .fill(Theme.border)
                                    .frame(height: 1)
                                    .padding(.leading, 64)
                            }
                        }
                    }
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
                    .padding(.horizontal, 14)
                    .padding(.top, 8)

                    Color.clear.frame(height: 40)
                }
            }
            .navigationTitle("Add to Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search ticker or company")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                }
            }
        }
    }
}

struct WatchlistCompactRow: View {
    let item: WatchlistItem
    let onTap: () -> Void

    private let mockPrice: Double = Double.random(in: 50...450)
    private let mockChange: Double = Double.random(in: -5...7)

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Text(item.ticker)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.text)

                        if !item.tags.isEmpty {
                            HStack(spacing: 3) {
                                ForEach(Array(item.tags.prefix(3)), id: \.self) { tag in
                                    Circle()
                                        .fill(tag.color)
                                        .frame(width: 6, height: 6)
                                }
                            }
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(mockPrice.fmtPrice())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.text)
                        .monospacedDigit()
                    Text(mockChange.fmtPct())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(mockChange >= 0 ? Theme.gain : Theme.loss)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 56)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
