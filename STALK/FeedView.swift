import SwiftUI

struct FeedView: View {
    @Environment(AppState.self) var appState
    let onTicker: (String) -> Void
    @State private var profileTrader: Trader? = nil

    var totalValue: Double { appState.totalValue }
    var totalCost: Double { appState.totalCost }
    var allTimeRet: Double { totalCost > 0 ? ((totalValue - totalCost) / totalCost) * 100 : 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // My Profile bar
                HStack(spacing: 14) {
                    Circle()
                        .fill(Theme.accentGradient)
                        .frame(width: 58, height: 58)
                        .overlay(
                            Text("I")
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(.white)
                        )
                        .shadow(color: Theme.accent.opacity(0.28), radius: 8, y: 4)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Itamar B.")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Theme.text)
                        HStack(spacing: 4) {
                            Text("@itamar ·")
                                .foregroundStyle(Theme.text3)
                            Text("PRO")
                                .foregroundStyle(Theme.accent)
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 13))

                        HStack(spacing: 24) {
                            statItem("\(12 + appState.followed.count)", "Followers")
                            statItem("\(7 + appState.followed.count)", "Following")
                            statItem("1", "Posts")
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 52)
                .padding(.bottom, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .bottom) { Divider() }

                // My performance
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

                // Holdings
                if !appState.positions.isEmpty {
                    holdingsStrip()
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                }

                Divider().padding(.vertical, 4)

                // Following label
                Text("Following")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.text3)
                    .textCase(.uppercase)
                    .kerning(1.3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)

                // Posts
                VStack(spacing: 10) {
                    ForEach(TRADERS) { trader in
                        TraderPostCard(trader: trader, onProfile: { profileTrader = trader }, onTicker: onTicker)
                    }
                }
                .padding(.horizontal, 14)

                Color.clear.frame(height: 100)
            }
        }
        .background(Theme.bg)
        .sheet(item: $profileTrader) { trader in
            TraderProfileView(trader: trader, onTicker: onTicker)
        }
    }

    func statItem(_ value: String, _ label: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Theme.text)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(0.5)
        }
    }

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

// MARK: - Trader Post Card

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
                            .background(Color(hex: "#EDEDFF"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(.bottom, 12)

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
                                .foregroundStyle(isFollowed ? .white : .white)
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
