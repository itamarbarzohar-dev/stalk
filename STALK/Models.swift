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

// MARK: - Social / Feed

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
           time: "2h ago", likes: 47),
    Trader(id: 2, name: "Sara Kim", handle: "@saratrades", initial: "S", color: Color(hex: "#F472B6"),
           followers: 8903, following: 94,
           perf: TraderPerf(day: -0.3, sixMonth: 9.7, ytd: 14.2, allTime: 38.5),
           holdings: ["TSLA", "META", "AMZN"],
           text: "Trimmed my Tesla position after the run-up. Taking profits at $250 🎯",
           time: "4h ago", likes: 123),
    Trader(id: 3, name: "Mike R.", handle: "@mikevalue", initial: "M", color: Color(hex: "#FBBF24"),
           followers: 1204, following: 312,
           perf: TraderPerf(day: 0.8, sixMonth: 5.1, ytd: 7.3, allTime: 29.1),
           holdings: ["BRK-B", "JPM", "V", "KO"],
           text: "Old school value investing still works. Berkshire + JPM = sleep well at night 💤",
           time: "6h ago", likes: 34),
    Trader(id: 4, name: "Lena V.", handle: "@lena_invest", initial: "L", color: Color(hex: "#6EE7B7"),
           followers: 4512, following: 201,
           perf: TraderPerf(day: 2.1, sixMonth: 31.2, ytd: 41.5, allTime: 89.2),
           holdings: ["NVDA", "AMD", "SMCI", "AVGO"],
           text: "Semis are on fire this week. My portfolio is up 2% just today 🔥",
           time: "8h ago", likes: 211),
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

let INDEX_TICKERS = ["^GSPC", "QQQ", "^DJI", "^RUT"]
let INDEX_NAMES: [String: String] = [
    "^GSPC": "S&P 500", "QQQ": "NASDAQ 100", "^DJI": "Dow Jones", "^RUT": "Russell 2000",
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
