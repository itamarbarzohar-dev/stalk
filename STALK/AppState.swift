import SwiftUI
import Observation
import StoreKit

// MARK: - Settings

struct PriceAlertThreshold: Codable, Identifiable {
    var id: UUID = UUID()
    var ticker: String
    var alertAbove: Double?
    var alertBelow: Double?
}

struct STALKSettings: Codable {
    var theme: String = "indigo"
    var privacy: String = "public"
    var darkMode: Bool = true
    var largeText: Bool = false
    var showValue: Bool = true
    var priceAlerts: Bool = true
    var earnings: Bool = true
    var whaleAlerts: Bool = false
    var socialActivity: Bool = true
    var biometric: Bool = false
    var leaderboard: Bool = true
    var friendsComparison: Bool = true
    var currency: String = "USD"
    var chartRange: String = "1mo"
    var sortBy: String = "pnl"
    var displayName: String = "Itamar B."
    var username: String = "@itamar"
    var bio: String = "Investor · STALK Pro"
    var hasCompletedOnboarding: Bool = false
    var alertThresholds: [PriceAlertThreshold] = []
    var isPro: Bool = false
    var aiMessagesUsed: Int = 0
    var priceAlertCount: Int = 0
}

enum AppTheme: String, CaseIterable {
    case indigo, rose, emerald, ocean, amber, pink, midnight, gold

    var label: String { rawValue.capitalized }

    var accent: Color {
        switch self {
        case .indigo:   return Color(hex: "#5B5BD6")
        case .rose:     return Color(hex: "#E11D48")
        case .emerald:  return Color(hex: "#059669")
        case .ocean:    return Color(hex: "#0284C7")
        case .amber:    return Color(hex: "#D97706")
        case .pink:     return Color(hex: "#DB2777")
        case .midnight: return Color(hex: "#4B5563")
        case .gold:     return Color(hex: "#B45309")
        }
    }

    var accent2: Color {
        switch self {
        case .indigo:   return Color(hex: "#8B7CF6")
        case .rose:     return Color(hex: "#FB7185")
        case .emerald:  return Color(hex: "#34D399")
        case .ocean:    return Color(hex: "#38BDF8")
        case .amber:    return Color(hex: "#F59E0B")
        case .pink:     return Color(hex: "#F472B6")
        case .midnight: return Color(hex: "#6B7280")
        case .gold:     return Color(hex: "#D97706")
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: [accent, accent2], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var heroGradient: LinearGradient {
        switch self {
        case .indigo:   return LinearGradient(colors: [Color(hex: "#4B4ACF"), Color(hex: "#7B6FEF"), Color(hex: "#B8AAFF")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .rose:     return LinearGradient(colors: [Color(hex: "#BE123C"), Color(hex: "#E11D48"), Color(hex: "#FB7185")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .emerald:  return LinearGradient(colors: [Color(hex: "#047857"), Color(hex: "#059669"), Color(hex: "#6EE7B7")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ocean:    return LinearGradient(colors: [Color(hex: "#0369A1"), Color(hex: "#0284C7"), Color(hex: "#7DD3FC")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .amber:    return LinearGradient(colors: [Color(hex: "#B45309"), Color(hex: "#D97706"), Color(hex: "#FCD34D")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .pink:     return LinearGradient(colors: [Color(hex: "#BE185D"), Color(hex: "#DB2777"), Color(hex: "#F9A8D4")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .midnight: return LinearGradient(colors: [Color(hex: "#111827"), Color(hex: "#1F2937"), Color(hex: "#374151")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gold:     return LinearGradient(colors: [Color(hex: "#92400E"), Color(hex: "#B45309"), Color(hex: "#F59E0B")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

@Observable
class AppState {
    // MARK: Portfolio
    var positions: [Position] = []
    var quotes: [String: Quote] = [:]
    var isLoadingPortfolio = false

    // MARK: Social
    var followed: Set<Int> = []
    var likedPosts: Set<Int> = []
    var userPosts: [UserPost] = []
    var notifications: [ActivityItem] = ACTIVITY_ITEMS
    var joinedCommunities: Set<String> = []
    var forYouSections: Set<String> = ["insider", "earnings", "putcall", "volume", "catalyst"]
    var copiedAmounts: [Int: Double] = [:]
    var postComments: [UUID: [Comment]] = [:]
    var savedItems: Set<UUID> = []
    var userWatchlists: [UserWatchlist] = []
    var activeWatchlistIndex: Int = 0
    var watchlistColumns: [WatchlistStat] = [.last, .changePct]

    // Backward-compat computed property (MarketView, MyProfileView, etc.)
    var watchlist: [WatchlistItem] {
        guard !userWatchlists.isEmpty else { return [] }
        return userWatchlists[min(activeWatchlistIndex, userWatchlists.count - 1)].items
    }

    // MARK: Market
    var marketQuotes: [String: Quote] = [:]
    var isLoadingMarket = false

    // MARK: Settings
    var settings: STALKSettings = STALKSettings()

    var currentTheme: AppTheme { AppTheme(rawValue: settings.theme) ?? .indigo }
    var accentColor: Color { currentTheme.accent }
    var accentGradient: LinearGradient { currentTheme.gradient }
    var heroGradient: LinearGradient { currentTheme.heroGradient }

    // MARK: Navigation
    var selectedTab: Tab = .portfolio
    var showSettings = false
    var showAIChat = false
    var showDailyBrief = false

    // MARK: Gamification
    var streak: Int = 0
    var portfolioATH: Double = 0

    init() {
        loadPositions()
        loadSocial()
        loadSettings()
        loadStreak()
        loadWatchlist()
        portfolioATH = UserDefaults.standard.double(forKey: "stalk_ath")
        if let saved = UserDefaults.standard.array(forKey: "stalk_foryou_sections") as? [String] {
            forYouSections = Set(saved)
        }
        if let data = UserDefaults.standard.data(forKey: "stalk_watchlist_columns"),
           let cols = try? JSONDecoder().decode([WatchlistStat].self, from: data) {
            watchlistColumns = cols
        }
    }

    // MARK: - Persistence

    private func loadPositions() {
        if let data = UserDefaults.standard.data(forKey: "stalk_positions"),
           let saved = try? JSONDecoder().decode([Position].self, from: data) {
            positions = saved
        }
    }

    func savePositions() {
        if let data = try? JSONEncoder().encode(positions) {
            UserDefaults.standard.set(data, forKey: "stalk_positions")
        }
    }

    private func loadSocial() {
        if let f = UserDefaults.standard.array(forKey: "stalk_followed") as? [Int] {
            followed = Set(f)
        }
        if let l = UserDefaults.standard.array(forKey: "stalk_liked") as? [Int] {
            likedPosts = Set(l)
        }
        if let data = UserDefaults.standard.data(forKey: "stalk_userposts"),
           let saved = try? JSONDecoder().decode([UserPost].self, from: data) {
            userPosts = saved
        }
        if let c = UserDefaults.standard.array(forKey: "stalk_copied") as? [Int] {
            copiedTraders = Set(c)
        }
    }

    func addUserPost(_ post: UserPost) {
        userPosts.insert(post, at: 0)
        if let data = try? JSONEncoder().encode(userPosts) {
            UserDefaults.standard.set(data, forKey: "stalk_userposts")
        }
    }

    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "stalk_settings"),
           let saved = try? JSONDecoder().decode(STALKSettings.self, from: data) {
            settings = saved
        }
    }

    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "stalk_settings")
        }
    }

    // MARK: - Watchlist helpers (operate on active watchlist)

    private var activeIdx: Int {
        min(activeWatchlistIndex, max(0, userWatchlists.count - 1))
    }

    func addToWatchlist(_ ticker: String) {
        guard !userWatchlists.isEmpty else { return }
        guard !userWatchlists[activeIdx].items.contains(where: { $0.ticker == ticker }) else { return }
        userWatchlists[activeIdx].items.insert(WatchlistItem(ticker: ticker), at: 0)
        saveWatchlists()
    }

    func addToWatchlist(_ ticker: String, tags: [WatchlistTag], note: String) {
        guard !userWatchlists.isEmpty else { return }
        guard !userWatchlists[activeIdx].items.contains(where: { $0.ticker == ticker }) else { return }
        userWatchlists[activeIdx].items.insert(WatchlistItem(ticker: ticker, tags: tags, note: note), at: 0)
        saveWatchlists()
    }

    func removeFromWatchlist(_ ticker: String) {
        guard !userWatchlists.isEmpty else { return }
        userWatchlists[activeIdx].items.removeAll { $0.ticker == ticker }
        saveWatchlists()
    }

    func isWatched(_ ticker: String) -> Bool {
        guard !userWatchlists.isEmpty else { return false }
        return userWatchlists[activeIdx].items.contains { $0.ticker == ticker }
    }

    func updateWatchlistItem(_ item: WatchlistItem) {
        guard !userWatchlists.isEmpty else { return }
        if let i = userWatchlists[activeIdx].items.firstIndex(where: { $0.id == item.id }) {
            userWatchlists[activeIdx].items[i] = item
            saveWatchlists()
        }
    }

    func updateWatchlistItem(_ id: UUID, tags: [WatchlistTag], note: String) {
        guard !userWatchlists.isEmpty else { return }
        if let i = userWatchlists[activeIdx].items.firstIndex(where: { $0.id == id }) {
            userWatchlists[activeIdx].items[i].tags = tags
            userWatchlists[activeIdx].items[i].note = note
            saveWatchlists()
        }
    }

    // MARK: - Multi-Watchlist management

    func createWatchlist(name: String) {
        userWatchlists.append(UserWatchlist(name: name))
        activeWatchlistIndex = userWatchlists.count - 1
        saveWatchlists()
    }

    func deleteWatchlist(at index: Int) {
        guard userWatchlists.count > 1, userWatchlists.indices.contains(index) else { return }
        userWatchlists.remove(at: index)
        activeWatchlistIndex = min(activeWatchlistIndex, userWatchlists.count - 1)
        saveWatchlists()
    }

    func renameWatchlist(at index: Int, to name: String) {
        guard userWatchlists.indices.contains(index) else { return }
        userWatchlists[index].name = name
        saveWatchlists()
    }

    func price(for ticker: String) -> Double {
        marketQuotes[ticker]?.price ?? quotes[ticker]?.price ?? 0
    }

    func change(for ticker: String) -> Double {
        marketQuotes[ticker]?.changePercent ?? quotes[ticker]?.changePercent ?? 0
    }

    private func loadWatchlist() {
        // Try loading multi-watchlist data first
        if let data = UserDefaults.standard.data(forKey: "stalk_user_watchlists"),
           let saved = try? JSONDecoder().decode([UserWatchlist].self, from: data) {
            userWatchlists = saved
            return
        }
        // Migrate legacy single watchlist
        if let data = UserDefaults.standard.data(forKey: "stalk_watchlist"),
           let saved = try? JSONDecoder().decode([WatchlistItem].self, from: data) {
            userWatchlists = [UserWatchlist(name: "My Watchlist", items: saved)]
        } else {
            userWatchlists = [UserWatchlist(name: "My Watchlist")]
        }
        saveWatchlists()
    }

    func saveWatchlists() {
        if let data = try? JSONEncoder().encode(userWatchlists) {
            UserDefaults.standard.set(data, forKey: "stalk_user_watchlists")
        }
    }

    func saveWatchlistColumns() {
        if let data = try? JSONEncoder().encode(watchlistColumns) {
            UserDefaults.standard.set(data, forKey: "stalk_watchlist_columns")
        }
    }

    // MARK: - Mock stat values (deterministic per ticker)
    func statValue(for stat: WatchlistStat, ticker: String) -> String {
        let p = price(for: ticker)
        let chgPct = change(for: ticker)
        let basePrice = p > 0 ? p : 100.0
        // Seed from ticker string for consistency
        let seed = ticker.unicodeScalars.reduce(0) { $0 + Int($1.value) }

        func mockFrac(_ offset: Int, lo: Double = 0, hi: Double = 1) -> Double {
            let v = abs((seed &* 1664525 &+ offset) % 10000)
            return lo + (Double(v) / 9999.0) * (hi - lo)
        }

        switch stat {
        case .last:
            return basePrice > 0 ? "$\(String(format: "%.2f", basePrice))" : "—"
        case .changePct:
            let s = chgPct >= 0 ? "+" : ""
            return "\(s)\(String(format: "%.2f", chgPct))%"
        case .changeDollar:
            let chgD = basePrice * chgPct / 100
            let s = chgD >= 0 ? "+" : ""
            return "\(s)$\(String(format: "%.2f", abs(chgD)))"
        case .volume:
            let v = Int(mockFrac(1, lo: 1_000_000, hi: 80_000_000))
            return v >= 1_000_000 ? "\(String(format: "%.1f", Double(v) / 1_000_000))M" : "\(v / 1000)K"
        case .avgVolume:
            let v = Int(mockFrac(2, lo: 2_000_000, hi: 60_000_000))
            return v >= 1_000_000 ? "\(String(format: "%.1f", Double(v) / 1_000_000))M" : "\(v / 1000)K"
        case .marketCap:
            let shares = mockFrac(3, lo: 50_000_000, hi: 15_000_000_000)
            let cap = basePrice * shares
            if cap >= 1_000_000_000_000 { return "$\(String(format: "%.2f", cap / 1e12))T" }
            if cap >= 1_000_000_000 { return "$\(String(format: "%.1f", cap / 1e9))B" }
            return "$\(String(format: "%.0f", cap / 1e6))M"
        case .pe:
            let pe = mockFrac(4, lo: 8, hi: 95)
            return String(format: "%.1f", pe)
        case .eps:
            let pe = mockFrac(4, lo: 8, hi: 95)
            return "$\(String(format: "%.2f", basePrice / pe))"
        case .beta:
            return String(format: "%.2f", mockFrac(5, lo: 0.4, hi: 2.8))
        case .divYield:
            let hasDividend = (seed % 3) != 0
            if !hasDividend { return "—" }
            return "\(String(format: "%.2f", mockFrac(6, lo: 0.5, hi: 5.5)))%"
        case .week52High:
            let high = basePrice * (1 + mockFrac(7, lo: 0.05, hi: 0.65))
            return "$\(String(format: "%.2f", high))"
        case .week52Low:
            let low = basePrice * (1 - mockFrac(8, lo: 0.05, hi: 0.55))
            return "$\(String(format: "%.2f", low))"
        case .dayHigh:
            return "$\(String(format: "%.2f", basePrice * (1 + mockFrac(9, lo: 0.002, hi: 0.025))))"
        case .dayLow:
            return "$\(String(format: "%.2f", basePrice * (1 - mockFrac(10, lo: 0.002, hi: 0.025))))"
        case .open:
            return "$\(String(format: "%.2f", basePrice * (1 + mockFrac(11, lo: -0.015, hi: 0.015))))"
        case .prevClose:
            return "$\(String(format: "%.2f", basePrice * (1 - chgPct / 100)))"
        case .rsi:
            return String(format: "%.1f", mockFrac(12, lo: 25, hi: 78))
        case .shortFloat:
            return "\(String(format: "%.1f", mockFrac(13, lo: 1, hi: 30)))%"
        }
    }

    func clearAllData() {
        positions = []
        quotes = [:]
        followed = []
        likedPosts = []
        settings = STALKSettings()
        UserDefaults.standard.removeObject(forKey: "stalk_positions")
        UserDefaults.standard.removeObject(forKey: "stalk_followed")
        UserDefaults.standard.removeObject(forKey: "stalk_liked")
        UserDefaults.standard.removeObject(forKey: "stalk_settings")
    }

    func exportCSV() -> String {
        var rows = ["Ticker,Shares,Avg Cost,Current Price,Value,P&L,P&L %"]
        for p in positions {
            let price = quotes[p.ticker]?.price ?? p.avgCost
            let val = price * p.shares
            let pnl = val - p.avgCost * p.shares
            let pct = p.avgCost > 0 ? (pnl / (p.avgCost * p.shares)) * 100 : 0
            rows.append("\(p.ticker),\(p.shares),\(p.avgCost),\(String(format: "%.2f", price)),\(String(format: "%.2f", val)),\(String(format: "%.2f", pnl)),\(String(format: "%.2f", pct))%")
        }
        return rows.joined(separator: "\n")
    }

    func updateATH() {
        if totalValue > portfolioATH && totalValue > 0 {
            portfolioATH = totalValue
            UserDefaults.standard.set(portfolioATH, forKey: "stalk_ath")
        }
    }

    private func loadStreak() {
        streak = UserDefaults.standard.integer(forKey: "stalk_streak")
        let last = UserDefaults.standard.object(forKey: "stalk_streak_date") as? Date ?? .distantPast
        var cal = Calendar.current
        cal.timeZone = MarketCalendar.eastern
        if !cal.isDateInToday(last) {
            if cal.isDateInYesterday(last) {
                streak += 1
            } else {
                streak = 1
            }
            UserDefaults.standard.set(streak, forKey: "stalk_streak")
            UserDefaults.standard.set(Date(), forKey: "stalk_streak_date")
        }
    }

    func toggleFollow(_ id: Int) {
        if followed.contains(id) { followed.remove(id) } else { followed.insert(id) }
        UserDefaults.standard.set(Array(followed), forKey: "stalk_followed")
    }

    func toggleLike(_ id: Int) {
        if likedPosts.contains(id) { likedPosts.remove(id) } else { likedPosts.insert(id) }
        UserDefaults.standard.set(Array(likedPosts), forKey: "stalk_liked")
    }

    var copiedTraders: Set<Int> = []

    func toggleCopyTrade(_ id: Int) {
        if copiedTraders.contains(id) { copiedTraders.remove(id) } else { copiedTraders.insert(id) }
        UserDefaults.standard.set(Array(copiedTraders), forKey: "stalk_copied")
    }

    // MARK: - Portfolio Computed

    var totalValue: Double {
        positions.reduce(0) { sum, p in
            let price = quotes[p.ticker]?.price ?? p.avgCost
            return sum + price * p.shares
        }
    }

    var totalCost: Double {
        positions.reduce(0) { $0 + $1.avgCost * $1.shares }
    }

    var totalPnl: Double { totalValue - totalCost }
    var totalPnlPct: Double { totalCost > 0 ? (totalPnl / totalCost) * 100 : 0 }

    var todayPnl: Double {
        positions.reduce(0) { sum, p in
            sum + (quotes[p.ticker]?.change ?? 0) * p.shares
        }
    }

    var todayPnlPct: Double { totalValue > 0 ? (todayPnl / totalValue) * 100 : 0 }

    // MARK: - Network

    func refreshPortfolio() async {
        guard !positions.isEmpty else { return }
        isLoadingPortfolio = true
        let tickers = positions.map(\.ticker)
        let fetched = await QuoteService.fetchManyQuotes(tickers)
        quotes.merge(fetched) { _, new in new }
        isLoadingPortfolio = false
        updateATH()
    }

    func refreshMarket() async {
        isLoadingMarket = true
        let all = SECTORS.map(\.etf) + INDEX_TICKERS + TRENDING_TICKERS
        let fetched = await QuoteService.fetchManyQuotes(all)
        marketQuotes.merge(fetched) { _, new in new }
        isLoadingMarket = false
    }

    // MARK: - Portfolio Mutations

    func addPosition(_ p: Position) {
        if let idx = positions.firstIndex(where: { $0.ticker == p.ticker }) {
            let existing = positions[idx]
            let totalShares = existing.shares + p.shares
            let newAvg = (existing.avgCost * existing.shares + p.avgCost * p.shares) / totalShares
            positions[idx] = Position(id: existing.id, ticker: p.ticker, shares: totalShares, avgCost: newAvg)
        } else {
            positions.append(p)
        }
        savePositions()
    }

    func deletePosition(at offsets: IndexSet) {
        positions.remove(atOffsets: offsets)
        savePositions()
    }

    func deletePosition(_ p: Position) {
        positions.removeAll { $0.id == p.id }
        savePositions()
    }

    // MARK: - StoreKit

    var storeKitProducts: [Product] = []

    func loadStoreKitProducts() async {
        do {
            storeKitProducts = try await Product.products(for: [
                "com.itamar.stalk.pro.monthly",
                "com.itamar.stalk.pro.annual"
            ])
        } catch {
            print("StoreKit load failed: \(error)")
        }
    }

    func purchaseProduct(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    settings.isPro = true
                    saveSettings()
                    return true
                }
                return false
            case .userCancelled, .pending: return false
            @unknown default: return false
            }
        } catch {
            print("Purchase failed: \(error)")
            return false
        }
    }

    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               (tx.productID == "com.itamar.stalk.pro.monthly" || tx.productID == "com.itamar.stalk.pro.annual"),
               tx.revocationDate == nil {
                settings.isPro = true
                saveSettings()
                return
            }
        }
        settings.isPro = false
        saveSettings()
    }

    func listenForTransactions() {
        Task {
            for await result in Transaction.updates {
                if case .verified(let tx) = result {
                    let active = tx.revocationDate == nil && (tx.expirationDate ?? .distantFuture) > Date()
                    settings.isPro = active
                    saveSettings()
                    await tx.finish()
                }
            }
        }
    }
}

enum Tab: String, CaseIterable {
    case market, portfolio, watchlist, ai, feed, forYou
}
