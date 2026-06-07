import SwiftUI

struct ForYouView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void
    @State private var selectedGainer: WorldGainer? = nil
    @State private var showPremium = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("For You ✨")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Theme.text)
                    .padding(.horizontal, 16)
                    .padding(.top, 52)
                    .padding(.bottom, 14)

                // Alert strip
                HStack(spacing: 10) {
                    Text("🔔 3 of your stocks report earnings this week")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(hex: "#92400E"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("View") {}
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#D97706"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [Color(hex: "#FFFBEB"), Color(hex: "#FEF3C7")], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#FDE68A"), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 14)
                .padding(.bottom, 10)

                hotOnSTALKSection()
                missedOpportunitiesSection()

                sectionLabel("🌍 Today's Top Portfolios · Copy & Invest")
                worldGainersSection()

                sectionLabel("📊 Earnings · Beat / Miss / Guidance")
                earningsSection()

                sectionLabel("📈 Analyst Moves")
                analystSection()

                sectionLabel("🏦 Insider Buys")
                insiderSection()

                sectionLabel("🇺🇸 Trump Watch")
                trumpSection()

                sectionLabel("🐋 Whale Alerts · Options Flow")
                PremiumLockedCard(icon: "🐋", title: "Whale Alerts", subtitle: "See where the big money is flowing in real-time.") { showPremium = true }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 9)

                sectionLabel("📉 Short Squeeze Radar")
                PremiumLockedCard(icon: "📉", title: "Short Squeeze Radar", subtitle: "Spot the next GME before it happens. Upgrade to Pro.") { showPremium = true }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 9)

                Color.clear.frame(height: 100)
            }
        }
        .background(Theme.bg)
        .sheet(item: $selectedGainer) { gainer in
            CopyPortfolioSheet(gainer: gainer)
        }
        .sheet(isPresented: $showPremium) {
            PremiumSheet()
        }
    }

    // MARK: - Sections

    func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Theme.text3)
            .textCase(.uppercase)
            .kerning(1.3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
            .padding(.top, 22)
    }

    func hotOnSTALKSection() -> some View {
        let hot: [(ticker: String, adds: Int, pct: Double, icon: String)] = [
            ("NVDA", 1243, 4.2, "🔥"),
            ("TSLA", 891,  2.1, "⚡"),
            ("META", 734, -0.8, "📱"),
            ("PLTR", 612,  6.7, "🤖"),
            ("AAPL", 504,  0.9, "🍎"),
        ]
        return VStack(alignment: .leading, spacing: 0) {
            sectionLabel("🔥 Hot on STALK This Week")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(hot, id: \.ticker) { item in
                        Button { onTicker(item.ticker) } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(item.icon).font(.system(size: 20))
                                    Spacer()
                                    Text(item.pct.fmtPct())
                                        .font(.system(size: 13, weight: .black))
                                        .foregroundStyle(item.pct >= 0 ? Theme.gain : Theme.loss)
                                }
                                Text(item.ticker)
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundStyle(Theme.text)
                                Text("\(item.adds.formatted()) users added")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.text3)
                                Text("this week")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Theme.accent)
                            }
                            .padding(14)
                            .frame(width: 130)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
            }
        }
    }

    func missedOpportunitiesSection() -> some View {
        let missed: [(ticker: String, gain: Double, days: Int, desc: String)] = [
            ("NVDA", 247, 180, "AI chip supercycle — up 247% in 6 months"),
            ("PLTR", 89,  90,  "Government AI contracts drove massive run"),
            ("ARM",  72,  60,  "IPO pop + AI tailwind since September"),
            ("SMCI", 61,  45,  "Data center build-out beneficiary"),
        ]
        return VStack(alignment: .leading, spacing: 0) {
            sectionLabel("😬 Missed Opportunities")
            VStack(spacing: 9) {
                ForEach(missed, id: \.ticker) { item in
                    Button { onTicker(item.ticker) } label: {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(item.ticker)
                                        .font(.system(size: 15, weight: .black))
                                        .foregroundStyle(Theme.text)
                                    Text("not in your portfolio")
                                        .font(.system(size: 10))
                                        .foregroundStyle(Theme.text3)
                                }
                                Text(item.desc)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.text2)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("+\(String(format: "%.0f", item.gain))%")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundStyle(Theme.gain)
                                Text("\(item.days)d")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.text3)
                            }
                        }
                        .padding(14)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Theme.gain.opacity(0.25), lineWidth: 1)
                        )
                        .overlay(alignment: .leading) {
                            Rectangle().fill(Theme.gain).frame(width: 3)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                .padding(.vertical, 6)
                        }
                        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
        }
    }

    func worldGainersSection() -> some View {
        VStack(spacing: 10) {
            ForEach(Array(WORLD_GAINERS.enumerated()), id: \.element.id) { i, gainer in
                Button { selectedGainer = gainer } label: {
                    HStack(spacing: 12) {
                        Text("#\(gainer.rank)")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Theme.text3)
                            .frame(width: 20)

                        Circle()
                            .fill(gainer.color)
                            .frame(width: 42, height: 42)
                            .overlay(
                                Text(gainer.initial)
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundStyle(.white)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(gainer.name) \(gainer.flag)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text(gainer.holdings.prefix(3).map(\.ticker).joined(separator: " · "))
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.text3)
                            Text("\(gainer.followers.formatted()) followers · \(gainer.value)")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("+\(String(format: "%.1f", gainer.todayReturn))%")
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(Theme.gain)
                            Text("YTD +\(String(format: "%.0f", gainer.ytd))%")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                            Text("Copy →")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .padding(14)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
    }

    func earningsSection() -> some View {
        VStack(spacing: 10) {
            ForEach(EARNINGS) { e in
                EarningsCard(report: e, onTicker: onTicker)
            }
        }
        .padding(.horizontal, 14)
    }

    func analystSection() -> some View {
        VStack(spacing: 8) {
            ForEach(ANALYST_MOVES) { move in
                Button { onTicker(move.ticker) } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(move.firm)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text(move.action + " from " + move.fromRating)
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.text3)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(move.ticker)
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(Theme.accent)
                            Text(move.priceTarget)
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.text3)
                            Text(move.changeLabel)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(move.isUpgrade ? Theme.gain : Theme.loss)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 13)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
                    .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
    }

    func insiderSection() -> some View {
        VStack(spacing: 9) {
            ForEach(INSIDER_BUYS) { buy in
                Button { onTicker(buy.ticker) } label: {
                    VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 4) {
                                    Text(buy.name)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(Theme.text)
                                    Text(buy.role)
                                        .font(.system(size: 11))
                                        .foregroundStyle(Theme.text3)
                                }
                                HStack(spacing: 5) {
                                    Text(buy.company)
                                        .font(.system(size: 11))
                                        .foregroundStyle(Theme.text3)
                                    Text(buy.ticker)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Theme.accent)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 1)
                                        .background(Color(hex: "#EDEDFF"))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(buy.value)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                Text(buy.shares + " shares")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.text3)
                            }
                        }
                        .padding(.bottom, 9)

                        Divider()

                        HStack {
                            Text(buy.sentiment)
                                .font(.system(size: 12, weight: .bold))
                            Spacer()
                            Text(buy.date)
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                        .padding(.top, 9)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
                    .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
    }

    func trumpSection() -> some View {
        VStack(spacing: 9) {
            ForEach(POLITICAL_TWEETS) { tweet in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "#E63946"), Color(hex: "#C1121F")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 38, height: 38)
                            .overlay(Text("T").font(.system(size: 16, weight: .black)).foregroundStyle(.white))

                        VStack(alignment: .leading, spacing: 1) {
                            Text(tweet.name)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text("\(tweet.handle) · \(tweet.time)")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.text3)
                        }
                    }

                    Text("\"\(tweet.text)\"")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.text2)
                        .italic()
                        .lineSpacing(2)

                    HStack {
                        HStack(spacing: 5) {
                            ForEach(tweet.tickers, id: \.self) { t in
                                Button { onTicker(t) } label: {
                                    Text(t)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Theme.accent)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2)
                                        .background(Color(hex: "#EDEDFF"))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        Spacer()
                        Text(tweet.impact.fmtPct())
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(tweet.impact >= 0 ? Theme.gain : Theme.loss)
                    }
                }
                .padding(14)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Theme.border, lineWidth: 1)
                )
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color(hex: "#E63946"))
                        .frame(width: 3)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .padding(.vertical, 4)
                }
                .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                .padding(.horizontal, 14)
            }
        }
    }
}

// MARK: - Earnings Card

struct EarningsCard: View {
    let report: EarningsReport
    let onTicker: (String) -> Void

    var body: some View {
        Button { onTicker(report.ticker) } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(report.company)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.text)
                        Text(report.ticker)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.accent)
                    }
                    Spacer()
                    Text(report.time)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.text3)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Theme.bg2)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                // Grid
                HStack(spacing: 1) {
                    earningsCell("EPS", report.eps)
                    earningsCell("Revenue", report.rev)
                    guidanceCell()
                }
                .background(Theme.border)
                .clipShape(RoundedRectangle(cornerRadius: 0))

                // Reactions
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(report.reactions, id: \.self) { r in
                            Text(r)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.text2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Theme.bg)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border, lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
        }
        .buttonStyle(.plain)
    }

    func earningsCell(_ label: String, _ cell: EarningsReport.EarningsCell) -> some View {
        let hasBeat = cell.actual != nil
        return VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(0.8)
            Text(hasBeat ? cell.actual! : cell.estimate)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.text)
            if hasBeat, let beat = cell.beat, let surprise = cell.surprise {
                Text("\(beat ? "✓ Beat " : "✗ Miss ")\(surprise)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(beat ? Theme.gain : Theme.loss)
            } else {
                Text("Est.")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.text3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(hasBeat ? (cell.beat == true ? Theme.gainBg : Theme.lossBg) : Theme.card)
    }

    func guidanceCell() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Guidance")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(0.8)
            Text(report.guidanceText)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.text)
            Text(report.guidance == "raised" ? "⬆ Raised" : report.guidance == "lowered" ? "⬇ Lowered" : "➡ Met")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(report.guidance == "raised" ? Theme.gain : report.guidance == "lowered" ? Theme.loss : Theme.gold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Theme.card)
    }
}

// MARK: - Premium Locked

struct PremiumLockedCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let onUnlock: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 14).fill(Theme.bg2).frame(height: 54)
                }
            }
            .blur(radius: 6)

            VStack(spacing: 8) {
                Text(icon).font(.system(size: 28))
                Text(title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(Theme.text)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text3)
                    .multilineTextAlignment(.center)
                Button("Unlock with Pro") {
                    onUnlock()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(18)
            .background(.white.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Theme.accent.opacity(0.18), radius: 16, y: 4)
            .padding(20)
        }
    }
}

// MARK: - Copy Portfolio Sheet

struct CopyPortfolioSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    let gainer: WorldGainer
    @State private var amount: String = "1000"

    var ytdPct: Double { gainer.ytd / 100 }
    var projectedReturn: Double { (Double(amount) ?? 0) * ytdPct }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack(spacing: 14) {
                        Circle()
                            .fill(gainer.color)
                            .frame(width: 56, height: 56)
                            .overlay(Text(gainer.initial).font(.system(size: 22, weight: .black)).foregroundStyle(.white))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(gainer.name) \(gainer.flag)")
                                .font(.system(size: 19, weight: .black))
                                .foregroundStyle(Theme.text)
                            Text(gainer.bio)
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.text3)
                        }
                    }

                    // Stats
                    HStack(spacing: 8) {
                        statCard("+\(String(format: "%.1f", gainer.todayReturn))%", "Today", Theme.gainBg)
                        statCard("+\(String(format: "%.0f", gainer.ytd))%", "YTD", Color(hex: "#EDEDFF"))
                        statCard(gainer.followers.formatted(), "Followers", Theme.bg2)
                    }

                    // Holdings
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Portfolio Value")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.text3)
                                .textCase(.uppercase)
                            Spacer()
                            Text(gainer.value)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.accent)
                        }
                        ForEach(gainer.holdings, id: \.ticker) { h in
                            HStack(spacing: 10) {
                                Text(h.ticker)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(Theme.text)
                                    .frame(width: 48, alignment: .leading)
                                GeometryReader { geo in
                                    RoundedRectangle(cornerRadius: 3).fill(Theme.bg2)
                                        .overlay(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(Theme.accentGradient)
                                                .frame(width: geo.size.width * CGFloat(h.weight) / 100)
                                        }
                                }
                                .frame(height: 6)
                                Text("\(h.weight)%")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Theme.accent)
                                    .frame(width: 36, alignment: .trailing)
                            }
                        }
                    }
                    .padding(14)
                    .background(Theme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Amount input
                    ZStack {
                        LinearGradient(colors: [Color(hex: "#1E1B4B"), Color(hex: "#2D2B6B")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("💰 How much do you want to invest?")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white.opacity(0.7))
                                .textCase(.uppercase)

                            HStack(spacing: 8) {
                                ForEach(["100", "500", "1000", "5000"], id: \.self) { v in
                                    let n = Double(v) ?? 0
                                    let label = n >= 1000 ? "$\(Int(n/1000))K" : "$\(Int(n))"
                                    Button(label) {
                                        amount = v
                                    }
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(.white.opacity(0.1))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.15), lineWidth: 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }

                            HStack(spacing: 8) {
                                Text("$")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.6))
                                TextField("1000", text: $amount)
                                    #if os(iOS)
                                    .keyboardType(.numberPad)
                                    #endif
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                    .tint(.white)
                            }
                            .padding(12)
                            .background(.white.opacity(0.1))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.15), lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                            Text("Funds distributed proportionally across holdings")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(18)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Projected return
                    HStack {
                        Text("📈 If YTD performance repeats")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.gain)
                        Spacer()
                        Text("+$\(Int(projectedReturn).formatted())")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(Theme.gain)
                    }
                    .padding(12)
                    .background(Theme.gainBg)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Button {
                        copyPortfolio()
                        dismiss()
                    } label: {
                        Text("🚀 Copy This Portfolio")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Theme.accentGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    Button("Cancel") { dismiss() }
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.text3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .padding(18)
            }
            .background(Theme.bg)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    func statCard(_ value: String, _ label: String, _ bg: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Theme.text)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    func copyPortfolio() {
        let amt = Double(amount) ?? 0
        Task {
            for h in gainer.holdings {
                let invest = amt * Double(h.weight) / 100
                guard invest > 5, !appState.positions.contains(where: { $0.ticker == h.ticker }) else { continue }
                if let q = try? await QuoteService.fetchQuote(h.ticker) {
                    appState.quotes[h.ticker] = q
                    let shares = invest / q.price
                    appState.addPosition(Position(ticker: h.ticker, shares: shares, avgCost: q.price))
                }
            }
            await appState.refreshPortfolio()
        }
    }
}

// MARK: - Premium Sheet

struct PremiumSheet: View {
    @Environment(\.dismiss) var dismiss

    let features: [(String, String, String)] = [
        ("🐋", "Whale Alerts",         "See $1M+ options trades in real-time"),
        ("🔔", "Price Alerts",         "Get notified at your target price"),
        ("🤖", "AI Stock Analysis",    "GPT-powered buy/sell signals"),
        ("📉", "Short Squeeze Radar",  "Spot the next GME before it happens"),
        ("📊", "Full Earnings Analysis","Beat/miss history, guidance trends"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("STALK Pro 🚀")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(Theme.text)
                .padding(.top, 28)

            Text("Unlock everything. Trade smarter.")
                .font(.system(size: 14))
                .foregroundStyle(Theme.text3)
                .padding(.bottom, 22)

            VStack(spacing: 0) {
                ForEach(features, id: \.0) { icon, title, sub in
                    HStack(spacing: 12) {
                        Text(icon).font(.system(size: 20)).frame(width: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title).font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.text)
                            Text(sub).font(.system(size: 12)).foregroundStyle(Theme.text3)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    Divider()
                }
            }
            .padding(.horizontal, 22)

            VStack(spacing: 4) {
                Text("$9.99/mo")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(Theme.accent)
                Text("Cancel anytime · 7-day free trial")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text3)
            }
            .padding(.vertical, 18)

            Button {
                dismiss()
            } label: {
                Text("Start Free Trial →")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Theme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal, 22)

            Button("Maybe later") { dismiss() }
                .font(.system(size: 14))
                .foregroundStyle(Theme.text3)
                .padding(12)
        }
        .background(Theme.card)
    }
}
