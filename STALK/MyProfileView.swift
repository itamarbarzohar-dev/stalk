import SwiftUI

struct MyProfileView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    @State private var showSettings = false
    @State private var showCreatePost = false
    @State private var showShareSheet = false
    @State private var selectedTab: ProfileTab = .posts

    enum ProfileTab: CaseIterable {
        case posts, portfolio, about

        var icon: String {
            switch self {
            case .posts:     return "square.grid.3x3.fill"
            case .portfolio: return "chart.line.uptrend.xyaxis"
            case .about:     return "info.circle.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Theme.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        profileHeader
                        statsBar
                        actionButtons
                        tabSelector
                        tabContent
                        Color.clear.frame(height: 100)
                    }
                }

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
            ShareSheet(items: ["Check out my STALK profile: https://stalk.app/\(appState.settings.username.replacingOccurrences(of: "@", with: ""))"])
        }
    }

    var profileHeader: some View {
        ZStack(alignment: .bottom) {
            appState.heroGradient
                .frame(height: 160)
                .overlay(alignment: .topTrailing) {
                    HStack(spacing: 10) {
                        Spacer()
                        Button {
                            showShareSheet = true
                        } label: {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(.white.opacity(0.18))
                                .clipShape(Circle())
                        }
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(.white.opacity(0.18))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 52)
                }

            HStack(alignment: .bottom) {
                avatarCircle
                    .offset(y: 42)
                    .padding(.leading, 20)
                Spacer()
            }
        }
        .padding(.bottom, 42)
    }

    var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(appState.accentGradient)
                .frame(width: 84, height: 84)

            Text(String(appState.settings.displayName.prefix(1)).uppercased())
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(.white)
        }
        .overlay(
            Circle().stroke(Theme.bg, lineWidth: 4)
        )
        .overlay(alignment: .bottomTrailing) {
            if appState.settings.isPro {
                Text("PRO")
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(Theme.gold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.gold.opacity(0.18))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Theme.gold.opacity(0.5), lineWidth: 1))
                    .offset(x: 4, y: 4)
            }
        }
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    }

    var statsBar: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .center, spacing: 8) {
                    Text(appState.settings.displayName)
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(Theme.text)
                    if appState.settings.isPro {
                        Text("PRO")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Theme.gold)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Theme.gold.opacity(0.14))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Theme.gold.opacity(0.35), lineWidth: 1))
                    }
                }
                Text(appState.settings.username)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.text3)
                if !appState.settings.bio.isEmpty {
                    Text(appState.settings.bio)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.text3)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 16)

            HStack(spacing: 0) {
                statCell(value: "\(appState.userPosts.count)", label: "Posts")
                Rectangle().fill(Theme.border).frame(width: 1, height: 30)
                statCell(value: "128", label: "Followers")
                Rectangle().fill(Theme.border).frame(width: 1, height: 30)
                statCell(value: "\(appState.followed.count)", label: "Following")
                Rectangle().fill(Theme.border).frame(width: 1, height: 30)
                statCellColored(
                    value: appState.totalPnlPct >= 0
                        ? "+\(String(format: "%.1f", appState.totalPnlPct))%"
                        : "\(String(format: "%.1f", appState.totalPnlPct))%",
                    label: "Return",
                    color: appState.totalPnlPct >= 0 ? Theme.gain : Theme.loss
                )
            }
            .padding(.vertical, 12)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
            .padding(.horizontal, 16)
        }
    }

    func statCell(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Theme.text)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.text3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    func statCellColored(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(color)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.text3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

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
                showCreatePost = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                    Text("New Post")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 11)
                .background(appState.accentGradient)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    var tabSelector: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(ProfileTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: selectedTab == tab ? .bold : .regular))
                                .foregroundStyle(selectedTab == tab ? Theme.text : Theme.text4)
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
        .padding(.bottom, 2)
    }

    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case .posts:
            postsGrid
        case .portfolio:
            portfolioTab
        case .about:
            aboutTab
        }
    }

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

private extension MyProfileView {

    var postsGrid: some View {
        Group {
            if appState.userPosts.isEmpty {
                postsEmptyState
            } else {
                let screenWidth = UIScreen.main.bounds.width
                let cellSize = (screenWidth - 4) / 3
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2),
                    ],
                    spacing: 2
                ) {
                    ForEach(appState.userPosts) { post in
                        PostGridCell(post: post, size: cellSize)
                    }
                }
                .padding(.top, 2)
            }
        }
    }

    var postsEmptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Theme.text4.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: "camera.fill")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(Theme.text4)
            }
            VStack(spacing: 6) {
                Text("Share your first trade idea")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.text)
                Text("Post market takes and ticker analysis\nfor the community to see.")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.text3)
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

    var portfolioTab: some View {
        VStack(spacing: 12) {
            performanceHeaderCard
                .padding(.horizontal, 16)

            if appState.positions.isEmpty {
                portfolioEmptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(appState.positions.enumerated()), id: \.element.id) { index, position in
                        EToroPositionRow(position: position, appState: appState, total: appState.totalValue)
                        if index < appState.positions.count - 1 {
                            Rectangle()
                                .fill(Theme.border)
                                .frame(height: 1)
                                .padding(.horizontal, 16)
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

    var aboutTab: some View {
        VStack(spacing: 14) {
            bioSection
            aboutStatsSection
            riskSection
            memberCard
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    var bioSection: some View {
        VStack(alignment: .leading, spacing: 10) {
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

    var aboutStatsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("STATS")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .tracking(1.3)
                .padding(.bottom, 8)
                .padding(.horizontal, 16)
                .padding(.top, 14)

            aboutRow(icon: "calendar", label: "Member since", value: "June 2026", color: Theme.text3)
            Divider().padding(.horizontal, 16)
            aboutRow(icon: "arrow.left.arrow.right", label: "Total trades", value: "24", color: Theme.text)
            Divider().padding(.horizontal, 16)
            aboutRow(icon: "trophy.fill", label: "Best trade", value: "+41.0% TSLA", color: Theme.gain)
            Divider().padding(.horizontal, 16)
            aboutRow(icon: "checkmark.seal.fill", label: "Win rate", value: "62%", color: Theme.accent)
            Divider().padding(.horizontal, 16)
            aboutRow(icon: "flame.fill", label: "Streak", value: "\(appState.streak) days", color: Color(hex: "#F97316"))
            Divider().padding(.horizontal, 16)
            aboutRow(icon: "paintpalette.fill", label: "Theme", value: appState.currentTheme.label, color: appState.accentColor)
                .padding(.bottom, 6)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
    }

    var riskSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RISK SCORE")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .tracking(1.3)

            HStack(spacing: 0) {
                ForEach(1...10, id: \.self) { i in
                    Rectangle()
                        .fill(riskBarColor(i))
                        .frame(height: 8)
                        .clipShape(
                            i == 1
                                ? AnyShape(UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 4))
                                : i == 10
                                    ? AnyShape(UnevenRoundedRectangle(bottomTrailingRadius: 4, topTrailingRadius: 4))
                                    : AnyShape(Rectangle())
                        )
                        .padding(.horizontal, 1)
                }
            }

            HStack {
                Text("Conservative")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
                Spacer()
                Text("5 / 10")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.accent)
                Spacer()
                Text("Aggressive")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
            }
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
    }

    func riskBarColor(_ index: Int) -> Color {
        let score = 5
        if index <= score {
            let fraction = Double(index) / 10.0
            if fraction < 0.4 { return Color(hex: "#22C55E") }
            if fraction < 0.7 { return Color(hex: "#F59E0B") }
            return Color(hex: "#EF4444")
        }
        return Theme.bg3
    }

    var memberCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(appState.accentGradient)
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
                    .background(Theme.gold.opacity(0.14))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Theme.gold.opacity(0.35), lineWidth: 1))
            }
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
    }

    func aboutRow(icon: String, label: String, value: String, color: Color) -> some View {
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

private struct PostGridCell: View {
    let post: UserPost
    let size: CGFloat

    var gradientColors: [Color] {
        switch post.sentiment {
        case "Bullish":
            return [Color(hex: "#052E16"), Color(hex: "#065F46"), Color(hex: "#0D9488")]
        case "Bearish":
            return [Color(hex: "#2D0A0A"), Color(hex: "#7F1D1D"), Color(hex: "#B91C1C")]
        default:
            return [Color(hex: "#0F0A2E"), Color(hex: "#1E1B4B"), Color(hex: "#312E81")]
        }
    }

    var sentimentDotColor: Color {
        switch post.sentiment {
        case "Bullish": return Theme.gain
        case "Bearish": return Theme.loss
        default:        return Theme.accent
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    if let ticker = post.tickers.first {
                        Text("$\(ticker)")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.white.opacity(0.18))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Circle()
                        .fill(sentimentDotColor)
                        .frame(width: 7, height: 7)
                }
                .padding(8)

                Spacer()

                Text(post.text)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
        }
        .frame(width: size, height: size)
        .clipped()
    }
}

private struct EToroPositionRow: View {
    let position: Position
    let appState: AppState
    let total: Double

    var price: Double { appState.quotes[position.ticker]?.price ?? position.avgCost }
    var value: Double { price * position.shares }
    var cost: Double { position.avgCost * position.shares }
    var pnl: Double { value - cost }
    var pnlPct: Double { cost > 0 ? (pnl / cost) * 100 : 0 }
    var isUp: Bool { pnl >= 0 }
    var allocationPct: Double { total > 0 ? (value / total) : 0 }
    var companyName: String {
        ADD_WATCHLIST_TICKERS.first(where: { $0.ticker == position.ticker })?.name ?? position.ticker
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.accent.opacity(0.12))
                        .frame(width: 42, height: 42)
                    Text(String(position.ticker.prefix(2)))
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(Theme.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(position.ticker)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text(companyName)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                        .lineLimit(1)
                }
                Spacer()
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

            HStack(spacing: 6) {
                Text("\(Int(allocationPct * 100))%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.text3)
                    .frame(width: 32, alignment: .leading)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Theme.bg3)
                            .frame(height: 5)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Theme.nanoBanana)
                            .frame(width: geo.size.width * allocationPct, height: 5)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
