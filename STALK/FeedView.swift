import SwiftUI

// MARK: - FeedView

struct FeedView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void
    @State private var profileTrader: Trader? = nil
    @State private var storyTrader: Trader? = nil
    @State private var feedTab = "Trending"
    @State private var showCreatePost = false
    @State private var showMyProfile = false

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
                                .font(.system(size: 36))
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
                                .shadow(color: Theme.gold.opacity(0.4), radius: 8)
                        }
                        .padding(14)
                        .background(LinearGradient(
                            colors: [Color(hex: "#FB923C").opacity(0.22), Color(hex: "#F97316").opacity(0.14), Color(hex: "#EA580C").opacity(0.06)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F97316").opacity(0.4), lineWidth: 1))
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
        .sheet(isPresented: $showMyProfile) {
            MyProfileView().environment(appState)
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
                Button { showMyProfile = true } label: {
                    Circle()
                        .fill(Theme.accentGradient)
                        .frame(width: 38, height: 38)
                        .overlay(
                            Text(String(appState.settings.displayName.prefix(1)).uppercased())
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(.white)
                        )
                        .overlay(Circle().stroke(Theme.accent.opacity(0.4), lineWidth: 2))
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
                .kerning(1.5)
            Text(value == 0 ? "—" : "\(value >= 0 ? "+" : "")\(String(format: "%.1f", value))%")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(value == 0 ? Theme.text3 : value >= 0 ? Theme.gain : Theme.loss)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(
            (value == 0 ? Theme.bg : (value >= 0 ? Theme.gain : Theme.loss).opacity(0.07))
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(value == 0 ? Color.clear : (value >= 0 ? Theme.gain : Theme.loss).opacity(0.18), lineWidth: 1)
        )
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
                        colors: [Theme.accent, Color(hex: "#A78BFA"), Theme.accent2.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(trader.name.prefix(1)))
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: Theme.accent.opacity(0.35), radius: 6, y: 2)

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
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(.white)
                    Text("today")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background((trader.todayPct >= 0 ? Theme.gain : Theme.loss).opacity(0.88))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // Post body — the "take"
            let postText = trader.take.isEmpty ? trader.text : trader.take
            Text(postText)
                .font(.system(size: 15))
                .foregroundStyle(Theme.text)
                .lineSpacing(5)
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
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 20)
                .fill((trader.todayPct >= 0 ? Theme.gain : Theme.loss).opacity(0.15))
                .frame(height: 3)
                .padding(.horizontal, 20)
        }
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
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                ZStack {
                    // Vivid 3-color gradient ring for unviewed stories
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: pct >= 0
                                    ? [Color(hex: "#00D26A"), Color(hex: "#34D399"), Color(hex: "#10B981"), Color(hex: "#00D26A")]
                                    : [Color(hex: "#FF4757"), Color(hex: "#FF6B81"), Color(hex: "#EF4444"), Color(hex: "#FF4757")],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 64, height: 64)
                        .scaleEffect(isOwn ? 1.0 : pulseScale)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.accent.opacity(0.75), Theme.accent2.opacity(0.55)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    Text(initial)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)
                }
                Text(name)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.text2)
                    .lineLimit(1)
                    .truncationMode(.tail)
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
            // Subtle pulse for unviewed stories
            if !isOwn {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(0.3)) {
                    pulseScale = 1.07
                }
            }
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
                        Text(emoji).font(.system(size: 20))
                        Text("\(reactions[emoji, default: 0])")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(tapped == emoji ? Theme.accent : Theme.text3)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(tapped == emoji ? Theme.accent.opacity(0.15) : Theme.bg3)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(tapped == emoji ? Theme.accent.opacity(0.5) : Color.clear, lineWidth: 1))
                    .scaleEffect(tapped == emoji ? 1.18 : 1.0)
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

    var leftBorderColor: Color {
        switch rank {
        case 1: return Theme.gold
        case 2: return Color(hex: "#C0C0C0")
        case 3: return Color(hex: "#CD7F32")
        default: return Color.clear
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text(rank <= 3 ? ["🥇", "🥈", "🥉"][rank - 1] : "\(rank)")
                .font(.system(size: rank <= 3 ? 24 : 13, weight: .bold))
                .foregroundStyle(rankColor)
                .frame(width: 32)

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
        .padding(.vertical, rank <= 3 ? 6 : 2)
        .padding(.horizontal, rank <= 3 ? 10 : 0)
        .background(rank == 1 ? Theme.gold.opacity(0.07) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .leading) {
            if rank <= 3 {
                RoundedRectangle(cornerRadius: 2)
                    .fill(leftBorderColor)
                    .frame(width: 3)
                    .padding(.vertical, 4)
            }
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

private enum ReturnsPeriod: String, CaseIterable {
    case day  = "1D"
    case week = "1W"
    case month = "1M"
    case ytd  = "YTD"
    case all  = "All"
}

struct TraderProfileView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    let trader: Trader
    let onTicker: (String) -> Void

    @State private var selectedPeriod: ReturnsPeriod = .day
    @State private var showCopySheet = false
    @State private var showMessageAlert = false
    @State private var copyHoldings: [String: Bool] = [:]

    var isFollowed: Bool { appState.followed.contains(trader.id) }
    var isCopying: Bool { appState.copiedTraders.contains(trader.id) }

    private var postCount: Int { trader.id % 10 + 12 }

    // Returns for selected period
    private var traderReturn: Double {
        switch selectedPeriod {
        case .day:   return trader.perf.day
        case .week:  return trader.weekPct
        case .month: return trader.perf.sixMonth / 6
        case .ytd:   return trader.perf.ytd
        case .all:   return trader.perf.allTime
        }
    }

    private var youReturn: Double {
        switch selectedPeriod {
        case .day: return appState.todayPnlPct
        default:   return appState.totalPnlPct
        }
    }

    private var spReturn: Double {
        switch selectedPeriod {
        case .day:   return 0.8
        case .week:  return 1.9
        case .month: return 4.2
        case .ytd:   return 14.8
        case .all:   return 26.8
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: Cover + Avatar
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [trader.color, trader.color.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 160)

                    // Back button overlaid top-left
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .bold))
                            Text("Back")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.25))
                        .clipShape(Capsule())
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 90)

                    // Avatar — overlaps cover bottom
                    ZStack {
                        Circle()
                            .fill(trader.color)
                            .frame(width: 90, height: 90)
                            .overlay(
                                Text(trader.initial)
                                    .font(.system(size: 34, weight: .black))
                                    .foregroundStyle(.white)
                            )
                            .overlay(Circle().stroke(Theme.bg, lineWidth: 4))
                            .shadow(color: .black.opacity(0.15), radius: 14, y: 6)

                        if trader.isPro {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Theme.gold)
                                .background(Circle().fill(Theme.bg).frame(width: 22, height: 22))
                                .offset(x: 32, y: 32)
                        }
                    }
                    .offset(x: 20, y: 45)
                }
                .frame(height: 160)

                // MARK: Identity + Stats
                VStack(alignment: .leading, spacing: 0) {
                    // Name row — offset to clear avatar
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 8) {
                                Text(trader.name)
                                    .font(.system(size: 22, weight: .black))
                                    .foregroundStyle(Theme.text)
                                if trader.isPro {
                                    Text("PRO")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundStyle(Theme.gold)
                                        .padding(.horizontal, 6).padding(.vertical, 3)
                                        .background(Theme.gold.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
                            Text(trader.handle)
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.text3)
                        }
                        Spacer()
                    }
                    .padding(.top, 54)

                    // Bio
                    if !trader.take.isEmpty {
                        Text(trader.take)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.text2)
                            .lineLimit(2)
                            .padding(.top, 6)
                    }

                    // Stats row
                    HStack(spacing: 0) {
                        profileStatItem(trader.followers.formatted(), "Followers")
                        Divider().frame(height: 28).padding(.horizontal, 16)
                        profileStatItem("\(trader.following)", "Following")
                        Divider().frame(height: 28).padding(.horizontal, 16)
                        profileStatItem("\(postCount)", "Posts")
                        Spacer()
                    }
                    .padding(.top, 18)

                    // MARK: Action Buttons
                    HStack(spacing: 10) {
                        // Follow
                        Button {
                            appState.toggleFollow(trader.id)
                        } label: {
                            Text(isFollowed ? "Following" : "Follow")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .background(isFollowed ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.accentGradient))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(isFollowed ? Color.clear : Color.clear, lineWidth: 1)
                                )
                        }

                        // Copy Trade
                        Button {
                            if isCopying {
                                appState.toggleCopyTrade(trader.id)
                            } else {
                                copyHoldings = Dictionary(uniqueKeysWithValues: trader.holdings.map { ($0, true) })
                                showCopySheet = true
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: isCopying ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                    .font(.system(size: 12))
                                Text(isCopying ? "Copying" : "Copy")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundStyle(isCopying ? Theme.gain : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .background(isCopying ? Theme.gainBg : Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // Message
                        Button {
                            showMessageAlert = true
                        } label: {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.text3)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 11)
                                .background(Theme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
                        }
                        .alert("Coming soon", isPresented: $showMessageAlert) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text("Direct messages are coming in a future update.")
                        }
                    }
                    .padding(.top, 16)

                    // MARK: Returns Comparison
                    VStack(alignment: .leading, spacing: 14) {
                        Text("RETURNS COMPARISON")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.text3)
                            .kerning(1.3)
                            .padding(.top, 24)

                        // Period picker
                        HStack(spacing: 6) {
                            ForEach(ReturnsPeriod.allCases, id: \.self) { period in
                                Button {
                                    selectedPeriod = period
                                } label: {
                                    Text(period.rawValue)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(selectedPeriod == period ? .white : Theme.text3)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedPeriod == period ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.card))
                                        .clipShape(Capsule())
                                }
                            }
                        }

                        // Comparison table
                        VStack(spacing: 0) {
                            returnsTableHeader()
                            Divider().background(Theme.border)
                            returnsRow(icon: "🏆", label: trader.name, todayVal: trader.perf.day, periodVal: traderReturn)
                            Divider().background(Theme.border).padding(.leading, 40)
                            returnsRow(icon: "👤", label: "You", todayVal: appState.todayPnlPct, periodVal: youReturn)
                            Divider().background(Theme.border).padding(.leading, 40)
                            returnsRow(icon: "📈", label: "S&P 500", todayVal: 0.8, periodVal: spReturn)
                        }
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))

                        // Visual bar comparison
                        returnsBarChart()
                    }

                    // MARK: Top Holdings
                    Text("TOP HOLDINGS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.text3)
                        .kerning(1.3)
                        .padding(.top, 24)
                        .padding(.bottom, 10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(trader.holdingDetails) { h in
                                Button {
                                    onTicker(h.ticker)
                                    dismiss()
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(h.ticker)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(Theme.text)
                                        Text("\(h.pct >= 0 ? "+" : "")\(String(format: "%.1f", h.pct))%")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(h.pct >= 0 ? Theme.gain : Theme.loss)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(h.pct >= 0 ? Theme.gainBg : Theme.lossBg)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(h.pct >= 0 ? Theme.gain.opacity(0.25) : Theme.loss.opacity(0.25), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 4)
                    }

                    // MARK: Recent Posts
                    Text("RECENT POSTS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.text3)
                        .kerning(1.3)
                        .padding(.top, 24)
                        .padding(.bottom, 10)

                    VStack(spacing: 10) {
                        if !trader.take.isEmpty {
                            recentPostCard(text: trader.take, time: trader.time, likes: trader.likes)
                        }
                        if !trader.text.isEmpty {
                            recentPostCard(text: trader.text, time: "5h ago", likes: max(trader.likes - 8, 1))
                        }
                        // Synthetic older post
                        recentPostCard(
                            text: "Portfolio update: holding strong through the volatility. Conviction > panic selling.",
                            time: "1d ago",
                            likes: max(trader.likes - 20, 1)
                        )
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 50)
            }
        }
        .background(Theme.bg)
        .sheet(isPresented: $showCopySheet) {
            copyTradeSheet()
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private func profileStatItem(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.text)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Theme.text3)
        }
    }

    @ViewBuilder
    private func returnsTableHeader() -> some View {
        HStack {
            Text("Trader")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.text3)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("TODAY")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .kerning(0.5)
                .frame(width: 68, alignment: .trailing)
            Text(selectedPeriod.rawValue)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .kerning(0.5)
                .frame(width: 68, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func returnsRow(icon: String, label: String, todayVal: Double, periodVal: Double) -> some View {
        HStack {
            Text(icon)
                .font(.system(size: 15))
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.text)
                .lineLimit(1)
            Spacer()
            Text(pctString(todayVal))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(todayVal >= 0 ? Theme.gain : Theme.loss)
                .frame(width: 68, alignment: .trailing)
            Text(pctString(periodVal))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(periodVal >= 0 ? Theme.gain : Theme.loss)
                .frame(width: 68, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func returnsBarChart() -> some View {
        let values = [traderReturn, youReturn, spReturn]
        let maxAbs = max(values.map { abs($0) }.max() ?? 1, 1)
        let labels = [trader.name, "You", "S&P 500"]
        let icons  = ["🏆", "👤", "📈"]
        let colors: [Color] = [trader.color, Theme.accent, Color(hex: "#22C55E")]

        VStack(alignment: .leading, spacing: 10) {
            ForEach(0..<3, id: \.self) { i in
                let val = values[i]
                HStack(spacing: 8) {
                    Text(icons[i])
                        .font(.system(size: 13))
                    Text(labels[i])
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.text2)
                        .frame(width: 70, alignment: .leading)
                    GeometryReader { geo in
                        let barWidth = CGFloat(abs(val) / maxAbs) * geo.size.width
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.card)
                                .frame(height: 18)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(val >= 0 ? colors[i] : Theme.loss)
                                .frame(width: max(barWidth, 4), height: 18)
                        }
                    }
                    .frame(height: 18)
                    Text(pctString(val))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(val >= 0 ? Theme.gain : Theme.loss)
                        .frame(width: 52, alignment: .trailing)
                }
            }
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private func recentPostCard(text: String, time: String, likes: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(trader.color)
                    .frame(width: 34, height: 34)
                    .overlay(
                        Text(trader.initial)
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.white)
                    )
                VStack(alignment: .leading, spacing: 1) {
                    Text(trader.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text("\(trader.handle) · \(time)")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                }
                Spacer()
            }
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Theme.text2)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 4) {
                Image(systemName: "heart")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
                Text("\(likes)")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
            }
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }

    @ViewBuilder
    private func copyTradeSheet() -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header card
                        HStack(spacing: 14) {
                            Circle()
                                .fill(trader.color)
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Text(trader.initial)
                                        .font(.system(size: 20, weight: .black))
                                        .foregroundStyle(.white)
                                )
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Copy \(trader.name)'s Portfolio")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                Text("Select holdings to mirror")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.text3)
                            }
                            Spacer()
                        }
                        .padding(18)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                        .padding(.horizontal, 18)
                        .padding(.top, 18)
                        .padding(.bottom, 14)

                        Text("HOLDINGS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.text3)
                            .kerning(1.3)
                            .padding(.horizontal, 18)
                            .padding(.bottom, 8)

                        VStack(spacing: 0) {
                            ForEach(trader.holdingDetails) { h in
                                let isOn = copyHoldings[h.ticker] ?? true
                                Button {
                                    copyHoldings[h.ticker] = !isOn
                                } label: {
                                    HStack {
                                        Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 20))
                                            .foregroundStyle(isOn ? Theme.accent : Theme.text3)
                                        Text(h.ticker)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(Theme.text)
                                        Spacer()
                                        Text(pctString(h.pct))
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(h.pct >= 0 ? Theme.gain : Theme.loss)
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(.plain)
                                if h.id != trader.holdingDetails.last?.id {
                                    Divider().padding(.leading, 54)
                                }
                            }
                        }
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                        .padding(.horizontal, 18)

                        // Disclaimer
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.text3)
                                .padding(.top, 1)
                            Text("This is a tracker, not a broker. No real trades are executed. Copy trading mirrors your portfolio watchlist only.")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.text3)
                        }
                        .padding(14)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                        .padding(.horizontal, 18)
                        .padding(.top, 14)
                    }
                }

                // Start Copying button
                Button {
                    appState.toggleCopyTrade(trader.id)
                    showCopySheet = false
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 14))
                        Text("Start Copying \(trader.name)")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 34)
            }
            .background(Theme.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCopySheet = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Theme.text3)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func pctString(_ v: Double) -> String {
        "\(v >= 0 ? "+" : "")\(String(format: "%.1f", v))%"
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
