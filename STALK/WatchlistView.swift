import SwiftUI

private struct WatchlistTagChip: View {
    let tag: WatchlistTag
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: tag.icon)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isSelected ? tag.color : Theme.text4)
                Text(tag.rawValue.capitalized)
                    .font(.system(size: 9))
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? tag.color : Theme.text3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity)
            .background(isSelected ? tag.color.opacity(0.15) : Theme.bg3)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? tag.color.opacity(0.5) : Color.clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - WatchlistView

enum WatchlistSortField: String, CaseIterable {
    case symbol = "SYMBOL"
    case last   = "LAST"
    case change = "CHG%"
}

enum WatchlistSortOrder { case asc, desc }

// MARK: - Column Picker Sheet

struct WatchlistColumnPickerSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    private let maxColumns = 10

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Pick up to \(maxColumns) columns to show in each row. Long-press to reorder.")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.text3)
                        Spacer()
                        Text("\(appState.watchlistColumns.count)/\(maxColumns)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(appState.watchlistColumns.count == maxColumns ? Theme.accent : Theme.text3)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(WatchlistStat.allCases) { stat in
                            let isOn = appState.watchlistColumns.contains(stat)
                            let canAdd = !isOn && appState.watchlistColumns.count < maxColumns
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    if isOn {
                                        appState.watchlistColumns.removeAll { $0 == stat }
                                    } else if canAdd {
                                        appState.watchlistColumns.append(stat)
                                    }
                                    appState.saveWatchlistColumns()
                                }
                            } label: {
                                VStack(spacing: 5) {
                                    if isOn {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(Theme.accent)
                                    } else {
                                        Image(systemName: "circle")
                                            .font(.system(size: 14))
                                            .foregroundStyle(canAdd ? Theme.text3 : Theme.text4)
                                    }
                                    Text(stat.rawValue)
                                        .font(.system(size: 10, weight: isOn ? .bold : .medium))
                                        .foregroundStyle(isOn ? Theme.accent : (canAdd ? Theme.text2 : Theme.text4))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isOn ? Theme.accent.opacity(0.1) : Theme.bg3)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(isOn ? Theme.accent.opacity(0.4) : Color.clear, lineWidth: 1))
                                .opacity((!isOn && !canAdd) ? 0.4 : 1)
                            }
                            .buttonStyle(.plain)
                            .disabled(!isOn && !canAdd)
                        }
                    }

                    if !appState.watchlistColumns.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("COLUMN ORDER")
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(Theme.text3)
                                .kerning(1.5)
                            ForEach(Array(appState.watchlistColumns.enumerated()), id: \.element) { i, col in
                                HStack(spacing: 12) {
                                    Text("\(i + 1)")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(Theme.text4)
                                        .frame(width: 18)
                                    Text(col.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Theme.text)
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Button {
                                            guard i > 0 else { return }
                                            withAnimation { appState.watchlistColumns.swapAt(i, i - 1) }
                                            appState.saveWatchlistColumns()
                                        } label: {
                                            Image(systemName: "chevron.up")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(i > 0 ? Theme.text2 : Theme.text4)
                                        }
                                        .disabled(i == 0)
                                        Button {
                                            guard i < appState.watchlistColumns.count - 1 else { return }
                                            withAnimation { appState.watchlistColumns.swapAt(i, i + 1) }
                                            appState.saveWatchlistColumns()
                                        } label: {
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(i < appState.watchlistColumns.count - 1 ? Theme.text2 : Theme.text4)
                                        }
                                        .disabled(i == appState.watchlistColumns.count - 1)
                                    }
                                    Button {
                                        withAnimation { appState.watchlistColumns.remove(at: i) }
                                        appState.saveWatchlistColumns()
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(Theme.text4)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 11)
                                .background(Theme.bg3)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                .padding(18)
            }
            .background(Theme.bg)
            .navigationTitle("Customize Columns")
            .navigationBarTitleDisplayMode(.inline)
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

struct WatchlistView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void

    @State private var sortField: WatchlistSortField = .symbol
    @State private var sortOrder: WatchlistSortOrder = .asc
    @State private var expandedId: UUID? = nil
    @State private var showAdd = false
    @State private var showNewListAlert = false
    @State private var newListName = ""
    @State private var renameTarget: Int? = nil
    @State private var renameText = ""
    @State private var showColumnPicker = false

    private var activeItems: [WatchlistItem] {
        appState.watchlist
    }

    private var sorted: [WatchlistItem] {
        activeItems.sorted { a, b in
            let aP = appState.price(for: a.ticker)
            let bP = appState.price(for: b.ticker)
            let aC = appState.change(for: a.ticker)
            let bC = appState.change(for: b.ticker)
            let result: Bool
            switch sortField {
            case .symbol: result = a.ticker < b.ticker
            case .last:   result = aP < bP
            case .change: result = aC < bC
            }
            return sortOrder == .asc ? result : !result
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            watchlistHeader
            watchlistTabBar
            columnHeader
            Divider().overlay(Theme.border)
            if sorted.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(sorted) { item in
                            WatchlistItemRow(
                                item: item,
                                columns: appState.watchlistColumns,
                                statValues: Dictionary(uniqueKeysWithValues: appState.watchlistColumns.map {
                                    ($0, appState.statValue(for: $0, ticker: item.ticker))
                                }),
                                changePct: appState.change(for: item.ticker),
                                isExpanded: expandedId == item.id,
                                onTap: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        expandedId = expandedId == item.id ? nil : item.id
                                    }
                                },
                                onTickerTap: { onTicker(item.ticker) },
                                onUpdate: { tags, note in
                                    appState.updateWatchlistItem(item.id, tags: tags, note: note)
                                },
                                onRemove: {
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        appState.removeFromWatchlist(item.ticker)
                                        if expandedId == item.id { expandedId = nil }
                                    }
                                }
                            )
                            Divider()
                                .frame(height: 0.5)
                                .overlay(Theme.border)
                        }
                    }
                    Color.clear.frame(height: 80)
                }
            }
        }
        .background(Theme.bg)
        .sheet(isPresented: $showAdd) {
            AddToWatchlistSheet().environment(appState)
        }
        .sheet(isPresented: $showColumnPicker) {
            WatchlistColumnPickerSheet().environment(appState)
        }
        .alert("New Watchlist", isPresented: $showNewListAlert) {
            TextField("Name", text: $newListName)
            Button("Create") {
                let name = newListName.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty { appState.createWatchlist(name: name) }
                newListName = ""
            }
            Button("Cancel", role: .cancel) { newListName = "" }
        }
        .alert("Rename", isPresented: Binding(
            get: { renameTarget != nil },
            set: { if !$0 { renameTarget = nil } }
        )) {
            TextField("Name", text: $renameText)
            Button("Save") {
                if let idx = renameTarget {
                    let name = renameText.trimmingCharacters(in: .whitespaces)
                    if !name.isEmpty { appState.renameWatchlist(at: idx, to: name) }
                }
                renameTarget = nil
            }
            Button("Cancel", role: .cancel) { renameTarget = nil }
        }
    }

    // MARK: - Header (title row)
    var watchlistHeader: some View {
        HStack(spacing: 10) {
            Text("WATCHLISTS")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Theme.text)
                .kerning(1.5)
            Spacer()
            // Column picker
            Button { showColumnPicker = true } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.text2)
                    .padding(8)
                    .background(Theme.bg3)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            // Sort menu
            Menu {
                ForEach(WatchlistSortField.allCases, id: \.self) { field in
                    Button {
                        if sortField == field { sortOrder = sortOrder == .asc ? .desc : .asc }
                        else { sortField = field; sortOrder = .asc }
                    } label: {
                        HStack {
                            Text(field.rawValue)
                            if sortField == field {
                                Image(systemName: sortOrder == .asc ? "chevron.up" : "chevron.down")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.text2)
                    .padding(8)
                    .background(Theme.bg3)
                    .clipShape(Circle())
            }
            Button { showAdd = true } label: {
                HStack(spacing: 5) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("Add")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Theme.accentGradient)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
        .padding(.bottom, 6)
    }

    // MARK: - Watchlist tab bar (horizontal pills)
    var watchlistTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(appState.userWatchlists.enumerated()), id: \.element.id) { idx, list in
                    let isActive = idx == appState.activeWatchlistIndex
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                            appState.activeWatchlistIndex = idx
                            expandedId = nil
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Text(list.name)
                                .font(.system(size: 12, weight: isActive ? .bold : .semibold))
                                .foregroundStyle(isActive ? .white : Theme.text3)
                            Text("\(list.items.count)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(isActive ? .white.opacity(0.7) : Theme.text4)
                        }
                        .padding(.horizontal, 13)
                        .padding(.vertical, 7)
                        .background(isActive ? Theme.accent : Theme.bg3)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            renameText = list.name
                            renameTarget = idx
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        if appState.userWatchlists.count > 1 {
                            Button(role: .destructive) {
                                appState.deleteWatchlist(at: idx)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }

                // "+" new watchlist
                Button {
                    showNewListAlert = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.text3)
                        .frame(width: 30, height: 30)
                        .background(Theme.bg3)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    var columnHeader: some View {
        HStack(spacing: 0) {
            sortBtn(.symbol, label: "SYMBOL").frame(maxWidth: .infinity, alignment: .leading)
            sortBtn(.last, label: "LAST").frame(width: 80, alignment: .trailing)
            sortBtn(.change, label: "CHG%").frame(width: 72, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
        .background(Theme.bg2)
    }

    @ViewBuilder
    func sortBtn(_ field: WatchlistSortField, label: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if sortField == field { sortOrder = sortOrder == .asc ? .desc : .asc }
                else { sortField = field; sortOrder = .asc }
            }
        } label: {
            HStack(spacing: 3) {
                Text(label)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(sortField == field ? Theme.accent : Theme.text3)
                    .kerning(0.7)
                Image(systemName: sortField == field ? (sortOrder == .asc ? "chevron.up" : "chevron.down") : "chevron.up.chevron.down")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(sortField == field ? Theme.accent : Theme.text4)
            }
        }
        .buttonStyle(.plain)
    }

    var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Theme.text3)
            Text("No symbols yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.text2)
            Text("Tap + Add to start tracking stocks.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.text3)
            Button { showAdd = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus").font(.system(size: 12, weight: .bold))
                    Text("Add Symbol").font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 11)
                .background(Theme.accentGradient)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 72)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Watchlist Item Row

struct WatchlistItemRow: View {
    let item: WatchlistItem
    let columns: [WatchlistStat]
    let statValues: [WatchlistStat: String]
    let changePct: Double
    let isExpanded: Bool
    let onTap: () -> Void
    let onTickerTap: () -> Void
    let onUpdate: ([WatchlistTag], String) -> Void
    let onRemove: () -> Void

    @State private var editNote: String = ""
    @State private var editTags: Set<WatchlistTag> = []

    private var isGain: Bool { changePct >= 0 }
    private let gridCols = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Top strip: ticker + right-side primary stats ──────
                    HStack(spacing: 0) {
                        // Ticker + note indicator
                        HStack(spacing: 6) {
                            Button(action: onTickerTap) {
                                Text(item.ticker)
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundStyle(Theme.text)
                            }
                            .buttonStyle(.plain)
                            if !item.note.isEmpty {
                                Image(systemName: "note.text")
                                    .font(.system(size: 9))
                                    .foregroundStyle(Theme.text4)
                            }
                        }

                        // Tag dots
                        if !item.tags.isEmpty {
                            HStack(spacing: 3) {
                                ForEach(Array(item.tags.prefix(6)), id: \.self) { tag in
                                    Circle().fill(tag.color).frame(width: 5, height: 5)
                                }
                            }
                            .padding(.leading, 8)
                        }

                        Spacer()

                        // Show first 2 selected stats inline (right side of top row)
                        HStack(spacing: 10) {
                            ForEach(Array(columns.prefix(2))) { col in
                                let val = statValues[col] ?? "—"
                                if col.isGainColored {
                                    Text(val)
                                        .font(.system(size: 11, weight: .black).monospacedDigit())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(isGain ? Theme.gain.opacity(0.9) : Theme.loss.opacity(0.9))
                                        .clipShape(Capsule())
                                } else {
                                    VStack(alignment: .trailing, spacing: 1) {
                                        Text(col.rawValue)
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(Theme.text4)
                                            .kerning(0.4)
                                        Text(val)
                                            .font(.system(size: 13, weight: .bold).monospacedDigit())
                                            .foregroundStyle(Theme.text)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, columns.count > 2 ? 8 : 12)

                    // ── Stats grid: remaining stats (3rd onward) ──────────
                    if columns.count > 2 {
                        let extraCols = Array(columns.dropFirst(2))
                        let rows = stride(from: 0, to: extraCols.count, by: 4).map {
                            Array(extraCols[$0..<min($0 + 4, extraCols.count)])
                        }
                        VStack(spacing: 0) {
                            Divider()
                                .frame(height: 0.5)
                                .overlay(Theme.border.opacity(0.6))
                                .padding(.horizontal, 16)

                            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                                HStack(spacing: 0) {
                                    ForEach(row) { col in
                                        let val = statValues[col] ?? "—"
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(col.rawValue)
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundStyle(Theme.text4)
                                                .kerning(0.5)
                                            if col.isGainColored {
                                                Text(val)
                                                    .font(.system(size: 12, weight: .black).monospacedDigit())
                                                    .foregroundStyle(isGain ? Theme.gain : Theme.loss)
                                            } else {
                                                Text(val)
                                                    .font(.system(size: 12, weight: .semibold).monospacedDigit())
                                                    .foregroundStyle(Theme.text)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    // Pad to 4 cells if last row is partial
                                    ForEach(0..<(4 - row.count), id: \.self) { _ in
                                        Color.clear.frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 7)
                                if rows.last.map({ $0 != row }) ?? false {
                                    Divider()
                                        .frame(height: 0.5)
                                        .overlay(Theme.border.opacity(0.4))
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                        .background(Theme.bg2.opacity(0.5))
                        .padding(.bottom, 0)
                    }
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                expandedPanel
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .onAppear {
            editNote = item.note
            editTags = Set(item.tags)
        }
        .onChange(of: item.note) { editNote = item.note }
        .onChange(of: item.tags) { editTags = Set(item.tags) }
    }

    @ViewBuilder
    var expandedPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.text3)
                Text("Why interesting?")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Theme.text3)
                    .kerning(0.8)
                Spacer()
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.loss.opacity(0.7))
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 8) {
                ForEach(WatchlistTag.allCases, id: \.self) { tag in
                    let isSelected = editTags.contains(tag)
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            if isSelected { editTags.remove(tag) } else { editTags.insert(tag) }
                            onUpdate(Array(editTags), editNote)
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(tag.color)
                                .frame(width: 6, height: 6)
                            Text(tag.rawValue.capitalized)
                                .font(.system(size: 10, weight: isSelected ? .bold : .regular))
                                .foregroundStyle(isSelected ? tag.color : Theme.text3)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(isSelected ? tag.color.opacity(0.15) : Theme.bg3)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? tag.color.opacity(0.5) : Color.clear, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .topLeading) {
                    if editNote.isEmpty {
                        Text("Add a note…")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.text4)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                    }
                    TextEditor(text: $editNote)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.text)
                        .frame(minHeight: 60)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .onChange(of: editNote) {
                            onUpdate(Array(editTags), editNote)
                        }
                }
                .background(Theme.bg2)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))

                HStack {
                    Spacer()
                    Text("\(editNote.count)/280")
                        .font(.system(size: 10))
                        .foregroundStyle(editNote.count > 260 ? Theme.loss : Theme.text4)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.bg2)
    }
}

// MARK: - Watchlist Compact Row

struct WatchlistCompactRow: View {
    let item: WatchlistItem
    let price: Double
    let changePct: Double
    let onTap: () -> Void
    let onTickerTap: () -> Void

    private var isGain: Bool { changePct >= 0 }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.ticker)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.text)
                    if !item.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(Array(item.tags.prefix(4)), id: \.self) { tag in
                                Circle().fill(tag.color).frame(width: 6, height: 6)
                            }
                        }
                    } else {
                        Color.clear.frame(height: 6)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(price.fmtPrice())
                    .font(.system(size: 15, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Theme.text)
                    .frame(width: 90, alignment: .trailing)

                Text(changePct.fmtPct())
                    .font(.system(size: 12, weight: .black).monospacedDigit())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(isGain ? Theme.gain.opacity(0.85) : Theme.loss.opacity(0.85))
                    .clipShape(Capsule())
                    .frame(width: 80, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add to Watchlist Sheet

struct AddToWatchlistSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    @State private var query = ""
    @State private var selectedTags: Set<WatchlistTag> = []
    @State private var note = ""
    @State private var tickers: [String] = []

    let suggestions = ["NVDA", "AAPL", "MSFT", "TSLA", "META", "AMZN", "GOOGL", "AMD", "NFLX", "PLTR", "SHOP", "SOFI", "HOOD", "COIN", "SPY", "QQQ"]

    var filtered: [String] {
        if query.isEmpty { return suggestions }
        return suggestions.filter { $0.hasPrefix(query.uppercased()) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.text3)
                        TextField("Search ticker…", text: $query)
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.text)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(Theme.bg3)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                        ForEach(filtered, id: \.self) { sym in
                            let already = appState.isWatched(sym)
                            Button {
                                if !already { query = sym }
                            } label: {
                                let fgColor: Color = already ? Theme.text4 : Theme.text
                                let bgColor: Color = already ? Theme.bg3.opacity(0.5) : Theme.card
                                Text(sym)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(fgColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 9)
                                    .background(bgColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            .disabled(already)
                        }
                    }

                    Text("TAGS (optional)")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(1.5)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                        ForEach(WatchlistTag.allCases, id: \.self) { tag in
                            WatchlistTagChip(tag: tag, isSelected: selectedTags.contains(tag)) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    if selectedTags.contains(tag) { selectedTags.remove(tag) } else { selectedTags.insert(tag) }
                                }
                            }
                        }
                    }

                    Text("NOTE (optional)")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(1.5)
                    ZStack(alignment: .topLeading) {
                        if note.isEmpty {
                            Text("Why are you watching this?")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.text4)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                        }
                        TextEditor(text: $note)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.text)
                            .frame(minHeight: 60)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                    }
                    .background(Theme.bg3)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))

                    Button {
                        let ticker = query.uppercased().trimmingCharacters(in: .whitespaces)
                        if !ticker.isEmpty && !appState.isWatched(ticker) {
                            appState.addToWatchlist(ticker, tags: Array(selectedTags), note: note)
                        }
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(query.isEmpty ? "Add to Watchlist" : "Add \(query.uppercased())")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(query.trimmingCharacters(in: .whitespaces).isEmpty ? AnyShapeStyle(Theme.bg3) : AnyShapeStyle(Theme.accentGradient))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(18)
            }
            .background(Theme.bg)
            .navigationTitle("Add Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Theme.text3)
                    }
                }
            }
        }
    }
}
