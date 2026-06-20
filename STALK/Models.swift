import Foundation
import SwiftUI

// MARK: - Portfolio

struct Position: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var ticker: String
    var shares: Double
    var avgCost: Double
}

struct Quote: Sendable {
    var ticker: String
    var price: Double
    var change: Double
    var changePercent: Double
    var name: String

    var isUp: Bool { change >= 0 }
}

struct ChartPoint: Identifiable {
    var id = UUID()
    var index: Int
    var value: Double
    var label: String
}

// MARK: - User Posts

struct UserPost: Identifiable, Codable {
    var id: UUID = UUID()
    var text: String
    var tickers: [String]
    var sentiment: String   // "Bullish" / "Bearish" / "Neutral"
    var timestamp: Date = Date()
}

// MARK: - Comments

struct Comment: Identifiable, Codable {
    var id = UUID()
    let authorName: String
    let authorHandle: String
    let text: String
    let likes: Int
    let timeAgo: String
}

// MARK: - Activity Feed

enum ActivityType: String, Codable {
    case copied, followed, copyPnl, earnings, whale, friendPost
}

struct ActivityItem: Identifiable {
    var id = UUID()
    let type: ActivityType
    let actor: String
    let detail: String
    let value: String?
    let timeAgo: String
    let isToday: Bool
}

// MARK: - Communities

struct Community: Identifiable {
    var id = UUID()
    let icon: String
    let name: String
    let members: Int
    let activity24h: Int
    let topHoldings: [String]
    let color: Color
    let description: String
}

// MARK: - Trade History

struct TradeHistoryItem: Identifiable {
    var id = UUID()
    let ticker: String
    let action: String
    let pct: Double
    let daysHeld: Int
    let date: String
}

// MARK: - Social / Feed

struct TraderHolding: Identifiable {
    let ticker: String
    let pct: Double
    var id: String { ticker }
}

struct Trader: Identifiable {
    let id: Int
    let name: String
    let handle: String
    let initial: String
    let color: Color
    let followers: Int
    let following: Int
    let perf: TraderPerf
    let holdings: [String]
    let text: String
    let time: String
    let likes: Int
    // Leaderboard / stories fields
    var weekPct: Double
    // New social fields
    var isPro: Bool = false
    var take: String = ""
    var riskScore: Int = 5
    var maxDrawdown: Double = -14.0
    var winRate: Double = 62.0
    var copiers: Int = 0
    var avgHoldingDays: Int = 12
    var tradeHistory: [TradeHistoryItem] = []
    // Computed
    var todayPct: Double { perf.day }
    var allTimeReturn: Double { perf.allTime }
    var topHolding: String { holdings.first ?? "" }

    /// Rich holding chips — ticker + mock daily pct spread for display
    var holdingDetails: [TraderHolding] {
        let base = perf.day
        let offsets: [Double] = [0.0, 0.4, -0.3, 0.7, -0.5, 0.2]
        return holdings.enumerated().map { i, ticker in
            TraderHolding(ticker: ticker, pct: base + offsets[i % offsets.count])
        }
    }
}

struct TraderPerf {
    let day: Double
    let sixMonth: Double
    let ytd: Double
    let allTime: Double

    func label(_ v: Double) -> String { v >= 0 ? "+\(String(format: "%.1f", v))%" : "\(String(format: "%.1f", v))%" }
}

let TRADERS: [Trader] = [
    Trader(id: 1, name: "Alex Chen", handle: "@alexcrypto", initial: "A", color: Color(hex: "#818CF8"),
           followers: 2341, following: 180,
           perf: TraderPerf(day: 1.2, sixMonth: 18.4, ytd: 22.1, allTime: 61.3),
           holdings: ["NVDA", "AAPL", "MSFT", "GOOGL"],
           text: "Loaded up on NVDA again — AI infrastructure is just getting started 🚀",
           time: "2h ago", likes: 47, weekPct: 4.7,
           isPro: true, take: "AI infrastructure spend is accelerating — every hyperscaler is doubling capex. NVDA is the toll booth. I'm adding on every dip.",
           riskScore: 7, maxDrawdown: -18.4, winRate: 71.0, copiers: 1247, avgHoldingDays: 8,
           tradeHistory: [
               TradeHistoryItem(ticker: "NVDA", action: "BUY", pct: 34.2, daysHeld: 5, date: "Jun 15"),
               TradeHistoryItem(ticker: "MSFT", action: "BUY", pct: 8.1, daysHeld: 12, date: "May 28"),
               TradeHistoryItem(ticker: "AAPL", action: "SELL", pct: -2.3, daysHeld: 4, date: "May 15"),
               TradeHistoryItem(ticker: "AMD", action: "BUY", pct: 19.7, daysHeld: 18, date: "Apr 22"),
           ]),
    Trader(id: 2, name: "Sara Kim", handle: "@saratrades", initial: "S", color: Color(hex: "#F472B6"),
           followers: 8903, following: 94,
           perf: TraderPerf(day: -0.3, sixMonth: 9.7, ytd: 14.2, allTime: 38.5),
           holdings: ["TSLA", "META", "AMZN"],
           text: "Trimmed my Tesla position after the run-up. Taking profits at $250 🎯",
           time: "4h ago", likes: 123, weekPct: 2.1,
           isPro: true, take: "Trimmed TSLA at $250 — that's a 40% gain from my cost basis. Cash is a position too. Waiting for re-entry around $210.",
           riskScore: 5, maxDrawdown: -11.2, winRate: 64.3, copiers: 3891, avgHoldingDays: 21,
           tradeHistory: [
               TradeHistoryItem(ticker: "TSLA", action: "SELL", pct: 41.0, daysHeld: 45, date: "Jun 12"),
               TradeHistoryItem(ticker: "META", action: "BUY", pct: 22.4, daysHeld: 30, date: "May 20"),
               TradeHistoryItem(ticker: "AMZN", action: "SELL", pct: 11.8, daysHeld: 14, date: "Apr 30"),
               TradeHistoryItem(ticker: "TSLA", action: "BUY", pct: -5.1, daysHeld: 7, date: "Apr 10"),
           ]),
    Trader(id: 3, name: "Mike R.", handle: "@mikevalue", initial: "M", color: Color(hex: "#FBBF24"),
           followers: 1204, following: 312,
           perf: TraderPerf(day: 0.8, sixMonth: 5.1, ytd: 7.3, allTime: 29.1),
           holdings: ["BRK-B", "JPM", "V", "KO"],
           text: "Old school value investing still works. Berkshire + JPM = sleep well at night 💤",
           time: "6h ago", likes: 34, weekPct: 1.3,
           isPro: false, take: "Everyone chasing AI hype. Meanwhile I'm sleeping soundly with BRK-B, JPM, V, KO. Boring wins long-term.",
           riskScore: 2, maxDrawdown: -5.8, winRate: 58.0, copiers: 412, avgHoldingDays: 180,
           tradeHistory: [
               TradeHistoryItem(ticker: "KO",    action: "BUY",  pct: 3.2,  daysHeld: 180, date: "Jan 2"),
               TradeHistoryItem(ticker: "JPM",   action: "BUY",  pct: 12.4, daysHeld: 90,  date: "Mar 15"),
               TradeHistoryItem(ticker: "BRK-B", action: "BUY",  pct: 7.8,  daysHeld: 120, date: "Feb 28"),
           ]),
    Trader(id: 4, name: "Lena V.", handle: "@lena_invest", initial: "L", color: Color(hex: "#6EE7B7"),
           followers: 4512, following: 201,
           perf: TraderPerf(day: 2.1, sixMonth: 31.2, ytd: 41.5, allTime: 89.2),
           holdings: ["NVDA", "AMD", "SMCI", "AVGO"],
           text: "Semis are on fire this week. My portfolio is up 2% just today 🔥",
           time: "8h ago", likes: 211, weekPct: 9.4,
           isPro: true, take: "Semis up 2% just today. SMCI broke out of its consolidation. If you're not in semis right now you're missing the decade trade.",
           riskScore: 8, maxDrawdown: -24.1, winRate: 78.2, copiers: 2673, avgHoldingDays: 11,
           tradeHistory: [
               TradeHistoryItem(ticker: "SMCI", action: "BUY",  pct: 47.3, daysHeld: 14, date: "Jun 10"),
               TradeHistoryItem(ticker: "AMD",  action: "SELL", pct: 33.5, daysHeld: 11, date: "Jun 5"),
               TradeHistoryItem(ticker: "NVDA", action: "BUY",  pct: 61.2, daysHeld: 7,  date: "Jun 1"),
               TradeHistoryItem(ticker: "AVGO", action: "BUY",  pct: 28.1, daysHeld: 21, date: "May 25"),
           ]),
]

// Extended trader list for feed stories & leaderboard
let FEED_TRADERS: [Trader] = TRADERS + [
    Trader(id: 5, name: "James T.", handle: "@jtrades", initial: "J", color: Color(hex: "#60A5FA"),
           followers: 3120, following: 240,
           perf: TraderPerf(day: -1.4, sixMonth: 6.2, ytd: 11.0, allTime: 44.8),
           holdings: ["AMZN", "GOOGL", "NFLX"],
           text: "Cloud names still my favourite long. Holding AMZN through earnings 🤞",
           time: "9h ago", likes: 61, weekPct: -2.1,
           isPro: false, take: "Cloud hyperscalers reporting next week. I'm holding AMZN, GOOGL through earnings. Risk/reward still favourable at current multiples."),
    Trader(id: 6, name: "Priya N.", handle: "@priyainvests", initial: "P", color: Color(hex: "#F87171"),
           followers: 5890, following: 130,
           perf: TraderPerf(day: 3.2, sixMonth: 22.8, ytd: 35.0, allTime: 102.4),
           holdings: ["NVDA", "TSM", "AVGO"],
           text: "Semis ATH incoming. TSM just broke out of a 6-month base 🚀",
           time: "11h ago", likes: 188, weekPct: 11.2,
           isPro: true, take: "TSM just broke out of a 6-month base on massive volume. This is textbook. Target $220. AVGO earnings next week = catalyst."),
    Trader(id: 7, name: "David K.", handle: "@davek", initial: "D", color: Color(hex: "#34D399"),
           followers: 920, following: 88,
           perf: TraderPerf(day: 0.4, sixMonth: 3.8, ytd: 5.2, allTime: 18.7),
           holdings: ["SPY", "VTI", "SCHD"],
           text: "Dollar-cost averaging into index funds every week. Boring but it works.",
           time: "12h ago", likes: 22, weekPct: 0.8,
           isPro: false, take: "Week 312 of DCA into VTI. Market timing is a loser's game. Time in the market beats timing the market — always."),
    Trader(id: 8, name: "Nina H.", handle: "@ninahedge", initial: "N", color: Color(hex: "#A78BFA"),
           followers: 7400, following: 310,
           perf: TraderPerf(day: -2.3, sixMonth: -4.1, ytd: 2.0, allTime: 55.9),
           holdings: ["GLD", "TLT", "BRK-B"],
           text: "Rotating into defensives. Market looks extended to me right now 🤔",
           time: "1d ago", likes: 95, weekPct: -3.8,
           isPro: true, take: "Reducing equity exposure to 50%. Rotating into GLD and TLT. Breadth is terrible — only mega-caps holding the indices up. Be careful."),
]

// MARK: - Market / Sectors

struct SectorInfo {
    let name: String
    let etf: String
    let icon: String
}

let SECTORS: [SectorInfo] = [
    .init(name: "Tech",        etf: "XLK",  icon: "💻"),
    .init(name: "Financials",  etf: "XLF",  icon: "🏦"),
    .init(name: "Healthcare",  etf: "XLV",  icon: "🏥"),
    .init(name: "Energy",      etf: "XLE",  icon: "⚡"),
    .init(name: "Consumer",    etf: "XLY",  icon: "🛍️"),
    .init(name: "Industrials", etf: "XLI",  icon: "🏗️"),
    .init(name: "Utilities",   etf: "XLU",  icon: "💡"),
    .init(name: "Real Estate", etf: "XLRE", icon: "🏠"),
    .init(name: "Semis",       etf: "SOXX", icon: "🔷"),
    .init(name: "AI",          etf: "BOTZ", icon: "🤖"),
    .init(name: "Clean Enrg",  etf: "ICLN", icon: "🌱"),
    .init(name: "Crypto",      etf: "IBIT", icon: "🪙"),
]

// Using ETF equivalents — SPY/DIA/IWM are more reliable from Yahoo Finance than ^ index tickers
let INDEX_TICKERS = ["SPY", "QQQ", "DIA", "IWM"]
let INDEX_NAMES: [String: String] = [
    "SPY": "S&P 500",      "QQQ": "NASDAQ 100",
    "DIA": "Dow Jones",    "IWM": "Russell 2000",
]
let TRENDING_TICKERS = ["NVDA", "AAPL", "TSLA", "META", "MSFT"]

// MARK: - Watchlists

struct WatchlistGroup: Identifiable {
    let id: String
    let label: String
    let color: Color
    let tickers: [String]
    var icon: String { label.split(separator: " ").first.map(String.init) ?? "📊" }
    var title: String { label.split(separator: " ").dropFirst().joined(separator: " ") }
}

let WATCHLISTS: [WatchlistGroup] = [
    .init(id: "trending", label: "🔥 Trending Now",          color: Color(hex: "#E11D48"), tickers: ["NVDA","TSLA","META","PLTR","MSTR","COIN","ARM","SMCI"]),
    .init(id: "chips",    label: "🔷 Semiconductors",         color: Color(hex: "#5B5BD6"), tickers: ["NVDA","AMD","INTC","QCOM","AVGO","TSM","SMCI","MU"]),
    .init(id: "ai",       label: "🤖 Artificial Intelligence",color: Color(hex: "#8B7CF6"), tickers: ["NVDA","MSFT","GOOGL","META","PLTR","AI","IBM","ORCL"]),
    .init(id: "quantum",  label: "⚛️ Quantum Computing",      color: Color(hex: "#0284C7"), tickers: ["IONQ","RGTI","QUBT","IBM","GOOGL","MSFT"]),
    .init(id: "crypto",   label: "🪙 Crypto Stocks",          color: Color(hex: "#F59E0B"), tickers: ["COIN","MSTR","MARA","RIOT","CLSK","IBIT"]),
    .init(id: "energy",   label: "⚡ Clean Energy",           color: Color(hex: "#059669"), tickers: ["ENPH","FSLR","NEE","PLUG","BE","SEDG"]),
    .init(id: "space",    label: "🚀 Space & Defense",        color: Color(hex: "#1D4ED8"), tickers: ["RKLB","ASTS","LUNR","LMT","RTX","NOC"]),
    .init(id: "fintech",  label: "🏦 Fintech",                color: Color(hex: "#7C3AED"), tickers: ["SQ","PYPL","SOFI","AFRM","NU","UPST","HOOD"]),
    .init(id: "health",   label: "🏥 Healthcare",             color: Color(hex: "#DB2777"), tickers: ["LLY","JNJ","UNH","MRNA","PFE","ABBV","AMGN"]),
    .init(id: "etf",      label: "📊 ETFs",                   color: Color(hex: "#0EA5E9"), tickers: ["SPY","QQQ","VTI","ARKK","SCHD","VGT","GLD"]),
]

// MARK: - For You

struct EarningsReport: Identifiable {
    struct EarningsCell {
        let estimate: String
        let actual: String?
        let beat: Bool?
        let surprise: String?
    }
    let id = UUID()
    let company: String
    let ticker: String
    let time: String
    let eps: EarningsCell
    let rev: EarningsCell
    let guidance: String
    let guidanceText: String
    let reactions: [String]
}

struct InsiderBuy: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let company: String
    let ticker: String
    let shares: String
    let value: String
    let date: String
    let sentiment: String
}

struct PoliticalTweet: Identifiable {
    let id = UUID()
    let name: String
    let handle: String
    let text: String
    let time: String
    let tickers: [String]
    let impact: Double
}

struct AnalystMove: Identifiable {
    let id = UUID()
    let firm: String
    let action: String
    let ticker: String
    let fromRating: String
    let priceTarget: String
    let changeLabel: String
    let isUpgrade: Bool
}

struct WorldGainer: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let flag: String
    let initial: String
    let color: Color
    let todayReturn: Double
    let value: String
    let followers: Int
    let holdings: [(ticker: String, weight: Int)]
    let bio: String
    let ytd: Double
}

let EARNINGS: [EarningsReport] = [
    EarningsReport(company: "Oracle", ticker: "ORCL", time: "After Close",
        eps: .init(estimate: "$1.63", actual: "$1.78", beat: true, surprise: "+9.2%"),
        rev: .init(estimate: "$14.7B", actual: "$15.1B", beat: true, surprise: "+2.7%"),
        guidance: "raised", guidanceText: "$16.2B next Q (est. $15.8B)",
        reactions: ["🚀 Stock +8% AH", "📈 Beat on all metrics", "⭐ 14 upgrades"]),
    EarningsReport(company: "Adobe", ticker: "ADBE", time: "After Close",
        eps: .init(estimate: "$4.97", actual: "$4.81", beat: false, surprise: "-3.2%"),
        rev: .init(estimate: "$5.77B", actual: "$5.71B", beat: false, surprise: "-1.0%"),
        guidance: "lowered", guidanceText: "$5.65B next Q (est. $5.9B)",
        reactions: ["📉 Stock -6% AH", "⚠️ Guidance miss", "🔴 3 downgrades"]),
    EarningsReport(company: "MongoDB", ticker: "MDB", time: "After Close",
        eps: .init(estimate: "$0.66", actual: "$0.94", beat: true, surprise: "+42.4%"),
        rev: .init(estimate: "$497M", actual: "$526M", beat: true, surprise: "+5.8%"),
        guidance: "raised", guidanceText: "$540M next Q (est. $515M)",
        reactions: ["🔥 Stock +14% AH", "💎 Massive beat", "⬆️ 8 upgrades"]),
]

let INSIDER_BUYS: [InsiderBuy] = [
    .init(name: "Jensen Huang",     role: "CEO",      company: "NVIDIA",     ticker: "NVDA", shares: "50,000",    value: "$27.3M", date: "Jun 3",  sentiment: "🟢 Strong Buy"),
    .init(name: "Elon Musk",        role: "Director", company: "Tesla",      ticker: "TSLA", shares: "1,200,000", value: "$290M",  date: "Jun 2",  sentiment: "🟢 Buy"),
    .init(name: "Mark Zuckerberg",  role: "CEO",      company: "Meta",       ticker: "META", shares: "80,000",    value: "$38.4M", date: "Jun 1",  sentiment: "🟢 Buy"),
    .init(name: "Satya Nadella",    role: "CEO",      company: "Microsoft",  ticker: "MSFT", shares: "25,000",    value: "$10.8M", date: "May 31", sentiment: "🟢 Buy"),
]

let POLITICAL_TWEETS: [PoliticalTweet] = [
    .init(name: "Donald J. Trump", handle: "@realDonaldTrump", text: "NVIDIA is doing GREAT things for America. AI chips made in the USA — nobody does it better! 🇺🇸", time: "2h ago", tickers: ["NVDA"], impact: 2.3),
    .init(name: "Donald J. Trump", handle: "@realDonaldTrump", text: "We are going to bring MANUFACTURING back. Steel, Chips, everything. Tariffs will make America RICH again!", time: "5h ago", tickers: ["X","NUE","CLF"], impact: 1.8),
    .init(name: "Donald J. Trump", handle: "@realDonaldTrump", text: "Apple must make their products in the United States. No more excuses. Do it NOW!", time: "1d ago", tickers: ["AAPL"], impact: -1.2),
    .init(name: "Donald J. Trump", handle: "@realDonaldTrump", text: "Bitcoin is the future. We will make the USA the crypto capital of the world. MAGA!", time: "1d ago", tickers: ["COIN","MSTR"], impact: 4.1),
]

let ANALYST_MOVES: [AnalystMove] = [
    .init(firm: "Goldman Sachs",  action: "Upgrade → Buy",        ticker: "NVDA", fromRating: "Neutral",    priceTarget: "$185 → $220", changeLabel: "+19%", isUpgrade: true),
    .init(firm: "Morgan Stanley", action: "Initiate Overweight",   ticker: "META", fromRating: "—",          priceTarget: "PT $620",     changeLabel: "New",  isUpgrade: true),
    .init(firm: "JPMorgan",       action: "Downgrade → Neutral",   ticker: "AAPL", fromRating: "Overweight", priceTarget: "$210 → $195", changeLabel: "-7%",  isUpgrade: false),
    .init(firm: "Citi",           action: "Upgrade → Buy",         ticker: "AMD",  fromRating: "Neutral",    priceTarget: "$180 → $210", changeLabel: "+17%", isUpgrade: true),
]

let WORLD_GAINERS: [WorldGainer] = [
    WorldGainer(rank: 1, name: "Oliver T.", flag: "🇬🇧", initial: "O", color: Color(hex: "#F59E0B"), todayReturn: 18.4, value: "$2.4M", followers: 12400, holdings: [("NVDA",40),("AMD",25),("SMCI",20),("AVGO",15)], bio: "Full-time trader · Semis & AI specialist", ytd: 127),
    WorldGainer(rank: 2, name: "Yuki M.",   flag: "🇯🇵", initial: "Y", color: Color(hex: "#EF4444"), todayReturn: 14.1, value: "$890K",  followers: 8200,  holdings: [("TSLA",50),("RIVN",30),("NIO",20)],                bio: "EV sector focus · 5yr track record",       ytd: 94),
    WorldGainer(rank: 3, name: "Sofia R.",  flag: "🇧🇷", initial: "S", color: Color(hex: "#8B5CF6"), todayReturn: 11.7, value: "$1.1M",  followers: 6700,  holdings: [("META",45),("GOOGL",35),("SNAP",20)],               bio: "Social media & ad tech investor",          ytd: 78),
    WorldGainer(rank: 4, name: "Carlos D.", flag: "🇲🇽", initial: "C", color: Color(hex: "#10B981"), todayReturn: 9.3,  value: "$3.2M",  followers: 21000, holdings: [("SPY",40),("QQQ",30),("AAPL",30)],                  bio: "Index + momentum strategy · 8yr veteran",  ytd: 52),
    WorldGainer(rank: 5, name: "Priya K.",  flag: "🇮🇳", initial: "P", color: Color(hex: "#F472B6"), todayReturn: 8.6,  value: "$650K",  followers: 4300,  holdings: [("MSFT",40),("AMZN",35),("CRM",25)],                  bio: "Cloud & SaaS focus · ex-Goldman analyst",  ytd: 44),
]

// MARK: - Communities Mock Data

let COMMUNITIES: [Community] = [
    Community(icon: "cpu.fill",             name: "AI & Semiconductors", members: 48200,  activity24h: 1243, topHoldings: ["NVDA","AMD","AVGO"],  color: Color(hex: "#5B5BD6"), description: "The AI chip race — NVDA, AMD, SMCI and the picks & shovels play"),
    Community(icon: "dollarsign.circle.fill", name: "Dividend Income",   members: 31700,  activity24h: 487,  topHoldings: ["O","KO","JNJ"],       color: Color(hex: "#22C55E"), description: "Build a passive income portfolio. Monthly payers, aristocrats and REITs"),
    Community(icon: "flame.fill",           name: "Meme Stocks",         members: 22400,  activity24h: 3891, topHoldings: ["GME","AMC","BBBY"],    color: Color(hex: "#F97316"), description: "High risk, high reward. WSB-style momentum plays and short squeezes"),
    Community(icon: "chart.bar.xaxis",      name: "Options Traders",     members: 19100,  activity24h: 2140, topHoldings: ["SPY","QQQ","AAPL"],   color: Color(hex: "#F43F5E"), description: "Calls, puts, spreads and income strategies for every skill level"),
    Community(icon: "building.columns.fill", name: "Value Investing",    members: 15800,  activity24h: 312,  topHoldings: ["BRK-B","BAC","V"],    color: Color(hex: "#D97706"), description: "Buffett-inspired long-only fundamentals. P/E, moats, margin of safety"),
    Community(icon: "globe.americas.fill",  name: "Macro Watchers",      members: 12300,  activity24h: 678,  topHoldings: ["GLD","TLT","DXY"],    color: Color(hex: "#38BDF8"), description: "Fed rates, CPI, yield curve, DXY. Top-down macro-driven investing"),
]

// MARK: - Activity Feed Mock Data

let ACTIVITY_ITEMS: [ActivityItem] = [
    ActivityItem(type: .copied,     actor: "Lena V.",       detail: "copied your portfolio",                  value: nil,      timeAgo: "2m ago",  isToday: true),
    ActivityItem(type: .followed,   actor: "James T.",      detail: "started following you",                  value: nil,      timeAgo: "15m ago", isToday: true),
    ActivityItem(type: .copyPnl,    actor: "Sara Kim",      detail: "your copy of Sara Kim is up",            value: "+8.4%",  timeAgo: "1h ago",  isToday: true),
    ActivityItem(type: .whale,      actor: "NVDA",          detail: "unusual options activity detected on",   value: "$340M",  timeAgo: "2h ago",  isToday: true),
    ActivityItem(type: .earnings,   actor: "MSFT",          detail: "reports earnings tomorrow — you hold",   value: nil,      timeAgo: "3h ago",  isToday: true),
    ActivityItem(type: .friendPost, actor: "Alex Chen",     detail: "posted a new trade idea",                value: nil,      timeAgo: "4h ago",  isToday: true),
    ActivityItem(type: .copied,     actor: "Priya N.",      detail: "copied your portfolio",                  value: nil,      timeAgo: "1d ago",  isToday: false),
    ActivityItem(type: .followed,   actor: "David K.",      detail: "started following you",                  value: nil,      timeAgo: "1d ago",  isToday: false),
    ActivityItem(type: .copyPnl,    actor: "Alex Chen",     detail: "your copy of Alex Chen is up",           value: "+12.1%", timeAgo: "2d ago",  isToday: false),
    ActivityItem(type: .whale,      actor: "TSLA",          detail: "large block trade detected on",          value: "$220M",  timeAgo: "2d ago",  isToday: false),
    ActivityItem(type: .earnings,   actor: "NVDA",          detail: "crushed earnings — you hold",            value: "+8% AH", timeAgo: "3d ago",  isToday: false),
    ActivityItem(type: .friendPost, actor: "Nina H.",       detail: "posted about her SMCI trade",            value: nil,      timeAgo: "3d ago",  isToday: false),
]
