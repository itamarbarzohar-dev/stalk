import SwiftUI

// MARK: - FeedView

struct FeedView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void
    @State private var profileTrader: Trader? = nil
    @State private var storyTrader: Trader? = nil
    @State private var feedTab = "Trending"
    @State private var showCreatePost = false

    var totalValue: Double { appState.totalValue }
    var totalCost: Double { appState.totalCost }
    var allTimeRet: Double { totalCost > 0 ? ((totalValue - totalCost) / totalCost) * 100 : 0 }

    // MARK: Achievements

    var achievements: [AchievementBadge] {
        [
            AchievementBadge(icon: "📈", title: "First Gain",    unlocked: appState.totalValue > appState.totalCost),
            AchievementBadge(icon: "💼", title: "5 Stocks",      unlocked: appState.positions.count >= 5),
            AchievementBadge(icon: "🔥", title: "7-Day Streak",  unlocked: appState.streak >= 7),
            AchievementBadge(icon: "🏆", title: "New ATH",       unlocked: appState.totalValue >= appState.portfolioATH && appState.portfolioATH > 0),
            AchievementBadge(icon: "💎", title: "Diamond Hands", unlocked: appState.positions.contains { $0.avgCost > 0 }),
            AchievementBadge(icon: "🤖", title: "AI User",       unlocked: appState.settings.aiMessagesUsed > 0),
            AchievementBadge(icon: "⭐", title: "STALK Pro",     unlocked: appState.settings.isPro),
        ]
    }

    var feedTraders: [Trader] {
        switch feedTab {
        case "Following":
            return FEED_TRADERS.filter { appState.followed.contains($0.id) }
        case "Friends":
            return Array(FEED_TRADERS.prefix(4))
        default: // Trending
            return FEED_TRADERS.sorted { $0.todayPct > $1.todayPct }
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 0) {

                    // ── Navigation Header ───────────────────────────────────
                    feedHeader

                    // ── Stories Row ─────────────────────────────────────────
                    StoriesRow(
                        appState: appState,
                        onStoryTap: { trader in storyTrader = trader }
                    )
                    .padding(.top, 4)

                    // ── Streak Banner ───────────────────────────────────────
                    if appState.streak >= 1 {
                        HStack(spacing: 10) {
                            Text("🔥")
                                .font(.system(size: 28))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(appState.streak)-day streak")
                                    .font(.system(size: 15, weight: .black))
                                    .foregroundStyle(Theme.text)
                                Text("You've checked STALK \(appState.streak) days in a row. Keep it up!")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.text2)
                            }
                            Spacer()
                            Text("+\(appState.streak * 5) XP")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.gold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Theme.gold.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .padding(14)
                        .background(LinearGradient(
                            colors: [Color(hex: "#F97316").opacity(0.12), Color(hex: "#EA580C").opacity(0.06)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F97316").opacity(0.25), lineWidth: 1))
                        .padding(.horizontal, 14)
                        .padding(.top, 12)
                    }

                    // ── Achievement Badges ──────────────────────────────────
                    AchievementsRow(badges: achievements)
                        .padding(.top, 10)
                        .padding(.bottom, 4)

                    // ── My Performance ──────────────────────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        Text("My Performance")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.text3)
                            .textCase(.uppercase)
                            .kerning(1.3)
                            .padding(.bottom, 12)

                        let sixM = allTimeRet * 0.6
                        let ytd = allTimeRet * 0.8
                        let dayPct = appState.todayPnlPct

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
                            perfItem("Today", dayPct)
                            perfItem("6 Months", sixM)
                            perfItem("YTD", ytd)
                            perfItem("All Time", allTimeRet)
                        }
                    }
                    .padding(16)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border, lineWidth: 1))
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)

                    // ── Holdings Strip ──────────────────────────────────────
                    if !appState.positions.isEmpty {
                        holdingsStrip()
                            .padding(.horizontal, 14)
                            .padding(.bottom, 12)
                    }

                    Divider().padding(.vertical, 4)

                    // ── Leaderboard ─────────────────────────────────────────
                    LeaderboardSection()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 16)

                    Divider().padding(.vertical, 4)

                    // ── Feed section label ──────────────────────────────────
                    HStack {
                        Text(feedTab)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.text3)
                            .textCase(.uppercase)
                            .kerning(1.3)
                        Spacer()
                        Text("\(appState.userPosts.count + feedTraders.count) posts")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.text4)
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)

                    // ── My Posts ─────────────────────────────────────────────
                    if !appState.userPosts.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(appState.userPosts) { post in
                                MyPostCard(post: post, appState: appState, onTicker: onTicker)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                    }

                    // ── Post Cards V2 ───────────────────────────────────────
                    if feedTraders.isEmpty && appState.userPosts.isEmpty {
                        VStack(spacing: 12) {
                            Text("👀")
                                .font(.system(size: 40))
                            Text("No posts yet")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.text2)
                            Text("Follow some traders to see their posts here.")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.text3)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 48)
                        .frame(maxWidth: .infinity)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(Array(feedTraders.enumerated()), id: \.element.id) { i, trader in
                                TraderPostCardV2(trader: trader, onTicker: onTicker)
                                    .staggerEntrance(index: i)
                            }
                        }
                        .padding(.horizontal, 14)
                    }

                    Color.clear.frame(height: 100)
                }
            }
            .background(Theme.bg)

            // ── Floating Compose FAB ────────────────────────────────────
            Button { showCreatePost = true } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Theme.accentGradient)
                    .clipShape(Circle())
                    .shadow(color: Theme.accent.opacity(0.4), radius: 12, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView().environment(appState)
        }
        .sheet(item: $profileTrader) { trader in
            TraderProfileView(trader: trader, onTicker: onTicker)
        }
        .sheet(item: $storyTrader) { trader in
            TraderProfileView(trader: trader, onTicker: onTicker)
        }
    }

    // MARK: - Navigation Header

    var feedHeader: some View {
        VStack(spacing: 12) {
            // Line 1: Title + Bell
            HStack {
                Text("Feed")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Theme.text)
                Spacer()
                Button { } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.text2)
                        .frame(width: 40, height: 40)
                        .background(Theme.bg3)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            // Line 2: Pill segmented control
            HStack(spacing: 0) {
                ForEach(["Friends", "Trending", "Following"], id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { feedTab = tab }
                    } label: {
                        Text(tab)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(feedTab == tab ? .white : Theme.text3)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(feedTab == tab ? Theme.accent : Color.clear)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(3)
            .background(Theme.bg3)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 18)
        .padding(.top, 56)
        .padding(.bottom, 14)
    }

    // MARK: - Helper Views

    func perfItem(_ label: String, _ value: Double) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(0.5)
            Text(value == 0 ? "—" : "\(value >= 0 ? "+" : "")\(String(format: "%.1f", value))%")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(value == 0 ? Theme.text3 : value >= 0 ? Theme.gain : Theme.loss)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(Theme.bg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    func holdingsStrip() -> some View {
        let tv = appState.totalValue
        return VStack(alignment: .leading, spacing: 10) {
            Text("My Holdings Allocation")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(1.3)

            ForEach(Array(appState.positions.enumerated()), id: \.element.id) { i, p in
                let price = appState.quotes[p.ticker]?.price ?? p.avgCost
                let val = price * p.shares
                let pct = tv > 0 ? val / tv : 0

                HStack(spacing: 10) {
                    Text(p.ticker)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.text)
                        .frame(width: 50, alignment: .leading)

                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Theme.bg2)
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(LinearGradient(colors: [Theme.accent, Color(hex: "#A78BFA")], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * CGFloat(pct))
                            }
                    }
                    .frame(height: 5)

                    Text("\(Int(pct * 100))%")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.text3)
                        .frame(width: 32, alignment: .trailing)
                }
            }
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}

// MARK: - TraderPostCardV2

struct TraderPostCardV2: View {
    let trader: Trader
    let onTicker: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header row
            HStack(spacing: 10) {
                Circle()
                    .fill(LinearGradient(
                        colors: [Theme.accent.opacity(0.8), Theme.accent2.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(trader.name.prefix(1)))
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(trader.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.text)
                        if trader.isPro {
                            Text("PRO")
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(Theme.accent)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Theme.accent.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    HStack(spacing: 4) {
                        Text(trader.handle)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.text3)
                        Text("·")
                            .foregroundStyle(Theme.text3)
                        Text(trader.time)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.text3)
                    }
                }

                Spacer()

                // Today's return badge
                VStack(alignment: .trailing, spacing: 1) {
                    Text(trader.todayPct.fmtPct())
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(trader.todayPct >= 0 ? Theme.gain : Theme.loss)
                    Text("today")
                        .font(.system(size: 9))
                        .foregroundStyle(Theme.text3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // Post body — the "take"
            let postText = trader.take.isEmpty ? trader.text : trader.take
            Text(postText)
                .font(.system(size: 14))
                .foregroundStyle(Theme.text)
                .lineSpacing(4)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            // Holdings preview — tappable ticker chips with pct
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(trader.holdingDetails.prefix(4)) { h in
                        Button { onTicker(h.ticker) } label: {
                            HStack(spacing: 4) {
                                Text(h.ticker)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                Text("\(h.pct >= 0 ? "+" : "")\(String(format: "%.1f", h.pct))%")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(h.pct >= 0 ? Theme.gain : Theme.loss)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Theme.bg3)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Theme.border, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 10)

            // Divider + reaction bar
            Divider().overlay(Theme.border)
            ReactionBar()
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
    }
}

// MARK: - Feature 1: Stories Row

struct StoriesRow: View {
    let appState: AppState
    let onStoryTap: (Trader) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // "Your Story" — the user's own
                StoryRing(
                    initial: "I",
                    name: "You",
                    ringColor: appState.todayPnlPct >= 0 ? Theme.gain : Theme.loss,
                    pct: appState.todayPnlPct,
                    isOwn: true,
                    onTap: {}
                )
                // Other traders
                ForEach(FEED_TRADERS.prefix(8)) { trader in
                    StoryRing(
                        initial: String(trader.name.prefix(1)),
                        name: trader.name.components(separatedBy: " ").first ?? trader.name,
                        ringColor: trader.todayPct >= 0 ? Theme.gain : Theme.loss,
                        pct: trader.todayPct,
                        isOwn: false,
                        onTap: { onStoryTap(trader) }
                    )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
    }
}

struct StoryRing: View {
    let initial: String
    let name: String
    let ringColor: Color
    let pct: Double
    let isOwn: Bool
    let onTap: () -> Void
    @State private var appeared = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .stroke(ringColor, lineWidth: 3)
                        .frame(width: 64, height: 64)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.accent.opacity(0.6), Theme.accent2.opacity(0.4)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    Text(initial)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)
                }
                Text(name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.text2)
                    .lineLimit(1)
                Text(pct.fmtPct())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(pct >= 0 ? Theme.gain : Theme.loss)
            }
            .frame(width: 68)
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.8)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { appeared = true }
        }
    }
}

// MARK: - Feature 2: Reaction Bar

struct ReactionBar: View {
    @State private var reactions: [String: Int] = ["🔥": 24, "📈": 18, "💎": 31, "😱": 7]
    @State private var tapped: String? = nil

    let emojis = ["🔥", "📈", "💎", "😱"]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(emojis, id: \.self) { emoji in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        if tapped == emoji {
                            tapped = nil
                            reactions[emoji, default: 0] -= 1
                        } else {
                            if let prev = tapped { reactions[prev, default: 1] -= 1 }
                            tapped = emoji
                            reactions[emoji, default: 0] += 1
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(emoji).font(.system(size: 14))
                        Text("\(reactions[emoji, default: 0])")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(tapped == emoji ? Theme.accent : Theme.text3)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(tapped == emoji ? Theme.accent.opacity(0.15) : Theme.bg3)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(tapped == emoji ? Theme.accent.opacity(0.4) : Color.clear, lineWidth: 1))
                    .scaleEffect(tapped == emoji ? 1.05 : 1.0)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
}

// MARK: - Feature 3: Leaderboard

struct LeaderboardSection: View {
    @State private var period: LeaderboardPeriod = .today
    @Environment(AppState.self) var appState

    enum LeaderboardPeriod: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case allTime = "All Time"
    }

    var traders: [Trader] {
        switch period {
        case .today:
            return FEED_TRADERS.sorted { $0.todayPct > $1.todayPct }
        case .week:
            return FEED_TRADERS.sorted { $0.weekPct > $1.weekPct }
        case .allTime:
            return FEED_TRADERS.sorted { $0.allTimeReturn > $1.allTimeReturn }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Leaderboard")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(1.3)

            // Period picker
            HStack(spacing: 0) {
                ForEach(LeaderboardPeriod.allCases, id: \.self) { p in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { period = p }
                    } label: {
                        Text(p.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(period == p ? .white : Theme.text3)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(period == p ? Theme.accent : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(Theme.bg3)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // Leaderboard rows
            ForEach(Array(traders.prefix(10).enumerated()), id: \.offset) { i, trader in
                LeaderboardRow(rank: i + 1, trader: trader, period: period)
                    .staggerEntrance(index: i)
            }
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let trader: Trader
    let period: LeaderboardSection.LeaderboardPeriod

    var returnPct: Double {
        switch period {
        case .today: return trader.todayPct
        case .week: return trader.weekPct
        case .allTime: return trader.allTimeReturn
        }
    }

    var rankColor: Color {
        switch rank {
        case 1: return Theme.gold
        case 2: return Color(hex: "#C0C0C0")
        case 3: return Color(hex: "#CD7F32")
        default: return Theme.text3
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text(rank <= 3 ? ["🥇", "🥈", "🥉"][rank - 1] : "\(rank)")
                .font(.system(size: rank <= 3 ? 18 : 13, weight: .bold))
                .foregroundStyle(rankColor)
                .frame(width: 28)

            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [Theme.accent.opacity(0.7), Theme.accent2.opacity(0.5)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(trader.name.prefix(1)))
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(trader.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.text)
                Text(trader.topHolding)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
            }

            Spacer()

            Text(returnPct.fmtPct())
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(returnPct >= 0 ? Theme.gain : Theme.loss)
                .monospacedDigit()
        }
    }
}

// MARK: - Feature 5: Achievement Badges

struct AchievementBadge: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let unlocked: Bool
}

struct AchievementsRow: View {
    let badges: [AchievementBadge]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Achievements")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(1.3)
                .padding(.horizontal, 14)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(badges) { badge in
                        BadgeTile(badge: badge)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 4)
            }
        }
    }
}

struct BadgeTile: View {
    let badge: AchievementBadge
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(badge.unlocked ? Theme.accentBg : Theme.bg3)
                    .frame(width: 48, height: 48)
                Text(badge.icon)
                    .font(.system(size: 22))
                    .opacity(badge.unlocked ? 1.0 : 0.35)
                if !badge.unlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.text4)
                        .offset(x: 14, y: 14)
                }
            }
            Text(badge.title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(badge.unlocked ? Theme.text2 : Theme.text4)
                .lineLimit(1)
                .frame(width: 56)
                .multilineTextAlignment(.center)
        }
        .frame(width: 60)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.85)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.05)) { appeared = true }
        }
    }
}

// MARK: - Trader Post Card (legacy — kept for TraderProfileView usage)

struct TraderPostCard: View {
    @Environment(AppState.self) var appState
    let trader: Trader
    let onProfile: () -> Void
    let onTicker: (String) -> Void

    var isFollowed: Bool { appState.followed.contains(trader.id) }
    var isLiked: Bool { appState.likedPosts.contains(trader.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: 11) {
                Button(action: onProfile) {
                    Circle()
                        .fill(trader.color)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(trader.initial)
                                .font(.system(size: 16, weight: .black))
                                .foregroundStyle(.white)
                        )
                }

                Button(action: onProfile) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trader.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.text)
                        Text("\(trader.handle) · \(trader.time) · \(trader.followers.formatted()) followers")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.text3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    appState.toggleFollow(trader.id)
                } label: {
                    Text(isFollowed ? "Following" : "Follow")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(isFollowed ? .white : Theme.accent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(isFollowed ? Theme.accent : Theme.bg2)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.bottom, 12)

            // Performance badges
            HStack(spacing: 6) {
                perfBadge("Today", trader.perf.day)
                perfBadge("6M", trader.perf.sixMonth)
                perfBadge("YTD", trader.perf.ytd)
                perfBadge("All Time", trader.perf.allTime)
            }
            .padding(.bottom, 10)

            // Post text
            Text(trader.text)
                .font(.system(size: 13))
                .foregroundStyle(Theme.text2)
                .lineSpacing(2)
                .padding(.bottom, 10)

            // Holdings tags
            HStack(spacing: 5) {
                ForEach(trader.holdings, id: \.self) { h in
                    Button { onTicker(h) } label: {
                        Text(h)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Theme.accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(.bottom, 12)

            // Reaction Bar
            ReactionBar()
                .padding(.bottom, 10)

            // Actions
            Divider()
            HStack(spacing: 14) {
                Button {
                    appState.toggleLike(trader.id)
                } label: {
                    HStack(spacing: 4) {
                        Text(isLiked ? "❤️" : "🤍")
                        Text("\(trader.likes + (isLiked ? 1 : 0))")
                            .foregroundStyle(isLiked ? Theme.loss : Theme.text3)
                    }
                    .font(.system(size: 12, weight: .semibold))
                }
                actionBtn("💬 Comment")
                actionBtn("↗ Share")
            }
            .padding(.top, 10)
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    func perfBadge(_ label: String, _ value: Double) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.opacity(0.65))
                .textCase(.uppercase)
                .kerning(0.3)
            Text("\(value >= 0 ? "+" : "")\(String(format: "%.1f", value))%")
                .font(.system(size: 13, weight: .black))
        }
        .foregroundStyle(value >= 0 ? Theme.gain : Theme.loss)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(value >= 0 ? Theme.gainBg : Theme.lossBg)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    func actionBtn(_ title: String) -> some View {
        Button(title) {}
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Theme.text3)
    }
}

// MARK: - Trader Profile

struct TraderProfileView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    let trader: Trader
    let onTicker: (String) -> Void

    var isFollowed: Bool { appState.followed.contains(trader.id) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Cover
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [trader.color, Color(hex: "#EDE9FE")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        .frame(height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 0))
                        .overlay(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 0)
                                .fill(.clear)
                                .frame(height: 42)
                        }

                        Circle()
                            .fill(trader.color)
                            .frame(width: 84, height: 84)
                            .overlay(
                                Text(trader.initial)
                                    .font(.system(size: 32, weight: .black))
                                    .foregroundStyle(.white)
                            )
                            .overlay(Circle().stroke(Theme.bg, lineWidth: 4))
                            .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
                            .offset(x: 18, y: 42)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Spacer()
                            Button("✕ Close") { dismiss() }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.accent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 7)
                                .background(Theme.bg2)
                                .clipShape(Capsule())
                        }
                        .padding(.bottom, -8)

                        Text(trader.name)
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(Theme.text)
                            .padding(.top, 54)

                        Text(trader.handle)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.text3)
                            .padding(.top, 2)

                        HStack(spacing: 24) {
                            VStack {
                                Text(trader.followers.formatted())
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                Text("Followers")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.text3)
                            }
                            VStack {
                                Text("\(trader.following)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                Text("Following")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.text3)
                            }
                        }
                        .padding(.top, 16)

                        Button {
                            appState.toggleFollow(trader.id)
                        } label: {
                            Text(isFollowed ? "Following" : "Follow")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Theme.accentGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.top, 14)

                        // Performance
                        Text("Performance")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.text3)
                            .textCase(.uppercase)
                            .kerning(1.3)
                            .padding(.top, 20)
                            .padding(.bottom, 10)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
                            profilePerfItem("Today", trader.perf.day)
                            profilePerfItem("6M", trader.perf.sixMonth)
                            profilePerfItem("YTD", trader.perf.ytd)
                            profilePerfItem("All Time", trader.perf.allTime)
                        }
                        .padding(.bottom, 18)

                        // Holdings
                        Text("Top Holdings")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.text3)
                            .textCase(.uppercase)
                            .kerning(1.3)
                            .padding(.bottom, 10)

                        VStack(spacing: 8) {
                            ForEach(trader.holdings, id: \.self) { h in
                                Button { onTicker(h); dismiss() } label: {
                                    HStack {
                                        Text(h)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Theme.text)
                                        Spacer()
                                        Text("Tap for chart →")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Theme.text3)
                                    }
                                    .padding(14)
                                    .background(Theme.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 40)
                }
            }
            .background(Theme.bg)
        }
    }

    func profilePerfItem(_ label: String, _ value: Double) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(0.5)
            Text("\(value >= 0 ? "+" : "")\(String(format: "%.1f", value))%")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(value >= 0 ? Theme.gain : Theme.loss)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(Theme.bg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - My Post Card

struct MyPostCard: View {
    let post: UserPost
    let appState: AppState
    let onTicker: (String) -> Void

    private var timeAgo: String {
        let diff = Date().timeIntervalSince(post.timestamp)
        if diff < 60 { return "Just now" }
        if diff < 3600 { return "\(Int(diff / 60))m ago" }
        if diff < 86400 { return "\(Int(diff / 3600))h ago" }
        return "\(Int(diff / 86400))d ago"
    }

    private var sentimentColor: Color {
        switch post.sentiment {
        case "Bullish": return Theme.gain
        case "Bearish": return Theme.loss
        default: return Theme.accent
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 10) {
                Circle()
                    .fill(Theme.accentGradient)
                    .frame(width: 38, height: 38)
                    .overlay(
                        Text(String(appState.settings.displayName.prefix(1)).uppercased())
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(appState.settings.displayName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.text)
                        Text("YOU")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Theme.accentBg)
                            .clipShape(Capsule())
                    }
                    Text("\(appState.settings.username) · \(timeAgo)")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.text3)
                }

                Spacer()

                Text(post.sentiment)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(sentimentColor)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(sentimentColor.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)

            // Body
            Text(post.text)
                .font(.system(size: 14))
                .foregroundStyle(Theme.text)
                .lineSpacing(4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

            // Ticker chips
            if !post.tickers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(post.tickers, id: \.self) { ticker in
                            Button { onTicker(ticker) } label: {
                                Text("$\(ticker)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Theme.accent)
                                    .padding(.horizontal, 10).padding(.vertical, 5)
                                    .background(Theme.accentBg)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Theme.accent.opacity(0.3), lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                }
                .padding(.bottom, 8)
            }

            Divider().overlay(Theme.border)
            HStack {
                Image(systemName: "heart")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text3)
                Text("0")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text3)
                Spacer()
                Image(systemName: "bubble.left")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text3)
                Text("0")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text3)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.accent.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.30), radius: 8, y: 3)
    }
}
