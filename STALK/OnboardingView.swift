import SwiftUI

// MARK: - Onboarding Flow Root

struct OnboardingFlowView: View {
    @Environment(AppState.self) var appState
    @State private var currentScreen = 0
    @State private var direction: Int = 1

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            switch currentScreen {
            case 0:
                OnboardingScreen1(onContinue: { advance() }, onSkip: { skip1(); advance() })
                    .transition(pageTransition(direction: direction))
            case 1:
                OnboardingScreen2(onContinue: { advance() })
                    .transition(pageTransition(direction: direction))
            case 2:
                OnboardingScreen3(onContinue: { advance() })
                    .transition(pageTransition(direction: direction))
            case 3:
                OnboardingScreen4(onFinish: { finish() })
                    .transition(pageTransition(direction: direction))
            default:
                EmptyView()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: currentScreen)
    }

    private func advance() {
        direction = 1
        if currentScreen == 1 && appState.positions.isEmpty {
            // Skip notification screen if no stocks
            markDone()
            return
        }
        if currentScreen >= 3 {
            finish()
        } else {
            currentScreen += 1
        }
    }

    private func skip1() {
        if appState.settings.displayName == "Itamar B." || appState.settings.displayName.isEmpty {
            appState.settings.displayName = "Investor"
        }
        if appState.settings.username == "@itamar" || appState.settings.username.isEmpty {
            appState.settings.username = "@user"
        }
        appState.saveSettings()
    }

    private func finish() {
        markDone()
    }

    private func markDone() {
        appState.settings.hasCompletedOnboarding = true
        appState.saveSettings()
    }

    private func pageTransition(direction: Int) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: direction >= 0 ? .trailing : .leading),
            removal: .move(edge: direction >= 0 ? .leading : .trailing)
        )
    }
}

// MARK: - Screen 1: Welcome / Identity

private struct OnboardingScreen1: View {
    @Environment(AppState.self) var appState
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var displayName = ""
    @State private var username = ""
    @FocusState private var focusedField: Field?

    enum Field { case name, username }

    var canContinue: Bool {
        let name = displayName.trimmingCharacters(in: .whitespaces)
        let user = username.trimmingCharacters(in: .whitespaces)
        return name.count >= 2 && name.count <= 30 && user.count >= 3 && user.count <= 20
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                // Logo / wordmark
                VStack(spacing: 6) {
                    Text("STALK")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(Theme.accentGradient)
                    Text("Your portfolio.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text("Live. Obsessive. Personal.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Theme.text3)
                }
                .multilineTextAlignment(.center)

                Divider()
                    .padding(.vertical, 40)

                VStack(alignment: .leading, spacing: 0) {
                    Text("What should we call you?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Theme.text)
                        .padding(.bottom, 24)

                    fieldLabel("Display Name")
                    TextField("Your name", text: $displayName)
                        .stalkInput()
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .name)
                        .onChange(of: displayName) { _, v in
                            if v.count > 30 { displayName = String(v.prefix(30)) }
                        }

                    fieldLabel("Username")
                    HStack(spacing: 0) {
                        Text("@")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.text3)
                            .padding(.leading, 14)
                        TextField("username", text: $username)
                            .autocorrectionDisabled()
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            #endif
                            .focused($focusedField, equals: .username)
                            .onChange(of: username) { _, v in
                                let filtered = v.filter { $0.isLetter || $0.isNumber || $0 == "_" }
                                username = String(filtered.prefix(20))
                            }
                            .padding(.vertical, 14)
                            .padding(.trailing, 14)
                            .padding(.leading, 4)
                    }
                    .background(Theme.bg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Theme.border, lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Text("Letters, numbers, and underscores only")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                        .padding(.top, 6)
                        .padding(.leading, 4)
                }
                .padding(.horizontal, 28)

                Spacer().frame(height: 40)

                VStack(spacing: 12) {
                    Button {
                        let name = displayName.trimmingCharacters(in: .whitespaces)
                        let user = username.trimmingCharacters(in: .whitespaces)
                        appState.settings.displayName = name
                        appState.settings.username = "@\(user)"
                        appState.saveSettings()
                        onContinue()
                    } label: {
                        Text("Continue →")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(canContinue ? Theme.accentGradient : LinearGradient(colors: [Theme.text3], startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .disabled(!canContinue)
                    .padding(.horizontal, 28)

                    Button("Skip") {
                        onSkip()
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.text3)
                }
                .padding(.bottom, 40)
            }
        }
        .background(Theme.bg)
        .onAppear {
            displayName = appState.settings.displayName == "Itamar B." ? "" : appState.settings.displayName
            let raw = appState.settings.username.hasPrefix("@") ? String(appState.settings.username.dropFirst()) : appState.settings.username
            username = raw == "itamar" ? "" : raw
        }
    }

    func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Theme.text2)
            .padding(.top, 18)
            .padding(.bottom, 7)
    }
}

// MARK: - Screen 2: Add First Stock

private struct OnboardingScreen2: View {
    @Environment(AppState.self) var appState
    let onContinue: () -> Void

    @State private var trendingQuotes: [String: Quote] = [:]
    @State private var addedTickers: Set<String> = []
    @State private var showAddSheet = false
    @State private var prefilledTicker = ""
    @State private var searchText = ""

    private let trending = ["NVDA", "TSLA", "AAPL", "MSFT", "AMZN", "META"]
    private let popular = [("S&P 500", "SPY"), ("NASDAQ 100", "QQQ"), ("Bitcoin ETF", "IBIT")]

    var addedCount: Int { appState.positions.count }

    var ctaLabel: String {
        if addedCount == 0 { return "Skip for now" }
        if addedCount >= 3 { return "Done, let's go →" }
        return "Continue (\(addedCount) added) →"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 60)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Hey \(firstName(appState.settings.displayName)),")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(Theme.text)
                    Text("let's build your portfolio.")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.text)

                    Text("Add 1–3 stocks you own or want to track.")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.text3)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)

                // Search bar
                Button {
                    prefilledTicker = ""
                    showAddSheet = true
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Theme.text3)
                        Text("Search stocks...")
                            .foregroundStyle(Theme.text3)
                        Spacer()
                    }
                    .padding(14)
                    .background(Theme.bg2)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1.5))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)

                // Trending chips
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("Trending right now")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(trending, id: \.self) { ticker in
                            trendingChip(ticker: ticker)
                        }
                    }
                    .padding(.horizontal, 28)
                }
                .padding(.bottom, 24)

                // Popular first picks
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("Popular first picks")

                    VStack(spacing: 8) {
                        ForEach(popular, id: \.1) { name, ticker in
                            popularRow(name: name, ticker: ticker)
                        }
                    }
                    .padding(.horizontal, 28)
                }
                .padding(.bottom, 16)

                Text("Already have a portfolio somewhere? You can import a CSV in Settings → Portfolio")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.text3)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 32)

                // CTA
                Button {
                    onContinue()
                } label: {
                    Text(ctaLabel)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(addedCount > 0 ? .white : Theme.text2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(addedCount > 0 ? Theme.accentGradient : LinearGradient(colors: [Theme.bg2], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
        .background(Theme.bg)
        .sheet(isPresented: $showAddSheet, onDismiss: refreshAdded) {
            AddPositionSheet(prefillTicker: prefilledTicker)
        }
        .task {
            trendingQuotes = await QuoteService.fetchManyQuotes(trending)
        }
    }

    func refreshAdded() {
        addedTickers = Set(appState.positions.map(\.ticker))
    }

    func firstName(_ name: String) -> String {
        name.components(separatedBy: " ").first ?? name
    }

    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Theme.text3)
            .textCase(.uppercase)
            .kerning(1)
            .padding(.horizontal, 28)
    }

    @ViewBuilder
    func trendingChip(ticker: String) -> some View {
        let quote = trendingQuotes[ticker]
        let isAdded = appState.positions.contains { $0.ticker == ticker }
        let pct = quote?.changePercent ?? 0
        let isUp = pct >= 0

        Button {
            prefilledTicker = ticker
            showAddSheet = true
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    if isAdded {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.gain)
                    }
                    Text(ticker)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.text)
                }
                if let _ = quote {
                    Text(pct.fmtPct())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(isUp ? Theme.gain : Theme.loss)
                } else {
                    Text("...")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isAdded ? Theme.gain.opacity(0.1) : Theme.bg2)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isAdded ? Theme.gain.opacity(0.4) : Theme.border, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func popularRow(name: String, ticker: String) -> some View {
        let isAdded = appState.positions.contains { $0.ticker == ticker }

        Button {
            prefilledTicker = ticker
            showAddSheet = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    Text(ticker)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                }
                Spacer()
                if isAdded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.gain)
                } else {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(Theme.accent)
                }
            }
            .padding(14)
            .background(isAdded ? Theme.gain.opacity(0.08) : Theme.bg2)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(isAdded ? Theme.gain.opacity(0.3) : Theme.border, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Screen 3: Portfolio Comes Alive

private struct OnboardingScreen3: View {
    @Environment(AppState.self) var appState
    let onContinue: () -> Void

    @State private var isLoading = true
    @State private var animatedValue: Double = 0

    var hasPositions: Bool { !appState.positions.isEmpty }
    var totalValue: Double { appState.totalValue }
    var todayPnl: Double { appState.todayPnl }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Theme.accent)

                    Text("Fetching live prices...")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Theme.text2)
                }
            } else {
                VStack(spacing: 0) {
                    if hasPositions {
                        // Live portfolio card
                        VStack(spacing: 24) {
                            VStack(spacing: 8) {
                                Text("Your portfolio is live.")
                                    .font(.system(size: 24, weight: .black))
                                    .foregroundStyle(Theme.text)

                                Text(animatedValue.fmtPrice())
                                    .font(.system(size: 42, weight: .black))
                                    .foregroundStyle(Theme.text)
                                    .contentTransition(.numericText())

                                HStack(spacing: 6) {
                                    Image(systemName: todayPnl >= 0 ? "arrow.up" : "arrow.down")
                                        .font(.system(size: 13, weight: .bold))
                                    Text("\(todayPnl >= 0 ? "+" : "")\(todayPnl.fmtPrice()) today")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundStyle(todayPnl >= 0 ? Theme.gain : Theme.loss)
                            }

                            // Allocation bars
                            allocationBars()
                        }
                        .padding(28)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
                        .padding(.horizontal, 28)

                        Text("This is just the beginning.")
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.text3)
                            .padding(.top, 20)

                        if appState.streak > 0 {
                            HStack(spacing: 6) {
                                Text("🔥")
                                Text("Day \(appState.streak) of your streak started")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Theme.gold)
                            }
                            .padding(.top, 8)
                        }

                    } else {
                        // Empty state
                        VStack(spacing: 16) {
                            Text("📊")
                                .font(.system(size: 56))
                            Text("Your portfolio is waiting.")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text("Add your first stock whenever you're ready.")
                                .font(.system(size: 15))
                                .foregroundStyle(Theme.text3)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 28)
                    }
                }
            }

            Spacer()

            Button {
                onContinue()
            } label: {
                Text("Go to my portfolio →")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(Theme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
            .opacity(isLoading ? 0 : 1)
        }
        .background(Theme.bg)
        .task {
            await appState.refreshPortfolio()
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = false
            }
            if appState.totalValue > 0 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animatedValue = appState.totalValue
                }
            }
        }
    }

    @ViewBuilder
    func allocationBars() -> some View {
        let totalVal = appState.totalValue
        if totalVal > 0 {
            VStack(spacing: 10) {
                ForEach(appState.positions.prefix(5)) { pos in
                    let price = appState.quotes[pos.ticker]?.price ?? pos.avgCost
                    let val = price * pos.shares
                    let pct = totalVal > 0 ? val / totalVal : 0

                    HStack(spacing: 10) {
                        Text(pos.ticker)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Theme.text)
                            .frame(width: 50, alignment: .leading)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.bg2)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.accentGradient)
                                    .frame(width: geo.size.width * pct)
                            }
                        }
                        .frame(height: 8)

                        Text(String(format: "%.0f%%", pct * 100))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.text3)
                            .frame(width: 34, alignment: .trailing)
                    }
                }
            }
        }
    }
}

// MARK: - Screen 4: Notifications Ask

private struct OnboardingScreen4: View {
    @Environment(AppState.self) var appState
    let onFinish: () -> Void

    @State private var isRequesting = false

    var sampleTicker: String {
        appState.positions.first?.ticker ?? "NVDA"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                // Bell icon with pulse
                ZStack {
                    Circle()
                        .fill(Theme.accent.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Circle()
                        .stroke(Theme.accent.opacity(0.2), lineWidth: 2)
                        .frame(width: 120, height: 120)
                    Image(systemName: "bell.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.accentGradient)
                }

                VStack(spacing: 10) {
                    Text("Stay one step ahead.")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(Theme.text)
                        .multilineTextAlignment(.center)

                    Text("Get alerts when your\nstocks make a big move.")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Theme.text2)
                        .multilineTextAlignment(.center)
                }

                // Example alerts
                VStack(alignment: .leading, spacing: 12) {
                    alertExample("\(sampleTicker) up 5% — you're up $120")
                    alertExample("Earnings report in 2 days")
                    alertExample("Daily market brief at 9:30am")
                }
                .padding(.horizontal, 28)
            }
            .padding(.horizontal, 28)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    isRequesting = true
                    Task {
                        let granted = await NotificationService.requestAuthorization()
                        if granted {
                            appState.settings.priceAlerts = true
                            appState.saveSettings()
                            NotificationService.scheduleMarketOpenNotification()
                        }
                        onFinish()
                    }
                } label: {
                    Group {
                        if isRequesting {
                            ProgressView().tint(.white)
                        } else {
                            Text("Enable Alerts")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(Theme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .disabled(isRequesting)
                .padding(.horizontal, 28)

                Button("Not now") {
                    onFinish()
                }
                .font(.system(size: 14))
                .foregroundStyle(Theme.text3)
            }
            .padding(.bottom, 40)
        }
        .background(Theme.bg)
    }

    func alertExample(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.gain)
                .font(.system(size: 16))
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(Theme.text2)
        }
    }
}

