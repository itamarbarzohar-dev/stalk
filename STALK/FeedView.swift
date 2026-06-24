import SwiftUI

// MARK: - FeedView

struct FeedView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void
    @State private var profileTrader: Trader? = nil
    @State private var storyTrader: Trader? = nil
    @State private var feedTab = "For You"
    @State private var showCreatePost = false
    @State private var showMyProfile = false
    @State private var showActivity = false
    @State private var showCommunities = false
    @State private var commentsTrader: Trader? = nil
    @State private var commentsDiscoverItem: DiscoverItem? = nil
    @State private var showTagSheet = false

    var feedTraders: [Trader] {
        switch feedTab {
        case "Following":
            return FEED_TRADERS.filter { appState.followed.contains($0.id) }
        case "Discover":
            return FEED_TRADERS.filter { !appState.followed.contains($0.id) }.sorted { $0.copiers > $1.copiers }
        default:
            return FEED_TRADERS.sorted { $0.todayPct > $1.todayPct }
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Theme.bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    feedHeader
                    feedTabBar

                    if feedTab == "Discover" {
                        DiscoverFeedSection(onTicker: onTicker)
                            .padding(.top, 8)
                    } else {
                        StoriesRow(appState: appState, onStoryTap: { trader in storyTrader = trader })
                            .padding(.top, 4)

                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 0.5)

                        if !appState.userPosts.isEmpty {
                            ForEach(appState.userPosts) { post in
                                MyPostCard(post: post, appState: appState, onTicker: onTicker)
                                Rectangle()
                                    .fill(Theme.border)
                                    .frame(height: 0.5)
                                Color.clear.frame(height: 8)
                            }
                        }

                        if feedTraders.isEmpty && appState.userPosts.isEmpty {
                            feedEmptyState
                        } else {
                            ForEach(Array(feedTraders.enumerated()), id: \.element.id) { i, trader in
                                SocialPostCard(
                                    trader: trader,
                                    onTicker: onTicker,
                                    onComments: { commentsTrader = trader },
                                    onProfile: { profileTrader = trader }
                                )
                                .staggerEntrance(index: i)
                                Rectangle()
                                    .fill(Theme.border)
                                    .frame(height: 0.5)
                                Color.clear.frame(height: 8)
                            }
                        }
                    }

                    Color.clear.frame(height: 100)
                }
            }

            Button { showCreatePost = true } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(Theme.accentGradient)
                    .clipShape(Circle())
                    .shadow(color: Theme.accent.opacity(0.45), radius: 14, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 18)
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView().environment(appState)
        }
        .sheet(isPresented: $showMyProfile) {
            MyProfileView().environment(appState)
        }
        .sheet(isPresented: $showActivity) {
            ActivityView().environment(appState)
        }
        .sheet(isPresented: $showCommunities) {
            CommunitiesView().environment(appState)
        }
        .sheet(item: $profileTrader) { trader in
            TraderProfileView(trader: trader, onTicker: onTicker)
        }
        .sheet(item: $storyTrader) { trader in
            TraderProfileView(trader: trader, onTicker: onTicker)
        }
        .sheet(item: $commentsTrader) { trader in
            CommentsSheet(trader: trader).environment(appState)
        }
        .sheet(item: $commentsDiscoverItem) { item in
            CommentsSheet(trader: item.trader).environment(appState)
        }
        .alert("Tag People", isPresented: $showTagSheet) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Tagging is coming in a future update.")
        }
    }

    var feedHeader: some View {
        HStack(spacing: 14) {
            HStack(spacing: 5) {
                Image(systemName: "sparkle")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Theme.accent)
                Text("STALK")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(Theme.text)
            }
            Spacer()
            Button {} label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.text2)
            }
            .buttonStyle(.plain)
            Button { showActivity = true } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.text2)
                    Circle()
                        .fill(Color(hex: "#F43F5E"))
                        .frame(width: 7, height: 7)
                        .overlay(Circle().stroke(Theme.bg, lineWidth: 1))
                        .offset(x: 2, y: -2)
                }
            }
            .buttonStyle(.plain)
            Button {} label: {
                Image(systemName: "paperplane")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.text2)
            }
            .buttonStyle(.plain)
            Button { showMyProfile = true } label: {
                Circle()
                    .fill(Theme.accentGradient)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(appState.settings.displayName.prefix(1)).uppercased())
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.top, 56)
        .padding(.bottom, 12)
        .background(Theme.bg)
    }

    var feedTabBar: some View {
        HStack(spacing: 0) {
            ForEach(["For You", "Following", "Discover"], id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { feedTab = tab }
                } label: {
                    VStack(spacing: 8) {
                        Text(tab)
                            .font(.system(size: 14, weight: feedTab == tab ? .bold : .regular))
                            .foregroundStyle(feedTab == tab ? Theme.text : Theme.text3)
                            .frame(maxWidth: .infinity)
                        Rectangle()
                            .fill(feedTab == tab ? Theme.accent : Color.clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 4)
        .background(Theme.bg)
        .overlay(Rectangle().fill(Theme.border).frame(height: 0.5), alignment: .bottom)
    }

    var feedEmptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Theme.text3)
            Text("No posts yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.text2)
            Text("Follow some traders to see their posts here.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.text3)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }
}

// MARK: - SocialPostCard

struct SocialPostCard: View {
    let trader: Trader
    let onTicker: (String) -> Void
    var onComments: (() -> Void)? = nil
    var onProfile: (() -> Void)? = nil

    @State private var liked = false
    @State private var likeCount: Int

    init(trader: Trader, onTicker: @escaping (String) -> Void,
         onComments: (() -> Void)? = nil, onProfile: (() -> Void)? = nil) {
        self.trader = trader
        self.onTicker = onTicker
        self.onComments = onComments
        self.onProfile = onProfile
        self._likeCount = State(initialValue: trader.likes)
    }

    private var postText: String { trader.take.isEmpty ? trader.text : trader.take }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Button { onProfile?() } label: {
                    Circle()
                        .fill(LinearGradient(
                            colors: [trader.color, trader.color.opacity(0.6)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 46, height: 46)
                        .overlay(
                            Text(trader.initial)
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(.white)
                        )
                        .shadow(color: trader.color.opacity(0.4), radius: 6, y: 2)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Button { onProfile?() } label: {
                            Text(trader.name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Theme.text)
                        }
                        .buttonStyle(.plain)
                        if trader.isPro {
                            Text("PRO")
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(Theme.accent)
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background(Theme.accentBg)
                                .clipShape(Capsule())
                        }
                    }
                    HStack(spacing: 4) {
                        Text(trader.handle)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.text3)
                        Text("·")
                            .foregroundStyle(Theme.text4)
                        Text(trader.time)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.text3)
                    }
                }

                Spacer()

                Text(trader.todayPct >= 0
                     ? "+\(String(format: "%.1f", trader.todayPct))%"
                     : "\(String(format: "%.1f", trader.todayPct))%")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background((trader.todayPct >= 0 ? Theme.gain : Theme.loss).opacity(0.9))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            Text(postText)
                .font(.system(size: 16))
                .foregroundStyle(Theme.text)
                .lineSpacing(6)
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 2)

            if !trader.holdingDetails.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(trader.holdingDetails.prefix(5)) { h in
                            Button { onTicker(h.ticker) } label: {
                                Text(h.ticker)
                                    .font(.system(size: 12, weight: .bold).monospaced())
                                    .foregroundStyle(Theme.text2)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Theme.bg3)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }

            HStack(spacing: 0) {
                actionPair(icon: liked ? "heart.fill" : "heart",
                           count: likeCount + (liked ? 1 : 0),
                           color: liked ? Color(hex: "#F43F5E") : Theme.text3) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { liked.toggle() }
                }
                actionPair(icon: "bubble.left", count: trader.likes / 5 + 2, color: Theme.text3) {
                    onComments?()
                }
                Button {} label: {
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.text3)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                Spacer()
                Button { onProfile?() } label: {
                    HStack(spacing: 4) {
                        Text("Copy Trade")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.accent)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Theme.accentBg)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
            }
            .padding(.top, 4)
            .padding(.bottom, 10)
        }
    }

    @ViewBuilder
    private func actionPair(icon: String, count: Int, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                Text("\(count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(color)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stories Row

struct StoriesRow: View {
    let appState: AppState
    let onStoryTap: (Trader) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                StoryRing(
                    initial: String(appState.settings.displayName.prefix(1)).uppercased(),
                    name: "You",
                    pct: appState.todayPnlPct,
                    isOwn: true,
                    onTap: {}
                )
                ForEach(FEED_TRADERS.prefix(8)) { trader in
                    StoryRing(
                        initial: trader.initial,
                        name: trader.name.components(separatedBy: " ").first ?? trader.name,
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
    let pct: Double
    let isOwn: Bool
    let onTap: () -> Void
    @State private var appeared = false
    @State private var pulseScale: CGFloat = 1.0

    private var ringGain: Bool { pct >= 0 }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: ringGain
                                    ? [Color(hex: "#00D26A"), Color(hex: "#34D399"), Color(hex: "#06B6D4"), Color(hex: "#00D26A")]
                                    : [Color(hex: "#FF4757"), Color(hex: "#FF6B81"), Color(hex: "#F43F5E"), Color(hex: "#FF4757")],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 72, height: 72)
                        .scaleEffect(isOwn ? 1.0 : pulseScale)

                    Circle()
                        .stroke(Theme.bg, lineWidth: 3)
                        .frame(width: 68, height: 68)

                    Circle()
                        .fill(LinearGradient(
                            colors: [Theme.accent.opacity(0.8), Theme.accent2.opacity(0.6)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 62, height: 62)

                    Text(initial)
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.white)

                    if isOwn {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.accent)
                            .background(Circle().fill(Theme.bg).frame(width: 20, height: 20))
                            .offset(x: 22, y: 22)
                    }
                }

                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.text2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .truncationMode(.tail)
            }
            .frame(width: 72)
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.8)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { appeared = true }
            if !isOwn {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.3)) {
                    pulseScale = 1.06
                }
            }
        }
    }
}

// MARK: - Reaction Bar

struct ReactionBar: View {
    @State private var reactions: [String: Int] = ["fire": 24, "up": 18, "gem": 31, "wow": 7]
    @State private var tapped: String? = nil

    let reactionItems: [(id: String, symbol: String, color: Color)] = [
        ("fire", "flame.fill",                  Color(hex: "#F97316")),
        ("up",   "chart.line.uptrend.xyaxis",   Color(hex: "#22C55E")),
        ("gem",  "diamond.fill",                Color(hex: "#38BDF8")),
        ("wow",  "exclamationmark.bubble.fill", Color(hex: "#F43F5E")),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(reactionItems, id: \.id) { item in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        if tapped == item.id {
                            tapped = nil
                            reactions[item.id, default: 0] -= 1
                        } else {
                            if let prev = tapped { reactions[prev, default: 1] -= 1 }
                            tapped = item.id
                            reactions[item.id, default: 0] += 1
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(tapped == item.id ? item.color : Theme.text3)
                        Text("\(reactions[item.id, default: 0])")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(tapped == item.id ? item.color : Theme.text3)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(tapped == item.id ? item.color.opacity(0.15) : Theme.bg3)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(tapped == item.id ? item.color.opacity(0.5) : Color.clear, lineWidth: 1))
                    .scaleEffect(tapped == item.id ? 1.18 : 1.0)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
}

// MARK: - Achievement Badges

struct AchievementBadge: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
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
                Image(systemName: badge.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(badge.unlocked ? badge.iconColor : Theme.text4)
                    .opacity(badge.unlocked ? 1.0 : 0.4)
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

// MARK: - TraderPostCard (legacy)

struct TraderPostCard: View {
    @Environment(AppState.self) var appState
    let trader: Trader
    let onProfile: () -> Void
    let onTicker: (String) -> Void

    var isFollowed: Bool { appState.followed.contains(trader.id) }
    var isLiked: Bool { appState.likedPosts.contains(trader.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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

            HStack(spacing: 6) {
                perfBadge("Today", trader.perf.day)
                perfBadge("6M", trader.perf.sixMonth)
                perfBadge("YTD", trader.perf.ytd)
                perfBadge("All Time", trader.perf.allTime)
            }
            .padding(.bottom, 10)

            Text(trader.text)
                .font(.system(size: 13))
                .foregroundStyle(Theme.text2)
                .lineSpacing(2)
                .padding(.bottom, 10)

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

            ReactionBar()
                .padding(.bottom, 10)

            Divider()
            HStack(spacing: 14) {
                Button {
                    appState.toggleLike(trader.id)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundStyle(isLiked ? Theme.loss : Theme.text3)
                        Text("\(trader.likes + (isLiked ? 1 : 0))")
                            .foregroundStyle(isLiked ? Theme.loss : Theme.text3)
                    }
                    .font(.system(size: 12, weight: .semibold))
                }
                actionBtn("Comment")
                actionBtn("Share")
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
    @State private var copyStep = 1
    @State private var copyAmount: Double = 1000
    @State private var stopLossPct: Double = 20

    private var riskColor: Color {
        if trader.riskScore <= 3 { return Theme.gain }
        if trader.riskScore <= 6 { return Theme.gold }
        return Theme.loss
    }

    var isFollowed: Bool { appState.followed.contains(trader.id) }
    var isCopying: Bool { appState.copiedTraders.contains(trader.id) }
    private var postCount: Int { trader.id % 10 + 12 }

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
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [trader.color, trader.color.opacity(0.3)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .frame(height: 160)

                    Button { dismiss() } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left").font(.system(size: 13, weight: .bold))
                            Text("Back").font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(.black.opacity(0.25))
                        .clipShape(Capsule())
                    }
                    .padding(.leading, 16).padding(.bottom, 90)

                    ZStack {
                        Circle()
                            .fill(trader.color)
                            .frame(width: 90, height: 90)
                            .overlay(Text(trader.initial).font(.system(size: 34, weight: .black)).foregroundStyle(.white))
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

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 8) {
                                Text(trader.name).font(.system(size: 22, weight: .black)).foregroundStyle(Theme.text)
                                if trader.isPro {
                                    Text("PRO")
                                        .font(.system(size: 9, weight: .black)).foregroundStyle(Theme.gold)
                                        .padding(.horizontal, 6).padding(.vertical, 3)
                                        .background(Theme.gold.opacity(0.15)).clipShape(Capsule())
                                }
                            }
                            Text(trader.handle).font(.system(size: 13)).foregroundStyle(Theme.text3)
                        }
                        Spacer()
                    }
                    .padding(.top, 54)

                    if !trader.take.isEmpty {
                        Text(trader.take)
                            .font(.system(size: 13)).foregroundStyle(Theme.text2).lineLimit(2).padding(.top, 6)
                    }

                    HStack(spacing: 0) {
                        profileStatItem(trader.followers.formatted(), "Followers")
                        Divider().frame(height: 28).padding(.horizontal, 16)
                        profileStatItem("\(trader.following)", "Following")
                        Divider().frame(height: 28).padding(.horizontal, 16)
                        profileStatItem("\(postCount)", "Posts")
                        Spacer()
                    }
                    .padding(.top, 18)

                    HStack(spacing: 10) {
                        Button { appState.toggleFollow(trader.id) } label: {
                            Text(isFollowed ? "Following" : "Follow")
                                .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 11)
                                .background(AnyShapeStyle(Theme.accentGradient))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        Button {
                            if isCopying { appState.toggleCopyTrade(trader.id) }
                            else { copyHoldings = Dictionary(uniqueKeysWithValues: trader.holdings.map { ($0, true) }); showCopySheet = true }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: isCopying ? "checkmark.circle.fill" : "doc.on.doc.fill").font(.system(size: 12))
                                Text(isCopying ? "Copying" : "Copy").font(.system(size: 14, weight: .bold))
                            }
                            .foregroundStyle(isCopying ? Theme.gain : .white)
                            .padding(.horizontal, 16).padding(.vertical, 11)
                            .background(isCopying ? Theme.gainBg : Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        Button { showMessageAlert = true } label: {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 16, weight: .semibold)).foregroundStyle(Theme.text3)
                                .padding(.horizontal, 14).padding(.vertical, 11)
                                .background(Theme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
                        }
                        .alert("Coming soon", isPresented: $showMessageAlert) { Button("OK", role: .cancel) {} }
                        message: { Text("Direct messages are coming in a future update.") }
                    }
                    .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("TRADING STATS")
                            .font(.system(size: 10, weight: .black)).foregroundStyle(Theme.text3).kerning(2.0).padding(.top, 22)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            etoroStatCell("Risk Score", "\(trader.riskScore)/10",
                                          subtitle: trader.riskScore <= 3 ? "Low" : trader.riskScore <= 6 ? "Medium" : "High", color: riskColor)
                            etoroStatCell("Max Drawdown", "\(String(format: "%.1f", trader.maxDrawdown))%", subtitle: "peak to trough", color: Theme.loss)
                            etoroStatCell("Win Rate", "\(String(format: "%.1f", trader.winRate))%", subtitle: "profitable trades", color: Theme.gain)
                            etoroStatCell("Copiers",
                                          trader.copiers >= 1000 ? "\(String(format: "%.1f", Double(trader.copiers)/1000))K" : "\(trader.copiers)",
                                          subtitle: "copying now", color: Theme.accent)
                            etoroStatCell("Avg Hold", "\(trader.avgHoldingDays)d", subtitle: "per trade", color: Theme.text2)
                            etoroStatCell("All Time", pctString(trader.perf.allTime), subtitle: "total return",
                                          color: trader.perf.allTime >= 0 ? Theme.gain : Theme.loss)
                        }
                    }

                    if !trader.tradeHistory.isEmpty {
                        Text("TRADE HISTORY")
                            .font(.system(size: 10, weight: .black)).foregroundStyle(Theme.text3).kerning(2.0)
                            .padding(.top, 22).padding(.bottom, 10)
                        VStack(spacing: 0) {
                            ForEach(Array(trader.tradeHistory.enumerated()), id: \.element.id) { i, trade in
                                HStack(spacing: 12) {
                                    Text(trade.action)
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundStyle(trade.action == "BUY" ? Theme.gain : Theme.loss)
                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                        .background((trade.action == "BUY" ? Theme.gain : Theme.loss).opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 6)).frame(width: 48)
                                    Text(trade.ticker).font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.text)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("\(trade.daysHeld)d held").font(.system(size: 11)).foregroundStyle(Theme.text3)
                                        Text(trade.date).font(.system(size: 10)).foregroundStyle(Theme.text4)
                                    }
                                    Spacer()
                                    Text(pctString(trade.pct))
                                        .font(.system(size: 14, weight: .black))
                                        .foregroundStyle(trade.pct >= 0 ? Theme.gain : Theme.loss).monospacedDigit()
                                }
                                .padding(.horizontal, 14).padding(.vertical, 12)
                                if i < trader.tradeHistory.count - 1 { Divider().padding(.leading, 14) }
                            }
                        }
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("RETURNS COMPARISON")
                            .font(.system(size: 10, weight: .bold)).foregroundStyle(Theme.text3).kerning(1.3).padding(.top, 24)
                        HStack(spacing: 6) {
                            ForEach(ReturnsPeriod.allCases, id: \.self) { period in
                                Button { selectedPeriod = period } label: {
                                    Text(period.rawValue)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(selectedPeriod == period ? .white : Theme.text3)
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(selectedPeriod == period ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.card))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        VStack(spacing: 0) {
                            returnsTableHeader()
                            Divider().background(Theme.border)
                            returnsRow(label: trader.name, todayVal: trader.perf.day, periodVal: traderReturn)
                            Divider().background(Theme.border).padding(.leading, 40)
                            returnsRow(label: "You", todayVal: appState.todayPnlPct, periodVal: youReturn)
                            Divider().background(Theme.border).padding(.leading, 40)
                            returnsRow(label: "S&P 500", todayVal: 0.8, periodVal: spReturn)
                        }
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                        returnsBarChart()
                    }

                    Text("TOP HOLDINGS")
                        .font(.system(size: 10, weight: .bold)).foregroundStyle(Theme.text3).kerning(1.3)
                        .padding(.top, 24).padding(.bottom, 10)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(trader.holdingDetails) { h in
                                Button { onTicker(h.ticker); dismiss() } label: {
                                    VStack(spacing: 4) {
                                        Text(h.ticker).font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.text)
                                        Text("\(h.pct >= 0 ? "+" : "")\(String(format: "%.1f", h.pct))%")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(h.pct >= 0 ? Theme.gain : Theme.loss)
                                    }
                                    .padding(.horizontal, 16).padding(.vertical, 12)
                                    .background(h.pct >= 0 ? Theme.gainBg : Theme.lossBg)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .stroke(h.pct >= 0 ? Theme.gain.opacity(0.25) : Theme.loss.opacity(0.25), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 4)
                    }

                    Text("RECENT POSTS")
                        .font(.system(size: 10, weight: .bold)).foregroundStyle(Theme.text3).kerning(1.3)
                        .padding(.top, 24).padding(.bottom, 10)
                    VStack(spacing: 10) {
                        if !trader.take.isEmpty { recentPostCard(text: trader.take, time: trader.time, likes: trader.likes) }
                        if !trader.text.isEmpty { recentPostCard(text: trader.text, time: "5h ago", likes: max(trader.likes - 8, 1)) }
                        recentPostCard(text: "Portfolio update: holding strong through the volatility. Conviction > panic selling.",
                                       time: "1d ago", likes: max(trader.likes - 20, 1))
                    }
                }
                .padding(.horizontal, 18).padding(.bottom, 50)
            }
        }
        .background(Theme.bg)
        .sheet(isPresented: $showCopySheet) { copyTradeSheet() }
    }

    @ViewBuilder private func profileStatItem(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 18, weight: .bold)).foregroundStyle(Theme.text)
            Text(label).font(.system(size: 10)).foregroundStyle(Theme.text3)
        }
    }

    @ViewBuilder private func returnsTableHeader() -> some View {
        HStack {
            Text("Trader").font(.system(size: 11, weight: .semibold)).foregroundStyle(Theme.text3).frame(maxWidth: .infinity, alignment: .leading)
            Text("TODAY").font(.system(size: 10, weight: .bold)).foregroundStyle(Theme.text3).kerning(0.5).frame(width: 68, alignment: .trailing)
            Text(selectedPeriod.rawValue).font(.system(size: 10, weight: .bold)).foregroundStyle(Theme.text3).kerning(0.5).frame(width: 68, alignment: .trailing)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
    }

    @ViewBuilder private func returnsRow(label: String, todayVal: Double, periodVal: Double) -> some View {
        HStack {
            Text(label).font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.text).lineLimit(1)
            Spacer()
            Text(pctString(todayVal)).font(.system(size: 13, weight: .bold))
                .foregroundStyle(todayVal >= 0 ? Theme.gain : Theme.loss).frame(width: 68, alignment: .trailing)
            Text(pctString(periodVal)).font(.system(size: 13, weight: .bold))
                .foregroundStyle(periodVal >= 0 ? Theme.gain : Theme.loss).frame(width: 68, alignment: .trailing)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
    }

    @ViewBuilder private func returnsBarChart() -> some View {
        let values = [traderReturn, youReturn, spReturn]
        let maxAbs = max(values.map { abs($0) }.max() ?? 1, 1)
        let labels = [trader.name, "You", "S&P 500"]
        let colors: [Color] = [trader.color, Theme.accent, Color(hex: "#22C55E")]
        VStack(alignment: .leading, spacing: 10) {
            ForEach(0..<3, id: \.self) { i in
                let val = values[i]
                HStack(spacing: 8) {
                    Text(labels[i]).font(.system(size: 12, weight: .semibold)).foregroundStyle(Theme.text2).frame(width: 70, alignment: .leading)
                    GeometryReader { geo in
                        let barWidth = CGFloat(abs(val) / maxAbs) * geo.size.width
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4).fill(Theme.card).frame(height: 18)
                            RoundedRectangle(cornerRadius: 4).fill(val >= 0 ? colors[i] : Theme.loss).frame(width: max(barWidth, 4), height: 18)
                        }
                    }
                    .frame(height: 18)
                    Text(pctString(val)).font(.system(size: 12, weight: .bold))
                        .foregroundStyle(val >= 0 ? Theme.gain : Theme.loss).frame(width: 52, alignment: .trailing)
                }
            }
        }
        .padding(.top, 4)
    }

    @ViewBuilder private func recentPostCard(text: String, time: String, likes: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle().fill(trader.color).frame(width: 34, height: 34)
                    .overlay(Text(trader.initial).font(.system(size: 13, weight: .black)).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 1) {
                    Text(trader.name).font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.text)
                    Text("\(trader.handle) · \(time)").font(.system(size: 11)).foregroundStyle(Theme.text3)
                }
                Spacer()
            }
            Text(text).font(.system(size: 13)).foregroundStyle(Theme.text2).fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 4) {
                Image(systemName: "heart").font(.system(size: 11)).foregroundStyle(Theme.text3)
                Text("\(likes)").font(.system(size: 11)).foregroundStyle(Theme.text3)
            }
        }
        .padding(14).background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }

    @ViewBuilder private func copyTradeSheet() -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(1...3, id: \.self) { step in
                        HStack(spacing: 0) {
                            ZStack {
                                Circle().fill(copyStep >= step ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.bg3)).frame(width: 28, height: 28)
                                Text("\(step)").font(.system(size: 12, weight: .black)).foregroundStyle(copyStep >= step ? .white : Theme.text3)
                            }
                            if step < 3 {
                                Rectangle().fill(copyStep > step ? Theme.accent : Theme.bg3).frame(height: 2).frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.horizontal, 36).padding(.vertical, 16)
                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if copyStep == 1 { copyStep1() }
                        else if copyStep == 2 { copyStep2() }
                        else { copyStep3() }
                    }
                }
                HStack(spacing: 12) {
                    if copyStep > 1 {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { copyStep -= 1 }
                        } label: {
                            Text("Back").font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.text2)
                                .frame(maxWidth: .infinity).padding(.vertical, 15)
                                .background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
                        }
                        .buttonStyle(.plain).frame(maxWidth: 100)
                    }
                    Button {
                        if copyStep < 3 {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { copyStep += 1 }
                        } else {
                            appState.toggleCopyTrade(trader.id)
                            appState.copiedAmounts[trader.id] = copyAmount
                            showCopySheet = false; copyStep = 1
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if copyStep == 3 { Image(systemName: "checkmark.circle.fill").font(.system(size: 14)) }
                            Text(copyStep == 3 ? "Confirm & Start Copying" : "Continue").font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 15)
                        .background(copyStep == 3
                            ? AnyShapeStyle(LinearGradient(colors: [Theme.gain, Color(hex: "#16A34A")], startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(Theme.accentGradient))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 18).padding(.top, 12).padding(.bottom, 34)
            }
            .background(Theme.bg)
            .navigationBarTitleDisplayMode(.inline).navigationTitle("Copy \(trader.name)")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showCopySheet = false; copyStep = 1 } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundStyle(Theme.text3)
                    }
                }
            }
        }
    }

    @ViewBuilder private func copyStep1() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(riskColor.opacity(0.15)).frame(width: 44, height: 44)
                    Text("\(trader.riskScore)").font(.system(size: 18, weight: .black)).foregroundStyle(riskColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Risk Score: \(trader.riskScore)/10").font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.text)
                    Text(trader.riskScore <= 3 ? "Low risk — suitable for conservative investors"
                       : trader.riskScore <= 6 ? "Medium risk — some volatility expected"
                       : "High risk — significant drawdowns possible")
                        .font(.system(size: 12)).foregroundStyle(Theme.text3).lineSpacing(2)
                }
            }
            .padding(14).background(riskColor.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(riskColor.opacity(0.25), lineWidth: 1))

            Text("Investment Amount").font(.system(size: 11, weight: .black)).foregroundStyle(Theme.text3).kerning(1.5)
            Text("$\(Int(copyAmount).formatted())")
                .font(.system(size: 40, weight: .black)).foregroundStyle(Theme.nanoBanana).monospacedDigit().kerning(-1)
            Slider(value: $copyAmount, in: 100...10000, step: 100).tint(Theme.nanoBanana)

            HStack(spacing: 8) {
                ForEach([500, 1000, 2500, 5000], id: \.self) { amt in
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { copyAmount = Double(amt) }
                    } label: {
                        Text("$\(amt.formatted())")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Int(copyAmount) == amt ? .white : Theme.text2)
                            .padding(.horizontal, 12).padding(.vertical, 7)
                            .background(Int(copyAmount) == amt ? Theme.accent : Theme.bg3)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Int(copyAmount) == amt ? Theme.accent : Theme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Stop Loss Protection").font(.system(size: 11, weight: .black)).foregroundStyle(Theme.text3).kerning(1.5)
                HStack {
                    Text("Stop copying if loss exceeds \(Int(stopLossPct))%").font(.system(size: 13)).foregroundStyle(Theme.text2)
                    Spacer()
                    Text("-\(Int(stopLossPct))%").font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.loss)
                }
                Slider(value: $stopLossPct, in: 5...50, step: 5).tint(Theme.loss)
            }
            .padding(14).background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill").font(.system(size: 14)).foregroundStyle(Theme.text3).padding(.top, 1)
                Text("This trader's maximum historical drawdown was \(String(format: "%.1f", trader.maxDrawdown))%. This is a portfolio tracker — no real trades are executed.")
                    .font(.system(size: 12)).foregroundStyle(Theme.text3).lineSpacing(3)
            }
            .padding(12).background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
        }
        .padding(18)
    }

    @ViewBuilder private func copyStep2() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Portfolio Breakdown").font(.system(size: 16, weight: .black)).foregroundStyle(Theme.text)
            Text("How $\(Int(copyAmount).formatted()) splits across \(trader.name)'s holdings").font(.system(size: 13)).foregroundStyle(Theme.text3)
            let total = Double(trader.holdingDetails.count)
            VStack(spacing: 0) {
                ForEach(Array(trader.holdingDetails.enumerated()), id: \.element.id) { i, h in
                    let portion = copyAmount / total
                    HStack(spacing: 12) {
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 3).fill(Theme.bg3)
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(LinearGradient(colors: [Theme.nanoBanana, Color(hex: "#A8D020")], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * CGFloat(1.0 / total))
                                }
                        }
                        .frame(height: 6).frame(width: 60)
                        Text(h.ticker).font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.text).frame(width: 54, alignment: .leading)
                        Spacer()
                        Text("$\(Int(portion).formatted())").font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.text).monospacedDigit()
                        Text(pctString(h.pct)).font(.system(size: 12, weight: .bold))
                            .foregroundStyle(h.pct >= 0 ? Theme.gain : Theme.loss).frame(width: 56, alignment: .trailing).monospacedDigit()
                    }
                    .padding(.horizontal, 16).padding(.vertical, 13)
                    if i < trader.holdingDetails.count - 1 { Divider().padding(.leading, 16) }
                }
            }
            .background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))

            HStack {
                Text("Total investment").font(.system(size: 14)).foregroundStyle(Theme.text2)
                Spacer()
                Text("$\(Int(copyAmount).formatted())").font(.system(size: 16, weight: .black)).foregroundStyle(Theme.nanoBanana)
            }
            .padding(14).background(Theme.nanoBananaBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.nanoBanana.opacity(0.3), lineWidth: 1))
        }
        .padding(18)
    }

    @ViewBuilder private func copyStep3() -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(LinearGradient(colors: [Theme.gain.opacity(0.25), Theme.gain.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    Image(systemName: "doc.on.doc.fill").font(.system(size: 32, weight: .semibold)).foregroundStyle(Theme.gain)
                }
                Text("Ready to copy \(trader.name)").font(.system(size: 20, weight: .black)).foregroundStyle(Theme.text).multilineTextAlignment(.center)
                Text("You're about to mirror $\(Int(copyAmount).formatted()) across \(trader.holdingDetails.count) positions. Stop-loss set at -\(Int(stopLossPct))%.")
                    .font(.system(size: 14)).foregroundStyle(Theme.text3).multilineTextAlignment(.center).lineSpacing(4)
            }
            .padding(24).background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.gain.opacity(0.25), lineWidth: 1))

            VStack(spacing: 0) {
                confirmRow("Investment", "$\(Int(copyAmount).formatted())", Theme.nanoBanana)
                Divider().padding(.leading, 16)
                confirmRow("Win Rate", "\(String(format: "%.1f", trader.winRate))%", Theme.gain)
                Divider().padding(.leading, 16)
                confirmRow("Max Drawdown (hist.)", "\(String(format: "%.1f", trader.maxDrawdown))%", Theme.loss)
                Divider().padding(.leading, 16)
                confirmRow("Stop-Loss", "-\(Int(stopLossPct))%", Theme.text2)
            }
            .background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
        }
        .padding(18)
    }

    @ViewBuilder private func confirmRow(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundStyle(Theme.text2)
            Spacer()
            Text(value).font(.system(size: 14, weight: .bold)).foregroundStyle(color)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
    }

    private func pctString(_ v: Double) -> String {
        "\(v >= 0 ? "+" : "")\(String(format: "%.1f", v))%"
    }

    @ViewBuilder private func etoroStatCell(_ label: String, _ value: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 9, weight: .bold)).foregroundStyle(Theme.text3).textCase(.uppercase).kerning(0.5)
            Text(value).font(.system(size: 18, weight: .black)).foregroundStyle(color).monospacedDigit().lineLimit(1).minimumScaleFactor(0.7)
            Text(subtitle).font(.system(size: 9)).foregroundStyle(Theme.text4).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(10)
        .background(color.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.18), lineWidth: 1))
    }
}

// MARK: - Discover Feed Section

struct DiscoverFeedSection: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void
    @State private var commentsItem: DiscoverItem? = nil
    @State private var showTagSheet = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.nanoBanana)
                Text("Discover").font(.system(size: 11, weight: .black)).foregroundStyle(Theme.text3).textCase(.uppercase).kerning(2.0)
                Spacer()
                Text("\(DISCOVER_ITEMS.count) items").font(.system(size: 10)).foregroundStyle(Theme.text4)
            }
            .padding(.horizontal, 18).padding(.top, 8)

            ForEach(Array(DISCOVER_ITEMS.enumerated()), id: \.element.id) { i, item in
                Group {
                    switch item.type {
                    case .short:
                        DiscoverShortCard(item: item, onTicker: onTicker, onComments: { commentsItem = item }, onTag: { showTagSheet = true })
                    case .video:
                        DiscoverVideoCard(item: item, onTicker: onTicker, onComments: { commentsItem = item }, onTag: { showTagSheet = true })
                    case .post:
                        DiscoverPostCard(item: item, onTicker: onTicker, onComments: { commentsItem = item }, onTag: { showTagSheet = true })
                    }
                }
                .staggerEntrance(index: i)
            }
        }
        .sheet(item: $commentsItem) { item in CommentsSheet(trader: item.trader).environment(appState) }
        .alert("Tag People", isPresented: $showTagSheet) { Button("OK", role: .cancel) {} }
        message: { Text("Tagging is coming in a future update.") }
    }
}

// MARK: - Short Card

struct DiscoverShortCard: View {
    @Environment(AppState.self) var appState
    let item: DiscoverItem
    let onTicker: (String) -> Void
    let onComments: () -> Void
    let onTag: () -> Void
    @State private var liked = false
    @State private var likeCount: Int
    @State private var appeared = false

    init(item: DiscoverItem, onTicker: @escaping (String) -> Void,
         onComments: @escaping () -> Void, onTag: @escaping () -> Void) {
        self.item = item; self.onTicker = onTicker; self.onComments = onComments; self.onTag = onTag
        self._likeCount = State(initialValue: item.saves)
    }

    var isSaved: Bool { appState.savedItems.contains(item.id) }

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: item.gradientColors.isEmpty ? [Color(hex: "#1A1A2E"), Color(hex: "#16213E"), Color(hex: "#0F3460")] : item.gradientColors,
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(height: 440)
                .overlay(alignment: .topLeading) {
                    HStack(spacing: 8) {
                        Text("SHORT").font(.system(size: 9, weight: .black)).foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4).background(.ultraThinMaterial.opacity(0.6)).clipShape(Capsule())
                        if let dur = item.duration { Text(dur).font(.system(size: 9, weight: .bold)).foregroundStyle(.white.opacity(0.8)) }
                    }
                    .padding(14)
                }
                .overlay(alignment: .center) { shortVisualOverlay() }

            LinearGradient(
                stops: [.init(color: .clear, location: 0), .init(color: .black.opacity(0.15), location: 0.25),
                        .init(color: .black.opacity(0.55), location: 0.55), .init(color: .black.opacity(0.82), location: 1)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 260)

            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 10) {
                        Circle().fill(item.trader.color).frame(width: 34, height: 34)
                            .overlay(Text(item.trader.initial).font(.system(size: 13, weight: .black)).foregroundStyle(.white))
                            .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 5) {
                                Text(item.trader.name).font(.system(size: 13, weight: .bold)).foregroundStyle(.white).shadow(color: .black.opacity(0.6), radius: 3)
                                if item.trader.isPro {
                                    Text("PRO").font(.system(size: 8, weight: .black)).foregroundStyle(Theme.nanoBanana)
                                        .padding(.horizontal, 5).padding(.vertical, 2).background(Theme.nanoBanana.opacity(0.18)).clipShape(Capsule())
                                }
                            }
                            Text("\(item.trader.handle) · \(formatViews(item.views)) views")
                                .font(.system(size: 10)).foregroundStyle(.white.opacity(0.65)).shadow(color: .black.opacity(0.5), radius: 2)
                        }
                        Spacer(minLength: 0)
                    }
                    Text(item.trader.todayPct.fmtPct()).font(.system(size: 13, weight: .black)).foregroundStyle(.white)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background((item.trader.todayPct >= 0 ? Theme.gain : Theme.loss).opacity(0.9)).clipShape(Capsule())
                        .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                    Text(item.caption).font(.system(size: 13)).foregroundStyle(.white.opacity(0.95))
                        .lineSpacing(3).lineLimit(3).fixedSize(horizontal: false, vertical: true).shadow(color: .black.opacity(0.7), radius: 3)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(item.tickers, id: \.self) { t in
                                Button { onTicker(t) } label: {
                                    Text(t).font(.system(size: 11, weight: .bold)).foregroundStyle(Theme.nanoBanana)
                                        .padding(.horizontal, 9).padding(.vertical, 4).background(.black.opacity(0.30)).clipShape(Capsule())
                                        .overlay(Capsule().stroke(Theme.nanoBanana.opacity(0.6), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.leading, 16).padding(.bottom, 22).frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 20) {
                    shortActionButton(icon: liked ? "heart.fill" : "heart", label: formatViews(likeCount + (liked ? 1 : 0)),
                                       color: liked ? Color(hex: "#F43F5E") : .white) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { liked.toggle() }
                    }
                    shortActionButton(icon: "bubble.left.fill", label: "\(item.comments)", color: .white, action: onComments)
                    ShareLink(item: "Check out this trade idea on STALK: \(item.caption.prefix(80))...") {
                        VStack(spacing: 4) {
                            Image(systemName: "arrowshape.turn.up.right.fill").font(.system(size: 26, weight: .semibold)).foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.7), radius: 5, y: 2)
                            Text("Share").font(.system(size: 10, weight: .semibold)).foregroundStyle(.white.opacity(0.85)).shadow(color: .black.opacity(0.6), radius: 3)
                        }
                    }
                    .buttonStyle(.plain)
                    shortActionButton(icon: isSaved ? "bookmark.fill" : "bookmark", label: "Save", color: isSaved ? Theme.nanoBanana : .white) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            if isSaved { appState.savedItems.remove(item.id) } else { appState.savedItems.insert(item.id) }
                        }
                    }
                    shortActionButton(icon: "person.badge.plus.fill", label: "Tag", color: .white, action: onTag)
                }
                .padding(.trailing, 14).padding(.bottom, 22)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20)).shadow(color: .black.opacity(0.5), radius: 16, y: 6)
        .padding(.horizontal, 14).opacity(appeared ? 1 : 0).scaleEffect(appeared ? 1 : 0.96)
        .onAppear { withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { appeared = true } }
    }

    @ViewBuilder private func shortActionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 26, weight: .semibold)).foregroundStyle(color).shadow(color: .black.opacity(0.7), radius: 5, y: 2)
                Text(label).font(.system(size: 10, weight: .semibold)).foregroundStyle(.white.opacity(0.9)).shadow(color: .black.opacity(0.6), radius: 3)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private func shortVisualOverlay() -> some View {
        GeometryReader { _ in
            Canvas { ctx, size in
                let w = size.width; let h = size.height
                var path = Path()
                let amplitude: CGFloat = 28; let freq: CGFloat = 0.018; let midY = h * 0.42
                path.move(to: CGPoint(x: 0, y: midY))
                for x in stride(from: 0, to: w, by: 2) {
                    path.addLine(to: CGPoint(x: x, y: midY + sin(x * freq) * amplitude + cos(x * freq * 0.7) * 14))
                }
                ctx.stroke(path, with: .color(.white.opacity(0.08)), lineWidth: 2)
                var path2 = Path()
                let midY2 = h * 0.60
                path2.move(to: CGPoint(x: 0, y: midY2))
                for x in stride(from: 0, to: w, by: 2) {
                    path2.addLine(to: CGPoint(x: x, y: midY2 + sin(x * freq * 1.3 + 1.2) * 20 + cos(x * freq * 0.5 + 0.8) * 10))
                }
                ctx.stroke(path2, with: .color(.white.opacity(0.05)), lineWidth: 1.5)
            }
        }
        .allowsHitTesting(false)
    }

    private func formatViews(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n)/1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n)/1_000) }
        return "\(n)"
    }
}

// MARK: - Video Card

struct DiscoverVideoCard: View {
    @Environment(AppState.self) var appState
    let item: DiscoverItem
    let onTicker: (String) -> Void
    let onComments: () -> Void
    let onTag: () -> Void
    @State private var liked = false
    var isSaved: Bool { appState.savedItems.contains(item.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: item.gradientColors.isEmpty ? [Color(hex: "#0F172A"), Color(hex: "#1E293B")] : item.gradientColors,
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(height: 210)
                    .overlay(alignment: .center) {
                        ZStack {
                            Circle().fill(.black.opacity(0.4)).frame(width: 56, height: 56).overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
                            Image(systemName: "play.fill").font(.system(size: 22, weight: .semibold)).foregroundStyle(.white).offset(x: 2)
                        }
                    }
                    .overlay(alignment: .topLeading) {
                        Text("VIDEO").font(.system(size: 9, weight: .black)).foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4).background(.black.opacity(0.5)).clipShape(Capsule()).padding(12)
                    }
                if let dur = item.duration {
                    Text(dur).font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 4).background(.black.opacity(0.65)).clipShape(RoundedRectangle(cornerRadius: 6)).padding(10)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

            HStack(alignment: .top, spacing: 12) {
                Circle().fill(item.trader.color).frame(width: 38, height: 38)
                    .overlay(Text(item.trader.initial).font(.system(size: 14, weight: .black)).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.caption).font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.text).lineLimit(2).lineSpacing(3)
                    HStack(spacing: 5) { Text(item.trader.handle); Text("·"); Text(formatViews(item.views) + " views") }
                        .font(.system(size: 11)).foregroundStyle(Theme.text3)
                    HStack(spacing: 5) {
                        ForEach(item.tickers, id: \.self) { t in
                            Button { onTicker(t) } label: {
                                Text(t).font(.system(size: 10, weight: .bold)).foregroundStyle(Theme.accent)
                                    .padding(.horizontal, 8).padding(.vertical, 3).background(Theme.accentBg).clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 2)
                }
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        if isSaved { appState.savedItems.remove(item.id) } else { appState.savedItems.insert(item.id) }
                    }
                } label: {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .semibold)).foregroundStyle(isSaved ? Theme.nanoBanana : Theme.text3)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4).padding(.top, 12)

            Divider().padding(.top, 10)
            HStack(spacing: 0) {
                videoAction(liked ? "heart.fill" : "heart", "\(item.saves + (liked ? 1 : 0))", liked ? Color(hex: "#F43F5E") : Theme.text3) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { liked.toggle() }
                }
                videoAction("bubble.left.fill", "\(item.comments)", Theme.text3, action: onComments)
                videoAction("arrowshape.turn.up.right.fill", "Share", Theme.text3) {}
                videoAction("person.badge.plus.fill", "Tag", Theme.text3, action: onTag)
            }
            .padding(.top, 4)
        }
        .padding(14).background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 10, y: 4).padding(.horizontal, 14)
    }

    @ViewBuilder private func videoAction(_ icon: String, _ label: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundStyle(color)
                Text(label).font(.system(size: 12, weight: .semibold)).foregroundStyle(color)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private func formatViews(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n)/1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n)/1_000) }
        return "\(n)"
    }
}

// MARK: - Discover Post Card

struct DiscoverPostCard: View {
    @Environment(AppState.self) var appState
    let item: DiscoverItem
    let onTicker: (String) -> Void
    let onComments: () -> Void
    let onTag: () -> Void
    @State private var liked = false
    var isSaved: Bool { appState.savedItems.contains(item.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Circle()
                    .fill(LinearGradient(colors: [item.trader.color, item.trader.color.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 42, height: 42)
                    .overlay(Text(item.trader.initial).font(.system(size: 16, weight: .black)).foregroundStyle(.white))
                    .shadow(color: item.trader.color.opacity(0.4), radius: 5, y: 2)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(item.trader.name).font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.text)
                        if item.trader.isPro {
                            Text("PRO").font(.system(size: 9, weight: .black)).foregroundStyle(Theme.accent)
                                .padding(.horizontal, 5).padding(.vertical, 2).background(Theme.accentBg).clipShape(Capsule())
                        }
                    }
                    Text("\(item.trader.handle) · \(formatViews(item.views)) views").font(.system(size: 12)).foregroundStyle(Theme.text3)
                }
                Spacer()
                Text(item.trader.todayPct.fmtPct()).font(.system(size: 14, weight: .black)).foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background((item.trader.todayPct >= 0 ? Theme.gain : Theme.loss).opacity(0.88)).clipShape(Capsule())
            }
            .padding(.horizontal, 16).padding(.top, 16)

            Text(item.caption).font(.system(size: 15)).foregroundStyle(Theme.text).lineSpacing(5)
                .padding(.horizontal, 16).padding(.vertical, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(item.tickers, id: \.self) { t in
                        Button { onTicker(t) } label: {
                            Text(t).font(.system(size: 11, weight: .bold)).foregroundStyle(Theme.accent)
                                .padding(.horizontal, 10).padding(.vertical, 5).background(Theme.accentBg).clipShape(Capsule())
                                .overlay(Capsule().stroke(Theme.accent.opacity(0.3), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 10)

            Divider().overlay(Theme.border)
            HStack(spacing: 0) {
                postDiscoverAction(liked ? "heart.fill" : "heart", "\(item.saves + (liked ? 1 : 0))", liked ? Color(hex: "#F43F5E") : Theme.text3) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { liked.toggle() }
                }
                postDiscoverAction("bubble.left.fill", "\(item.comments)", Theme.text3, action: onComments)
                ShareLink(item: "Check out this trade idea on STALK: \(item.caption.prefix(80))...") {
                    HStack(spacing: 5) {
                        Image(systemName: "arrowshape.turn.up.right.fill").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.text3)
                        Text("Share").font(.system(size: 12, weight: .semibold)).foregroundStyle(Theme.text3)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                postDiscoverAction(isSaved ? "bookmark.fill" : "bookmark", "Save", isSaved ? Theme.nanoBanana : Theme.text3) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        if isSaved { appState.savedItems.remove(item.id) } else { appState.savedItems.insert(item.id) }
                    }
                }
                postDiscoverAction("person.badge.plus.fill", "Tag", Theme.text3, action: onTag)
            }
            .padding(.horizontal, 8).padding(.vertical, 2)
        }
        .background(Theme.card).clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 10, y: 4).padding(.horizontal, 14)
    }

    @ViewBuilder private func postDiscoverAction(_ icon: String, _ label: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 13, weight: .semibold)).foregroundStyle(color)
                Text(label).font(.system(size: 11, weight: .semibold)).foregroundStyle(color)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    private func formatViews(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n)/1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n)/1_000) }
        return "\(n)"
    }
}

// MARK: - Comments Sheet

struct CommentsSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    let trader: Trader
    @State private var replyText = ""

    private let mockComments: [Comment] = [
        Comment(authorName: "Priya N.", authorHandle: "@priyainvests", text: "Totally agree — NVDA has so much runway left with the data center buildout.", likes: 14, timeAgo: "1h ago"),
        Comment(authorName: "David K.", authorHandle: "@davidk_trades", text: "I've been saying this for months. AI infrastructure is just getting started.", likes: 8, timeAgo: "2h ago"),
        Comment(authorName: "Nina H.",  authorHandle: "@ninaHTrades",   text: "Added 50 more shares after reading this. Let's go!", likes: 5, timeAgo: "3h ago"),
        Comment(authorName: "James T.", authorHandle: "@jtrades",       text: "Risk/reward looks amazing at current levels. Nice call.", likes: 21, timeAgo: "4h ago"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Circle().fill(trader.color).frame(width: 38, height: 38)
                        .overlay(Text(trader.initial).font(.system(size: 14, weight: .black)).foregroundStyle(.white))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trader.name).font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.text)
                        Text(trader.take.isEmpty ? trader.text : trader.take).font(.system(size: 12)).foregroundStyle(Theme.text3).lineLimit(2)
                    }
                    Spacer()
                }
                .padding(14).background(Theme.card)
                Divider()
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(mockComments) { comment in
                            CommentRow(comment: comment)
                            Divider().padding(.leading, 66)
                        }
                    }
                }
                HStack(spacing: 10) {
                    Circle().fill(Theme.accentGradient).frame(width: 34, height: 34)
                        .overlay(Text(String(appState.settings.displayName.prefix(1)).uppercased()).font(.system(size: 13, weight: .black)).foregroundStyle(.white))
                    HStack {
                        TextField("Add a comment…", text: $replyText).font(.system(size: 14)).foregroundStyle(Theme.text)
                        if !replyText.isEmpty {
                            Button { replyText = "" } label: {
                                Image(systemName: "paperplane.fill").font(.system(size: 16, weight: .semibold)).foregroundStyle(Theme.accent)
                            }
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10).background(Theme.bg3).clipShape(Capsule())
                    .overlay(Capsule().stroke(Theme.border, lineWidth: 1))
                }
                .padding(.horizontal, 16).padding(.vertical, 12).background(Theme.card)
                .overlay(Rectangle().fill(Theme.border).frame(height: 1), alignment: .top)
            }
            .background(Theme.bg).navigationTitle("Comments").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 22)).foregroundStyle(Theme.text3)
                    }
                }
            }
        }
    }
}

struct CommentRow: View {
    let comment: Comment
    @State private var liked = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().fill(Theme.accentBg).frame(width: 38, height: 38)
                .overlay(Text(String(comment.authorName.prefix(1))).font(.system(size: 14, weight: .black)).foregroundStyle(Theme.accent))
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(comment.authorName).font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.text)
                    Text(comment.authorHandle).font(.system(size: 12)).foregroundStyle(Theme.text3)
                    Spacer()
                    Text(comment.timeAgo).font(.system(size: 11)).foregroundStyle(Theme.text4)
                }
                Text(comment.text).font(.system(size: 13)).foregroundStyle(Theme.text2).lineSpacing(3)
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { liked.toggle() }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: liked ? "heart.fill" : "heart").font(.system(size: 11))
                            .foregroundStyle(liked ? Theme.loss : Theme.text3)
                        Text("\(comment.likes + (liked ? 1 : 0))").font(.system(size: 11))
                            .foregroundStyle(liked ? Theme.loss : Theme.text3)
                    }
                }
                .buttonStyle(.plain).padding(.top, 2)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
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
            HStack(alignment: .top, spacing: 12) {
                Circle().fill(Theme.accentGradient).frame(width: 46, height: 46)
                    .overlay(Text(String(appState.settings.displayName.prefix(1)).uppercased()).font(.system(size: 18, weight: .black)).foregroundStyle(.white))
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(appState.settings.displayName).font(.system(size: 15, weight: .bold)).foregroundStyle(Theme.text)
                        Text("YOU").font(.system(size: 9, weight: .black)).foregroundStyle(Theme.accent)
                            .padding(.horizontal, 5).padding(.vertical, 2).background(Theme.accentBg).clipShape(Capsule())
                    }
                    Text("\(appState.settings.username) · \(timeAgo)").font(.system(size: 13)).foregroundStyle(Theme.text3)
                }
                Spacer()
                Text(post.sentiment).font(.system(size: 12, weight: .bold)).foregroundStyle(sentimentColor)
                    .padding(.horizontal, 10).padding(.vertical, 5).background(sentimentColor.opacity(0.12)).clipShape(Capsule())
            }
            .padding(.horizontal, 16).padding(.top, 14)

            Text(post.text).font(.system(size: 16)).foregroundStyle(Theme.text).lineSpacing(6)
                .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 6)

            if !post.tickers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(post.tickers, id: \.self) { ticker in
                            Button { onTicker(ticker) } label: {
                                Text(ticker).font(.system(size: 12, weight: .bold).monospaced()).foregroundStyle(Theme.text2)
                                    .padding(.horizontal, 10).padding(.vertical, 5).background(Theme.bg3).clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 8)
                }
            }

            HStack(spacing: 0) {
                HStack(spacing: 5) {
                    Image(systemName: "heart").font(.system(size: 16, weight: .semibold)).foregroundStyle(Theme.text3)
                    Text("0").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.text3)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                HStack(spacing: 5) {
                    Image(systemName: "bubble.left").font(.system(size: 16, weight: .semibold)).foregroundStyle(Theme.text3)
                    Text("0").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.text3)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
            }
            .padding(.top, 4).padding(.bottom, 6)
        }
    }
}
