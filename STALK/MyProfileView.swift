import SwiftUI

// MARK: - MyProfileView

enum ProfileTab {
    case posts, portfolio, about
}

struct MyProfileView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    var embedded: Bool = false   // true when rendered inline inside the Feed tab
    @State private var profileTab: ProfileTab = .posts
    @State private var showSettings = false
    @State private var showShareSheet = false
    @State private var showEditProfile = false
    @State private var showSavedArchive = false

    private let gridColumns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]

    var body: some View {
        Group {
            if embedded {
                profileContent
            } else {
                ScrollView(showsIndicators: false) {
                    profileContent
                }
                .background(Theme.bg)
                .ignoresSafeArea(edges: .top)
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView().environment(appState) }
        .sheet(isPresented: $showEditProfile) { EditProfileView().environment(appState) }
        .sheet(isPresented: $showSavedArchive) { SavedArchiveView().environment(appState) }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: ["Check out my portfolio on STALK! @\(appState.settings.username)"])
        }
    }

    var profileContent: some View {
        VStack(spacing: 0) {
            profileCover
            profileIdentity
            profileStats
            profileActions
            if appState.isInfluencer {
                creatorDashboard
            }
            tabSelector
            tabContent
            Color.clear.frame(height: 100)
        }
    }

    // Creator dashboard — influencer accounts only
    var creatorDashboard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: "#3897F0"))
                Text("CREATOR DASHBOARD")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(Theme.text3)
                    .kerning(1.5)
                Spacer()
                if !appState.settings.isCreator {
                    Text("PREVIEW")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Theme.goldBg)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 0) {
                creatorStat("48.2K", "Post views", "+18%")
                creatorStat("+182", "Followers /wk", "+9%")
                creatorStat("36", "Copiers", "+4")
                creatorStat("$1,284", "Earnings", "+$212")
            }

            if !appState.settings.isCreator {
                Text("Upgrade to Creator to activate revenue share and unlock full analytics.")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
            }
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#3897F0").opacity(0.25), lineWidth: 1))
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
    }

    func creatorStat(_ value: String, _ label: String, _ delta: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(Theme.text)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(Theme.text3)
            Text(delta)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.gain)
        }
        .frame(maxWidth: .infinity)
    }

    var profileCover: some View {
        ZStack(alignment: .topTrailing) {
            Rectangle()
                .fill(AnyShapeStyle(appState.heroGradient))
                .frame(height: embedded ? 150 : 220)
                .overlay(alignment: .bottomLeading) {
                    Circle()
                        .fill(AnyShapeStyle(appState.accentGradient))
                        .frame(width: 90, height: 90)
                        .overlay(
                            Text(String(appState.settings.displayName.prefix(1)).uppercased())
                                .font(.system(size: 36, weight: .black))
                                .foregroundStyle(.white)
                        )
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
                        .offset(x: 20, y: 45)
                }

            HStack(spacing: 10) {
                Button { showSavedArchive = true } label: {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                        .shadow(color: .black.opacity(0.25), radius: 6, y: 2)
                }
                .buttonStyle(.plain)

                Button { showSettings = true } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                        .shadow(color: .black.opacity(0.25), radius: 6, y: 2)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, embedded ? 16 : 56)
            .padding(.trailing, 18)
        }
        .frame(height: embedded ? 150 : 220)
    }

    var profileIdentity: some View {
        VStack(alignment: .leading, spacing: 6) {
            Color.clear.frame(height: 50)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Text(appState.settings.displayName)
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(Theme.text)
                        if appState.isVerified {
                            VerifiedBadge(size: 16)
                        }
                    }
                    HStack(spacing: 6) {
                        Text("@\(appState.settings.username)")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.text3)
                        if appState.isInfluencer {
                            Text("CREATOR")
                                .font(.system(size: 8, weight: .black))
                                .foregroundStyle(Color(hex: "#3897F0"))
                                .kerning(0.8)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "#3897F0").opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
                Spacer()
                Text(appState.totalPnlPct.fmtPct())
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(appState.totalPnlPct >= 0 ? Theme.gain : Theme.loss)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(appState.totalPnlPct >= 0 ? Theme.gainBg : Theme.lossBg)
                    .clipShape(Capsule())
            }

            if !appState.settings.bio.isEmpty {
                Text(appState.settings.bio)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text2)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    var profileStats: some View {
        HStack(spacing: 0) {
            profileStatCell("\(appState.userPosts.count)", "Posts")
            statDivider
            profileStatCell("2,341", "Followers")
            statDivider
            profileStatCell("180", "Following")
            statDivider
            profileStatCell(appState.totalPnlPct.fmtPct(), "Return")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .overlay(Rectangle().fill(Theme.border).frame(height: 0.5), alignment: .top)
        .overlay(Rectangle().fill(Theme.border).frame(height: 0.5), alignment: .bottom)
    }

    @ViewBuilder
    var statDivider: some View {
        Rectangle()
            .fill(Theme.border)
            .frame(width: 1, height: 28)
    }

    var profileActions: some View {
        HStack(spacing: 10) {
            Button { showEditProfile = true } label: {
                Text("Edit Profile")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Theme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1.5))
            }
            .buttonStyle(.plain)

            Button { showShareSheet = true } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.text2)
                    .frame(width: 44, height: 44)
                    .background(Theme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    var tabSelector: some View {
        HStack(spacing: 0) {
            profileTabBtn(.posts, icon: "square.grid.3x3.fill")
            profileTabBtn(.portfolio, icon: "chart.bar.fill")
            profileTabBtn(.about, icon: "person.crop.rectangle.fill")
        }
        .overlay(Rectangle().fill(Theme.border).frame(height: 0.5), alignment: .top)
        .overlay(Rectangle().fill(Theme.border).frame(height: 0.5), alignment: .bottom)
    }

    func profileTabBtn(_ tab: ProfileTab, icon: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { profileTab = tab }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: profileTab == tab ? .bold : .regular))
                    .foregroundStyle(profileTab == tab ? Theme.text : Theme.text3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                Rectangle()
                    .fill(profileTab == tab ? Theme.text : Color.clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    var tabContent: some View {
        switch profileTab {
        case .posts:    postsGrid
        case .portfolio: portfolioTab
        case .about:    aboutTab
        }
    }

    var postsGrid: some View {
        Group {
            if appState.userPosts.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(Theme.text3)
                    Text("Share your first trade idea")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.text2)
                    Text("Your posts will appear here.")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.text3)
                    Button {} label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus").font(.system(size: 12, weight: .bold))
                            Text("New Post").font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 11)
                        .background(Theme.accentGradient)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 60)
                .frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: gridColumns, spacing: 2) {
                    ForEach(appState.userPosts) { post in
                        PostGridCell(post: post)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var portfolioTab: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("PORTFOLIO VALUE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(1.5)
                    Text(appState.totalValue.fmtPrice())
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(Theme.text)
                        .monospacedDigit()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("TOTAL P&L")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(1.5)
                    Text(appState.totalPnl.fmtChange())
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(appState.totalPnl >= 0 ? Theme.gain : Theme.loss)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)

            Divider().overlay(Theme.border)

            VStack(spacing: 0) {
                ForEach(Array(appState.positions.enumerated()), id: \.element.id) { i, position in
                    EToroPositionRow(position: position, quote: appState.quotes[position.ticker], totalValue: appState.totalValue)
                    if i < appState.positions.count - 1 {
                        Divider().padding(.leading, 20).overlay(Theme.border)
                    }
                }
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    @ViewBuilder
    var aboutTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("RISK SCORE")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(Theme.text3)
                    .kerning(1.5)
                HStack(spacing: 12) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.bg3)
                                .frame(height: 8)
                            LinearGradient(
                                colors: [Theme.gain, Theme.gold, Theme.loss],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .mask(
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width: geo.size.width * CGFloat(5) / 10, height: 8)
                            )
                        }
                    }
                    .frame(height: 8)
                    Text("\(5)/10")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(5 <= 3 ? Theme.gain : 5 <= 6 ? Theme.gold : Theme.loss)
                        .frame(width: 42, alignment: .trailing)
                }
            }
            .padding(16)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                aboutStatCell("All-Time Return", appState.totalPnlPct.fmtPct(), appState.totalPnlPct >= 0 ? Theme.gain : Theme.loss)
                aboutStatCell("Today P&L", appState.todayPnlPct.fmtPct(), appState.todayPnlPct >= 0 ? Theme.gain : Theme.loss)
                aboutStatCell("Portfolio Value", appState.totalValue.fmtPrice(), Theme.text)
                aboutStatCell("Positions", "\(appState.positions.count)", Theme.accent)
                aboutStatCell("Copiers", "\(appState.copiedTraders.count)", Theme.accent)
                aboutStatCell("Watchlist", "\(appState.watchlist.count)", Theme.text2)
            }

            if !appState.settings.bio.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("BIO")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(1.5)
                    Text(appState.settings.bio)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.text2)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    func profileStatCell(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Theme.text)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Theme.text3)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func aboutStatCell(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(0.5)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(color)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
    }

    private func formatStatNum(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n)/1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n)/1_000) }
        return "\(n)"
    }
}

// MARK: - Post Grid Cell

struct PostGridCell: View {
    let post: UserPost

    private var cellGradient: LinearGradient {
        switch post.sentiment {
        case "Bullish":
            return LinearGradient(colors: [Color(hex: "#052E16"), Color(hex: "#14532D")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Bearish":
            return LinearGradient(colors: [Color(hex: "#450A0A"), Color(hex: "#7F1D1D")], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [Color(hex: "#1E1B4B"), Color(hex: "#312E81")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(cellGradient)
                    .frame(width: geo.size.width, height: geo.size.width)

                if let first = post.tickers.first {
                    Text(first)
                        .font(.system(size: 10, weight: .black).monospaced())
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }

                LinearGradient(
                    stops: [.init(color: .clear, location: 0.4), .init(color: .black.opacity(0.75), location: 1)],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(width: geo.size.width, height: geo.size.width)

                Text(post.text)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                    .shadow(color: .black.opacity(0.6), radius: 3)
            }
            .frame(width: geo.size.width, height: geo.size.width)
            .clipped()
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - eToro Position Row

struct EToroPositionRow: View {
    let position: Position
    let quote: Quote?
    let totalValue: Double

    private var currentPrice: Double { quote?.price ?? position.avgCost }
    private var currentValue: Double { currentPrice * position.shares }
    private var pnlPct: Double { position.avgCost > 0 ? ((currentPrice - position.avgCost) / position.avgCost) * 100 : 0 }

    private var allocation: Double {
        guard totalValue > 0 else { return 0 }
        return min(currentValue / totalValue, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(position.ticker)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text(quote?.name ?? position.ticker)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(currentValue.fmtPrice())
                        .font(.system(size: 14, weight: .bold).monospacedDigit())
                        .foregroundStyle(Theme.text)
                    Text(pnlPct.fmtPct())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(pnlPct >= 0 ? Theme.gain : Theme.loss)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.bg2)
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.nanoBanana)
                        .frame(width: max(geo.size.width * CGFloat(allocation), 4), height: 4)
                }
            }
            .frame(height: 4)
            HStack {
                Text("\(Int(allocation * 100))% allocation")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.text4)
                Spacer()
                Text("\(position.shares) shares")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.text4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var displayName = ""
    @State private var username = ""
    @State private var bio = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("DISPLAY NAME")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(1.5)
                    TextField("Display Name", text: $displayName)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Theme.bg3)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("USERNAME")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(1.5)
                    TextField("username", text: $username)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.text)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Theme.bg3)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("BIO")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.text3)
                        .kerning(1.5)
                    ZStack(alignment: .topLeading) {
                        if bio.isEmpty {
                            Text("Tell people about your trading style…")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.text4)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 13)
                        }
                        TextEditor(text: $bio)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.text)
                            .frame(height: 80)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                    }
                    .background(Theme.bg3)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                }
                Spacer()
                Button {
                    let dn = displayName.trimmingCharacters(in: .whitespaces)
                    let un = username.trimmingCharacters(in: .whitespaces)
                    if !dn.isEmpty { appState.settings.displayName = dn }
                    if !un.isEmpty { appState.settings.username = un }
                    appState.settings.bio = bio.trimmingCharacters(in: .whitespaces)
                    dismiss()
                } label: {
                    Text("Save Changes")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Theme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(Theme.bg)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Theme.text3)
                    }
                }
            }
            .onAppear {
                displayName = appState.settings.displayName
                username = appState.settings.username
                bio = appState.settings.bio
            }
        }
    }
}

// MARK: - Saved & Archive (Instagram-style)

struct SavedArchiveView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var section = "Saved"

    var savedTraders: [Trader] {
        FEED_TRADERS.filter { appState.savedTraderPosts.contains($0.id) }
    }
    var archivedPosts: [UserPost] {
        appState.userPosts.filter { appState.archivedUserPosts.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.text2)
                        .frame(width: 34, height: 34)
                        .background(Theme.bg2)
                        .clipShape(Circle())
                }
                Spacer()
                Text(section)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Theme.text)
                Spacer()
                Color.clear.frame(width: 34, height: 34)
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 12)

            // Segmented control
            HStack(spacing: 0) {
                ForEach(["Saved", "Archive"], id: \.self) { s in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { section = s }
                    } label: {
                        VStack(spacing: 7) {
                            HStack(spacing: 5) {
                                Image(systemName: s == "Saved" ? "bookmark" : "archivebox")
                                    .font(.system(size: 12, weight: .semibold))
                                Text(s)
                                    .font(.system(size: 13, weight: section == s ? .black : .semibold))
                            }
                            .foregroundStyle(section == s ? Theme.text : Theme.text3)
                            .frame(maxWidth: .infinity)
                            Rectangle()
                                .fill(section == s ? Theme.accent : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .overlay(Rectangle().fill(Theme.border).frame(height: 0.5), alignment: .bottom)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    if section == "Saved" {
                        if savedTraders.isEmpty {
                            savedEmptyState(icon: "bookmark", title: "No saved posts",
                                            text: "Tap the bookmark on any post in your feed to save it here.")
                        } else {
                            ForEach(savedTraders) { trader in
                                SocialPostCard(trader: trader, onTicker: { _ in })
                                Rectangle().fill(Theme.border).frame(height: 0.5)
                            }
                        }
                    } else {
                        if archivedPosts.isEmpty {
                            savedEmptyState(icon: "archivebox", title: "Archive is empty",
                                            text: "Posts you archive disappear from your feed but stay here — only you can see them.")
                        } else {
                            ForEach(archivedPosts) { post in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(post.text)
                                        .font(.system(size: 14))
                                        .foregroundStyle(Theme.text)
                                        .lineSpacing(4)
                                    HStack {
                                        Text(post.sentiment)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(Theme.text3)
                                        Spacer()
                                        Button {
                                            withAnimation { _ = appState.archivedUserPosts.remove(post.id) }
                                        } label: {
                                            Text("Unarchive")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(Theme.accent)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 7)
                                                .background(Theme.accentBg)
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(16)
                                .background(Theme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                                .padding(.horizontal, 14)
                                .padding(.top, 10)
                            }
                        }
                    }
                    Color.clear.frame(height: 40)
                }
            }
        }
        .background(Theme.bg)
    }

    func savedEmptyState(icon: String, title: String, text: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(Theme.text3)
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.text2)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Theme.text3)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity)
    }
}
