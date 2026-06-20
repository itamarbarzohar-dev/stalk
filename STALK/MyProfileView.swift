import SwiftUI

// MARK: - MyProfileView

struct MyProfileView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    @State private var showSettings = false
    @State private var showCreatePost = false
    @State private var showShareSheet = false
    @State private var selectedTab: ProfileTab = .posts

    enum ProfileTab: String, CaseIterable {
        case posts = "Posts"
        case portfolio = "Portfolio"
        case about = "About"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Theme.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        profileHeader
                        statsRow
                        actionButtons
                        tabBar
                        tabContent
                        Color.clear.frame(height: 100)
                    }
                }

                // Floating compose FAB — only on Posts tab
                if selectedTab == .posts {
                    composeFAB
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environment(appState)
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView().environment(appState)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: ["Check out my STALK profile: https://stalk.app/@\(appState.settings.username.replacingOccurrences(of: "@", with: ""))"])
        }
    }

    // MARK: - Profile Header

    var profileHeader: some View {
        ZStack(alignment: .bottom) {
            // Cover gradient
            appState.heroGradient
                .frame(height: 180)
                .overlay(alignment: .topLeading) {
                    // Navigation bar overlaid on cover
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Back")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.18))
                            .clipShape(Capsule())
                        }
                        Spacer()
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(.white.opacity(0.18))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 52)
                }

            // Avatar overlapping cover bottom
            HStack(alignment: .bottom) {
                avatarCircle
                    .offset(y: 40)
                    .padding(.leading, 20)
                Spacer()
            }
        }
        .padding(.bottom, 40)

        // Name / username / bio below avatar area
        .overlay(alignment: .bottomLeading) {
            EmptyView()
        }
    }

    var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#4B4ACF"), Color(hex: "#8B7CF6")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)

            Text(String(appState.settings.displayName.prefix(1)).uppercased())
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(.white)
        }
        .overlay(
            Circle()
                .stroke(Theme.bg, lineWidth: 4)
        )
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    }

    // MARK: - Identity Block

    var identityBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                Text(appState.settings.displayName)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(Theme.text)

                if appState.settings.isPro {
                    Text("PRO")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.gold.opacity(0.15))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.gold.opacity(0.4), lineWidth: 1))
                }
            }

            Text(appState.settings.username)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.text3)

            if !appState.settings.bio.isEmpty {
                Text(appState.settings.bio)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.text2)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Stats Row

    var statsRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Identity (name, username, bio) rendered here after avatar offset settles
            identityBlock
                .padding(.bottom, 16)

            HStack(spacing: 0) {
                profileStat(value: "\(appState.userPosts.count)", label: "Posts")
                    .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 30)
                    .background(Theme.border)

                profileStat(value: "\(appState.followed.count)", label: "Following")
                    .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 30)
                    .background(Theme.border)

                profileStat(value: "128", label: "Followers")
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
            .padding(.horizontal, 16)
        }
    }

    func profileStat(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Theme.text)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.text3)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Action Buttons

    var actionButtons: some View {
        HStack(spacing: 10) {
            Button {
                showSettings = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Edit Profile")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Button {
                showShareSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Share Profile")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    // MARK: - Tab Bar

    var tabBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(ProfileTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: selectedTab == tab ? .black : .semibold))
                                .foregroundStyle(selectedTab == tab ? Theme.text : Theme.text3)
                                .frame(maxWidth: .infinity)

                            Rectangle()
                                .fill(selectedTab == tab ? appState.accentColor : Color.clear)
                                .frame(height: 2)
                                .clipShape(Capsule())
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)

            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
        }
        .padding(.bottom, 4)
    }

    // MARK: - Tab Content

    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case .posts:
            postsTab
        case .portfolio:
            portfolioTab
        case .about:
            aboutTab
        }
    }

    // MARK: - Compose FAB

    var composeFAB: some View {
        Button {
            showCreatePost = true
        } label: {
            Image(systemName: "pencil")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(appState.accentGradient)
                .clipShape(Circle())
                .shadow(color: appState.accentColor.opacity(0.45), radius: 12, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 104)
    }
}

// MARK: - Posts Tab

private extension MyProfileView {

    var postsTab: some View {
        VStack(spacing: 12) {
            if appState.userPosts.isEmpty {
                postsEmptyState
            } else {
                ForEach(appState.userPosts) { post in
                    UserPostCard(post: post)
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.top, 12)
    }

    var postsEmptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Theme.text4)

            VStack(spacing: 6) {
                Text("No posts yet")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.text)
                Text("Share your market takes and\nticker analysis with the community.")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.text2)
                    .multilineTextAlignment(.center)
            }

            Button {
                showCreatePost = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("Create First Post")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background(appState.accentGradient)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 60)
        .padding(.horizontal, 32)
    }
}

// MARK: - Portfolio Tab

private extension MyProfileView {

    var portfolioTab: some View {
        VStack(spacing: 12) {
            performanceHeaderCard
                .padding(.horizontal, 16)

            if appState.positions.isEmpty {
                portfolioEmptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(appState.positions.enumerated()), id: \.element.id) { index, position in
                        PositionRow(position: position, appState: appState)

                        if index < appState.positions.count - 1 {
                            Divider()
                                .padding(.horizontal, 16)
                                .background(Theme.border)
                        }
                    }
                }
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 12)
    }

    var performanceHeaderCard: some View {
        VStack(spacing: 14) {
            HStack {
                Text("PORTFOLIO PERFORMANCE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.text3)
                    .tracking(1.3)
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(appState.totalValue.fmtPrice())
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(Theme.text)
                    .monospacedDigit()

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    let pnl = appState.totalPnl
                    let pct = appState.totalPnlPct
                    let isUp = pnl >= 0

                    Text(pnl.fmtChange())
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(isUp ? Theme.gain : Theme.loss)
                        .monospacedDigit()

                    Text(pct.fmtPct())
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isUp ? Theme.gain : Theme.loss)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background((isUp ? Theme.gain : Theme.loss).opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
    }

    var portfolioEmptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.pie")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Theme.text4)

            VStack(spacing: 6) {
                Text("No positions yet")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.text)
                Text("Add your first stock to track\nyour portfolio performance.")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.text2)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 50)
        .padding(.horizontal, 32)
    }
}

// MARK: - About Tab

private extension MyProfileView {

    var aboutTab: some View {
        VStack(spacing: 14) {
            bioSection
            statsSection
            memberSection
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    var bioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BIO")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .tracking(1.3)

            if appState.settings.bio.isEmpty {
                Text("No bio yet. Tap Edit Profile to add one.")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.text3)
                    .italic()
            } else {
                Text(appState.settings.bio)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.text2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
    }

    var statsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("STATS")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .tracking(1.3)
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
                .padding(.top, 14)

            aboutStatRow(icon: "chart.line.uptrend.xyaxis", label: "Total Return",
                         value: appState.totalPnlPct.fmtPct(),
                         color: appState.totalPnlPct >= 0 ? Theme.gain : Theme.loss)

            Divider().padding(.horizontal, 16).background(Theme.border)

            aboutStatRow(icon: "dollarsign.circle.fill", label: "Portfolio Value",
                         value: appState.totalValue.fmtPrice(),
                         color: Theme.text)

            Divider().padding(.horizontal, 16).background(Theme.border)

            aboutStatRow(icon: "flame.fill", label: "Login Streak",
                         value: "\(appState.streak) days",
                         color: Color(hex: "#F97316"))

            Divider().padding(.horizontal, 16).background(Theme.border)

            aboutStatRow(icon: "calendar", label: "Member Since",
                         value: "June 2026",
                         color: Theme.text3)

            Divider().padding(.horizontal, 16).background(Theme.border)

            aboutStatRow(icon: "paintpalette.fill", label: "Theme",
                         value: appState.currentTheme.label,
                         color: appState.accentColor)

            Divider().padding(.horizontal, 16).background(Theme.border)

            let privacyLabel: String = {
                switch appState.settings.privacy {
                case "private": return "Private"
                case "percent": return "Public (% only)"
                default:        return "Public"
                }
            }()

            aboutStatRow(icon: "lock.shield.fill", label: "Privacy",
                         value: privacyLabel,
                         color: Theme.text3)
                .padding(.bottom, 6)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
    }

    var memberSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#4B4ACF"), Color(hex: "#8B7CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)

                Text(String(appState.settings.displayName.prefix(1)).uppercased())
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(appState.settings.displayName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.text)
                Text(appState.settings.username)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text3)
            }

            Spacer()

            if appState.settings.isPro {
                Text("PRO")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Theme.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.gold.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Theme.gold.opacity(0.35), lineWidth: 1))
            }
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
    }

    func aboutStatRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(color)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.text2)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

// MARK: - UserPostCard

private struct UserPostCard: View {
    let post: UserPost

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: sentiment + time
            HStack(spacing: 8) {
                sentimentBadge(post.sentiment)

                Spacer()

                Text(timeAgo(post.timestamp))
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
            }

            // Post text
            Text(post.text)
                .font(.system(size: 15))
                .foregroundStyle(Theme.text)
                .fixedSize(horizontal: false, vertical: true)

            // Ticker chips
            if !post.tickers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(post.tickers, id: \.self) { ticker in
                            Text("$\(ticker)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.accent)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(Theme.accent.opacity(0.1))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Theme.accent.opacity(0.25), lineWidth: 1))
                        }
                    }
                }
            }

            // Bottom bar: like + comment counts
            HStack(spacing: 16) {
                Label("0", systemImage: "heart")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.text3)

                Label("0", systemImage: "bubble.left")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.text3)

                Spacer()
            }
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
    }

    func sentimentBadge(_ sentiment: String) -> some View {
        let (label, color): (String, Color) = {
            switch sentiment {
            case "Bullish": return ("Bullish", Theme.gain)
            case "Bearish": return ("Bearish", Theme.loss)
            default:        return ("Neutral", Theme.accent)
            }
        }()

        return Text(label)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
    }

    func timeAgo(_ date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "Just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        if days < 7 { return "\(days)d ago" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - PositionRow

private struct PositionRow: View {
    let position: Position
    let appState: AppState

    var price: Double { appState.quotes[position.ticker]?.price ?? position.avgCost }
    var value: Double { price * position.shares }
    var cost: Double { position.avgCost * position.shares }
    var pnl: Double { value - cost }
    var pnlPct: Double { cost > 0 ? (pnl / cost) * 100 : 0 }
    var isUp: Bool { pnl >= 0 }
    var changePercent: Double { appState.quotes[position.ticker]?.changePercent ?? 0 }

    var body: some View {
        HStack(spacing: 12) {
            // Ticker avatar
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.accent.opacity(0.12))
                    .frame(width: 42, height: 42)

                Text(String(position.ticker.prefix(2)))
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(Theme.accent)
            }

            // Ticker + shares
            VStack(alignment: .leading, spacing: 3) {
                Text(position.ticker)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.text)
                Text("\(String(format: "%.4g", position.shares)) shares")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text3)
            }

            Spacer()

            // Value + P&L
            VStack(alignment: .trailing, spacing: 3) {
                Text(value.fmtPrice())
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.text)
                    .monospacedDigit()

                Text(pnlPct.fmtPct())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isUp ? Theme.gain : Theme.loss)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

// MARK: - ShareSheet (UIActivityViewController wrapper)

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
