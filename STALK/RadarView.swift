import SwiftUI

// MARK: - Radar — Premium Intelligence Hub
// Free tier: top 2 rows of each section, 24h-delayed framing.
// Pro tier: everything, real-time framing, no locks.

// MARK: Mock data models

struct SqueezeCandidate: Identifiable {
    let id = UUID()
    let ticker: String
    let shortInterest: Double   // % of float
    let daysToCover: Double
    let borrowFee: Double       // %
    let squeezeScore: Int       // 0–100
}

struct WhaleAlert: Identifiable {
    let id = UUID()
    let ticker: String
    let side: String            // BUY / SELL
    let amount: Double          // dollars
    let venue: String
    let timeAgo: String
}

struct InsiderTrade: Identifiable {
    let id = UUID()
    let ticker: String
    let insider: String
    let role: String
    let side: String            // BUY / SELL
    let value: Double
    let date: String
    let isCluster: Bool         // 3+ insiders same window
}

struct CongressTrade: Identifiable {
    let id = UUID()
    let politician: String
    let chamber: String         // House / Senate
    let party: String           // D / R
    let ticker: String
    let side: String
    let amountRange: String
    let tradeDate: String
    let disclosedDaysLater: Int
}

struct HedgeFundMove: Identifiable {
    let id = UUID()
    let fund: String
    let manager: String
    let ticker: String
    let action: String          // NEW / ADD / TRIM / EXIT
    let positionValue: Double
    let changePct: Double       // vs prior quarter
}

struct DarkPoolPrint: Identifiable {
    let id = UUID()
    let ticker: String
    let shares: Double
    let price: Double
    let pctOfDailyVol: Double
    let timeAgo: String
}

struct OptionsFlow: Identifiable {
    let id = UUID()
    let ticker: String
    let kind: String            // SWEEP / BLOCK
    let side: String            // CALL / PUT
    let strike: Double
    let expiry: String
    let premium: Double
    let timeAgo: String
}

// MARK: Mock data

private let SQUEEZE_CANDIDATES: [SqueezeCandidate] = [
    SqueezeCandidate(ticker: "GME",  shortInterest: 24.2, daysToCover: 6.8, borrowFee: 18.4, squeezeScore: 91),
    SqueezeCandidate(ticker: "CVNA", shortInterest: 31.8, daysToCover: 4.2, borrowFee: 12.1, squeezeScore: 86),
    SqueezeCandidate(ticker: "BYND", shortInterest: 38.4, daysToCover: 8.1, borrowFee: 42.6, squeezeScore: 82),
    SqueezeCandidate(ticker: "UPST", shortInterest: 28.1, daysToCover: 3.9, borrowFee: 9.8,  squeezeScore: 74),
    SqueezeCandidate(ticker: "MSTR", shortInterest: 22.6, daysToCover: 2.8, borrowFee: 7.2,  squeezeScore: 68),
    SqueezeCandidate(ticker: "RIVN", shortInterest: 19.4, daysToCover: 3.1, borrowFee: 6.4,  squeezeScore: 61),
]

private let WHALE_ALERTS: [WhaleAlert] = [
    WhaleAlert(ticker: "NVDA", side: "BUY",  amount: 340e6, venue: "NYSE Block",  timeAgo: "28m"),
    WhaleAlert(ticker: "TSLA", side: "SELL", amount: 220e6, venue: "Dark Pool",   timeAgo: "1h"),
    WhaleAlert(ticker: "AAPL", side: "BUY",  amount: 185e6, venue: "NASDAQ",      timeAgo: "2h"),
    WhaleAlert(ticker: "META", side: "BUY",  amount: 142e6, venue: "Dark Pool",   timeAgo: "3h"),
    WhaleAlert(ticker: "SPY",  side: "SELL", amount: 480e6, venue: "NYSE Block",  timeAgo: "4h"),
    WhaleAlert(ticker: "AMZN", side: "BUY",  amount: 96e6,  venue: "IEX",         timeAgo: "5h"),
]

private let INSIDER_TRADES: [InsiderTrade] = [
    InsiderTrade(ticker: "NVDA", insider: "Colette Kress",   role: "CFO",       side: "SELL", value: 12.4e6, date: "Jul 17", isCluster: false),
    InsiderTrade(ticker: "OXY",  insider: "Warren Buffett",  role: "10% Owner", side: "BUY",  value: 246e6,  date: "Jul 16", isCluster: false),
    InsiderTrade(ticker: "SOFI", insider: "Anthony Noto",    role: "CEO",       side: "BUY",  value: 1.2e6,  date: "Jul 15", isCluster: true),
    InsiderTrade(ticker: "INTC", insider: "Lip-Bu Tan",      role: "CEO",       side: "BUY",  value: 4.8e6,  date: "Jul 14", isCluster: true),
    InsiderTrade(ticker: "TSLA", insider: "Kimbal Musk",     role: "Director",  side: "SELL", value: 8.2e6,  date: "Jul 11", isCluster: false),
    InsiderTrade(ticker: "PLTR", insider: "Alex Karp",       role: "CEO",       side: "SELL", value: 22.6e6, date: "Jul 10", isCluster: false),
]

private let CONGRESS_TRADES: [CongressTrade] = [
    CongressTrade(politician: "Nancy Pelosi",      chamber: "House",  party: "D", ticker: "NVDA", side: "BUY",  amountRange: "$1M–5M",     tradeDate: "Jul 14", disclosedDaysLater: 4),
    CongressTrade(politician: "Dan Crenshaw",      chamber: "House",  party: "R", ticker: "XOM",  side: "BUY",  amountRange: "$15K–50K",   tradeDate: "Jul 12", disclosedDaysLater: 6),
    CongressTrade(politician: "Tommy Tuberville",  chamber: "Senate", party: "R", ticker: "AAPL", side: "SELL", amountRange: "$50K–100K",  tradeDate: "Jul 10", disclosedDaysLater: 8),
    CongressTrade(politician: "Ro Khanna",         chamber: "House",  party: "D", ticker: "MSFT", side: "BUY",  amountRange: "$100K–250K", tradeDate: "Jul 8",  disclosedDaysLater: 5),
    CongressTrade(politician: "Mark Green",        chamber: "House",  party: "R", ticker: "LMT",  side: "BUY",  amountRange: "$250K–500K", tradeDate: "Jul 3",  disclosedDaysLater: 11),
    CongressTrade(politician: "Sheldon Whitehouse", chamber: "Senate", party: "D", ticker: "TSLA", side: "SELL", amountRange: "$15K–50K",  tradeDate: "Jun 30", disclosedDaysLater: 14),
]

private let HEDGE_FUND_MOVES: [HedgeFundMove] = [
    HedgeFundMove(fund: "Berkshire Hathaway", manager: "Warren Buffett",  ticker: "OXY",  action: "ADD",  positionValue: 14.2e9, changePct: 8.4),
    HedgeFundMove(fund: "Scion Asset Mgmt",   manager: "Michael Burry",   ticker: "BABA", action: "NEW",  positionValue: 182e6,  changePct: 100),
    HedgeFundMove(fund: "Pershing Square",    manager: "Bill Ackman",     ticker: "GOOGL", action: "ADD", positionValue: 2.1e9,  changePct: 12.6),
    HedgeFundMove(fund: "Bridgewater",        manager: "Ray Dalio (fdr)", ticker: "SPY",  action: "TRIM", positionValue: 890e6,  changePct: -22.4),
    HedgeFundMove(fund: "Appaloosa",          manager: "David Tepper",    ticker: "NVDA", action: "TRIM", positionValue: 420e6,  changePct: -31.2),
    HedgeFundMove(fund: "Third Point",        manager: "Dan Loeb",        ticker: "AMZN", action: "NEW",  positionValue: 640e6,  changePct: 100),
]

private let DARK_POOL_PRINTS: [DarkPoolPrint] = [
    DarkPoolPrint(ticker: "NVDA", shares: 2.4e6, price: 171.80, pctOfDailyVol: 4.2, timeAgo: "18m"),
    DarkPoolPrint(ticker: "AAPL", shares: 1.8e6, price: 213.95, pctOfDailyVol: 3.1, timeAgo: "42m"),
    DarkPoolPrint(ticker: "SPY",  shares: 3.2e6, price: 628.40, pctOfDailyVol: 5.8, timeAgo: "1h"),
    DarkPoolPrint(ticker: "META", shares: 640e3, price: 641.20, pctOfDailyVol: 4.6, timeAgo: "2h"),
    DarkPoolPrint(ticker: "TSLA", shares: 1.1e6, price: 249.10, pctOfDailyVol: 2.4, timeAgo: "3h"),
]

private let OPTIONS_FLOW: [OptionsFlow] = [
    OptionsFlow(ticker: "NVDA", kind: "SWEEP", side: "CALL", strike: 180, expiry: "Aug 15", premium: 4.8e6, timeAgo: "12m"),
    OptionsFlow(ticker: "TSLA", kind: "SWEEP", side: "PUT",  strike: 230, expiry: "Aug 1",  premium: 2.2e6, timeAgo: "34m"),
    OptionsFlow(ticker: "SPY",  kind: "BLOCK", side: "PUT",  strike: 610, expiry: "Jul 31", premium: 8.4e6, timeAgo: "1h"),
    OptionsFlow(ticker: "AMD",  kind: "SWEEP", side: "CALL", strike: 170, expiry: "Sep 19", premium: 1.6e6, timeAgo: "2h"),
    OptionsFlow(ticker: "META", kind: "BLOCK", side: "CALL", strike: 680, expiry: "Aug 15", premium: 3.1e6, timeAgo: "2h"),
]

// MARK: - Radar View

struct RadarView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void
    @State private var showPremium = false

    var isPro: Bool { appState.settings.isPro }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                radarHeader

                if !isPro {
                    freeVsProCard
                        .padding(.horizontal, 14)
                        .padding(.bottom, 20)
                }

                radarSection(title: "Short Squeeze Radar", icon: "chart.line.downtrend.xyaxis",
                             subtitle: "High short interest + hard to borrow") {
                    squeezeRows
                }
                radarSection(title: "Whale Alerts", icon: "waveform.path.ecg",
                             subtitle: "Block trades over $50M") {
                    whaleRows
                }
                radarSection(title: "Insider Activity", icon: "person.badge.key",
                             subtitle: "Officer & director buys and sells (Form 4)") {
                    insiderRows
                }
                radarSection(title: "Congress Trades", icon: "building.columns",
                             subtitle: "House & Senate disclosed trades (STOCK Act)") {
                    congressRows
                }
                radarSection(title: "Hedge Fund Moves", icon: "chart.pie",
                             subtitle: "13F position changes by top funds") {
                    hedgeFundRows
                }
                radarSection(title: "Dark Pool Prints", icon: "eye.slash",
                             subtitle: "Large off-exchange blocks") {
                    darkPoolRows
                }
                radarSection(title: "Unusual Options Flow", icon: "bolt.horizontal",
                             subtitle: "Premium sweeps & blocks") {
                    optionsFlowRows
                }

                Color.clear.frame(height: 100)
            }
        }
        .background(Theme.bg)
        .sheet(isPresented: $showPremium) {
            PremiumSheet()
        }
    }

    // MARK: Header

    var radarHeader: some View {
        HStack(spacing: 10) {
            Text("RADAR")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(Theme.text)
                .kerning(0.5)
            Text("PRO")
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(isPro ? .white : Color(hex: "#06B6D4"))
                .kerning(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isPro ? Color(hex: "#06B6D4") : Color(hex: "#06B6D4").opacity(0.12))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color(hex: "#06B6D4").opacity(isPro ? 0 : 0.4), lineWidth: 1))
            Spacer()
            HStack(spacing: 5) {
                Circle().fill(isPro ? Theme.gain : Theme.gold).frame(width: 7, height: 7)
                Text(isPro ? "Real-time" : "Delayed 24h")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isPro ? Theme.gain : Theme.gold)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background((isPro ? Theme.gain : Theme.gold).opacity(0.10))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.top, 52)
        .padding(.bottom, 16)
    }

    // MARK: Free vs Pro comparison

    var freeVsProCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("FREE vs PRO")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Theme.text)
                    .kerning(1.5)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            let rows: [(String, String, String)] = [
                ("Radar data",        "Top 2 rows",   "Everything"),
                ("Data freshness",    "24h delayed",  "Real-time"),
                ("Squeeze scores",    "—",            "Full ranking"),
                ("Congress trades",   "Preview",      "All + alerts"),
                ("Hedge fund 13Fs",   "Preview",      "Full history"),
                ("Options flow",      "—",            "Live sweeps"),
                ("AI chat messages",  "3 / day",      "Unlimited"),
                ("Price alerts",      "3 tickers",    "Unlimited"),
            ]
            ForEach(Array(rows.enumerated()), id: \.offset) { i, row in
                HStack {
                    Text(row.0)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.text2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.1)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.text3)
                        .frame(width: 90, alignment: .trailing)
                    Text(row.2)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(hex: "#06B6D4"))
                        .frame(width: 96, alignment: .trailing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                if i < rows.count - 1 {
                    Rectangle().fill(Theme.border).frame(height: 0.5).padding(.leading, 16)
                }
            }

            Button { showPremium = true } label: {
                Text("Upgrade to Pro")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(16)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "#06B6D4").opacity(0.25), lineWidth: 1))
    }

    // MARK: Section scaffold with Pro gating

    @ViewBuilder
    func radarSection<Content: View>(title: String, icon: String, subtitle: String,
                                     @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(hex: "#06B6D4"))
                VStack(alignment: .leading, spacing: 1) {
                    Text(title.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(2)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.text4)
                }
                Spacer()
                if !isPro {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text4)
                }
            }
            .padding(.horizontal, 16)

            VStack(spacing: 0) {
                content()
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
            .padding(.horizontal, 14)
        }
        .padding(.bottom, 20)
    }

    // A row that blurs + locks when index >= 2 for free users
    @ViewBuilder
    func gated(_ index: Int, @ViewBuilder row: () -> some View) -> some View {
        if isPro || index < 2 {
            row()
        } else {
            row()
                .blur(radius: 5)
                .overlay(
                    Button { showPremium = true } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10, weight: .bold))
                            Text("PRO")
                                .font(.system(size: 10, weight: .black))
                                .kerning(1)
                        }
                        .foregroundStyle(Color(hex: "#06B6D4"))
                    }
                    .buttonStyle(.plain)
                )
        }
    }

    func rowDivider() -> some View {
        Rectangle().fill(Theme.border).frame(height: 0.5).padding(.leading, 16)
    }

    // MARK: Squeeze rows

    var squeezeRows: some View {
        ForEach(Array(SQUEEZE_CANDIDATES.enumerated()), id: \.element.id) { i, s in
            gated(i) {
                Button { onTicker(s.ticker) } label: {
                    HStack(spacing: 12) {
                        Text(s.ticker)
                            .font(.system(size: 13, weight: .black).monospaced())
                            .foregroundStyle(Theme.text)
                            .frame(width: 52, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SI \(String(format: "%.1f", s.shortInterest))% · DTC \(String(format: "%.1f", s.daysToCover))")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.text2)
                            Text("Borrow fee \(String(format: "%.1f", s.borrowFee))%")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .stroke(Theme.bg3, lineWidth: 4)
                                .frame(width: 34, height: 34)
                            Circle()
                                .trim(from: 0, to: CGFloat(s.squeezeScore) / 100)
                                .stroke(s.squeezeScore >= 80 ? Theme.loss : s.squeezeScore >= 65 ? Theme.gold : Theme.text3,
                                        style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 34, height: 34)
                            Text("\(s.squeezeScore)")
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(Theme.text)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            if i < SQUEEZE_CANDIDATES.count - 1 { rowDivider() }
        }
    }

    // MARK: Whale rows

    var whaleRows: some View {
        ForEach(Array(WHALE_ALERTS.enumerated()), id: \.element.id) { i, w in
            gated(i) {
                Button { onTicker(w.ticker) } label: {
                    HStack(spacing: 12) {
                        Text(w.side)
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(w.side == "BUY" ? Theme.gain : Theme.loss)
                            .frame(width: 34)
                            .padding(.vertical, 4)
                            .background((w.side == "BUY" ? Theme.gain : Theme.loss).opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        Text(w.ticker)
                            .font(.system(size: 13, weight: .black).monospaced())
                            .foregroundStyle(Theme.text)
                            .frame(width: 52, alignment: .leading)
                        Text(w.venue)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Theme.text3)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(w.amount.fmtCompact())
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Theme.text)
                                .monospacedDigit()
                            Text(w.timeAgo)
                                .font(.system(size: 9))
                                .foregroundStyle(Theme.text4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            if i < WHALE_ALERTS.count - 1 { rowDivider() }
        }
    }

    // MARK: Insider rows

    var insiderRows: some View {
        ForEach(Array(INSIDER_TRADES.enumerated()), id: \.element.id) { i, t in
            gated(i) {
                Button { onTicker(t.ticker) } label: {
                    HStack(spacing: 12) {
                        Text(t.side)
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(t.side == "BUY" ? Theme.gain : Theme.loss)
                            .frame(width: 34)
                            .padding(.vertical, 4)
                            .background((t.side == "BUY" ? Theme.gain : Theme.loss).opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(t.insider)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                if t.isCluster {
                                    Text("CLUSTER")
                                        .font(.system(size: 7, weight: .black))
                                        .foregroundStyle(Theme.gold)
                                        .padding(.horizontal, 5).padding(.vertical, 2)
                                        .background(Theme.goldBg)
                                        .clipShape(Capsule())
                                }
                            }
                            Text("\(t.role) · \(t.ticker) · \(t.date)")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                        Spacer()
                        Text(t.value.fmtCompact())
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(t.side == "BUY" ? Theme.gain : Theme.loss)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            if i < INSIDER_TRADES.count - 1 { rowDivider() }
        }
    }

    // MARK: Congress rows

    var congressRows: some View {
        ForEach(Array(CONGRESS_TRADES.enumerated()), id: \.element.id) { i, t in
            gated(i) {
                Button { onTicker(t.ticker) } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill((t.party == "D" ? Color(hex: "#2563EB") : Color(hex: "#DC2626")).opacity(0.15))
                                .frame(width: 32, height: 32)
                            Text(t.party)
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(t.party == "D" ? Color(hex: "#2563EB") : Color(hex: "#DC2626"))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(t.politician)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text("\(t.chamber) · \(t.tradeDate) · disclosed +\(t.disclosedDaysLater)d")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 5) {
                                Text(t.side)
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundStyle(t.side == "BUY" ? Theme.gain : Theme.loss)
                                Text(t.ticker)
                                    .font(.system(size: 12, weight: .black).monospaced())
                                    .foregroundStyle(Theme.text)
                            }
                            Text(t.amountRange)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Theme.text3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            if i < CONGRESS_TRADES.count - 1 { rowDivider() }
        }
    }

    // MARK: Hedge fund rows

    var hedgeFundRows: some View {
        ForEach(Array(HEDGE_FUND_MOVES.enumerated()), id: \.element.id) { i, m in
            gated(i) {
                Button { onTicker(m.ticker) } label: {
                    HStack(spacing: 12) {
                        Text(m.action)
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(m.action == "NEW" || m.action == "ADD" ? Theme.gain : m.action == "EXIT" ? Theme.loss : Theme.gold)
                            .frame(width: 36)
                            .padding(.vertical, 4)
                            .background((m.action == "NEW" || m.action == "ADD" ? Theme.gain : m.action == "EXIT" ? Theme.loss : Theme.gold).opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(m.fund)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text("\(m.manager) · \(m.ticker)")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(m.positionValue.fmtCompact())
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Theme.text)
                                .monospacedDigit()
                            Text(m.action == "NEW" ? "new stake" : m.changePct.fmtPct() + " q/q")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(m.changePct >= 0 ? Theme.gain : Theme.loss)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            if i < HEDGE_FUND_MOVES.count - 1 { rowDivider() }
        }
    }

    // MARK: Dark pool rows

    var darkPoolRows: some View {
        ForEach(Array(DARK_POOL_PRINTS.enumerated()), id: \.element.id) { i, d in
            gated(i) {
                Button { onTicker(d.ticker) } label: {
                    HStack(spacing: 12) {
                        Text(d.ticker)
                            .font(.system(size: 13, weight: .black).monospaced())
                            .foregroundStyle(Theme.text)
                            .frame(width: 52, alignment: .leading)
                        Text("\(String(format: "%.1f", d.shares / 1e6))M sh @ \(d.price.fmtPrice())")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.text2)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("\(String(format: "%.1f", d.pctOfDailyVol))% of vol")
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(d.pctOfDailyVol >= 4 ? Theme.gold : Theme.text2)
                            Text(d.timeAgo)
                                .font(.system(size: 9))
                                .foregroundStyle(Theme.text4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            if i < DARK_POOL_PRINTS.count - 1 { rowDivider() }
        }
    }

    // MARK: Options flow rows

    var optionsFlowRows: some View {
        ForEach(Array(OPTIONS_FLOW.enumerated()), id: \.element.id) { i, o in
            gated(i) {
                Button { onTicker(o.ticker) } label: {
                    HStack(spacing: 12) {
                        Text(o.side)
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(o.side == "CALL" ? Theme.gain : Theme.loss)
                            .frame(width: 36)
                            .padding(.vertical, 4)
                            .background((o.side == "CALL" ? Theme.gain : Theme.loss).opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(o.ticker)
                                    .font(.system(size: 13, weight: .black).monospaced())
                                    .foregroundStyle(Theme.text)
                                Text(o.kind)
                                    .font(.system(size: 7, weight: .black))
                                    .foregroundStyle(Color(hex: "#06B6D4"))
                                    .padding(.horizontal, 5).padding(.vertical, 2)
                                    .background(Color(hex: "#06B6D4").opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            Text("$\(String(format: "%.0f", o.strike)) \(o.side.lowercased()) · \(o.expiry)")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(o.premium.fmtCompact())
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Theme.text)
                                .monospacedDigit()
                            Text(o.timeAgo)
                                .font(.system(size: 9))
                                .foregroundStyle(Theme.text4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            if i < OPTIONS_FLOW.count - 1 { rowDivider() }
        }
    }
}
