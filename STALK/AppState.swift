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
        portfolioATH = UserDefaults.standard.double(forKey: "stalk_ath")
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
    case market, portfolio, search, feed, forYou
}
