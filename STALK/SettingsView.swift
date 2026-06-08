import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var editField: EditField? = nil
    @State private var showClearConfirm = false
    @State private var showPremium = false

    enum EditField: Identifiable {
        case name, username, bio
        var id: Self { self }
        var title: String {
            switch self { case .name: "Display Name"; case .username: "Username"; case .bio: "Bio" }
        }
    }

    var theme: AppTheme { appState.currentTheme }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    ZStack(alignment: .bottom) {
                        appState.heroGradient
                            .frame(height: 200)

                        VStack(spacing: 0) {
                            HStack {
                                Button { dismiss() } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                    }
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .background(.white.opacity(0.15))
                                    .clipShape(Capsule())
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 52)
                            .padding(.bottom, 16)

                            HStack(spacing: 14) {
                                Circle()
                                    .fill(.white.opacity(0.25))
                                    .frame(width: 64, height: 64)
                                    .overlay(
                                        Text(String(appState.settings.displayName.prefix(1)).uppercased())
                                            .font(.system(size: 26, weight: .black))
                                            .foregroundStyle(.white)
                                    )
                                    .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 3))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(appState.settings.displayName)
                                        .font(.system(size: 20, weight: .black))
                                        .foregroundStyle(.white)
                                    Text("\(appState.settings.username) · PRO member")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.white.opacity(0.65))

                                    let privacyLabel = appState.settings.privacy == "private" ? "🔒 Private"
                                        : appState.settings.privacy == "percent" ? "👁️ Percentages only" : "🌍 Public"
                                    Text(privacyLabel)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 3)
                                        .background(.white.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                    }

                    // Content
                    VStack(spacing: 20) {
                        profileSection()
                        privacySection()
                        appearanceSection()
                        displaySection()
                        notificationsSection()
                        securitySection()
                        dataSection()
                        aboutSection()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 60)
                }
            }
            .background(Theme.bg)
            .navigationBarHidden(true)
        }
        .sheet(item: $editField) { field in
            EditFieldSheet(field: field)
        }
        .sheet(isPresented: $showPremium) {
            PremiumSheet()
        }
        .confirmationDialog("Clear all portfolio data?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Clear All Data", role: .destructive) { appState.clearAllData() }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Profile

    func profileSection() -> some View {
        SettingsSection(title: "👤 Profile") {
            SettingsRow(icon: "✏️", label: "Display Name", sub: appState.settings.displayName) {
                editField = .name
            }
            SettingsDivider()
            SettingsRow(icon: "🏷️", label: "Username", sub: appState.settings.username) {
                editField = .username
            }
            SettingsDivider()
            SettingsRow(icon: "📝", label: "Bio", sub: appState.settings.bio) {
                editField = .bio
            }
        }
    }

    // MARK: - Privacy

    func privacySection() -> some View {
        SettingsSection(title: "🔒 Privacy") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Who can see your account?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.text)
                    .padding(.bottom, 4)

                ForEach([("private", "🔒", "Private", "Only you can see your portfolio & trades"),
                         ("percent", "👁️", "Public · Percentages only", "Others see % returns & daily P&L — not your balance"),
                         ("public",  "🌍", "Public · Full access",      "Everyone sees your trades, balance & full portfolio")],
                        id: \.0) { val, icon, label, sub in
                    let selected = appState.settings.privacy == val
                    Button {
                        appState.settings.privacy = val
                        appState.saveSettings()
                    } label: {
                        HStack(spacing: 12) {
                            Text(icon).font(.system(size: 20))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(label).font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.text)
                                Text(sub).font(.system(size: 11)).foregroundStyle(Theme.text3)
                            }
                            Spacer()
                            Circle()
                                .fill(selected ? appState.accentColor : Color.clear)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Circle().stroke(selected ? appState.accentColor : Theme.border, lineWidth: 2)
                                )
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundStyle(.white)
                                        .opacity(selected ? 1 : 0)
                                )
                        }
                        .padding(14)
                        .background(selected ? appState.accentColor.opacity(0.08) : Theme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(selected ? appState.accentColor : Color.clear, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)

            SettingsDivider()
            SettingsToggleRow(icon: "🏆", label: "Appear in Leaderboard", sub: "Show in World Top Gainers",
                              isOn: appState.settings.leaderboard) {
                appState.settings.leaderboard.toggle()
                appState.saveSettings()
            }
            SettingsDivider()
            SettingsToggleRow(icon: "📊", label: "Show in Friends Comparison", sub: "Let friends see you in vs Friends",
                              isOn: appState.settings.friendsComparison) {
                appState.settings.friendsComparison.toggle()
                appState.saveSettings()
            }
        }
    }

    // MARK: - Appearance

    func appearanceSection() -> some View {
        SettingsSection(title: "🎨 Appearance") {
            VStack(alignment: .leading, spacing: 14) {
                Text("Theme Color")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.text)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(AppTheme.allCases, id: \.self) { t in
                        let selected = appState.settings.theme == t.rawValue
                        Button {
                            appState.settings.theme = t.rawValue
                            appState.saveSettings()
                        } label: {
                            Circle()
                                .fill(t.gradient)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .black))
                                        .foregroundStyle(.white)
                                        .opacity(selected ? 1 : 0)
                                )
                                .overlay(
                                    Circle().stroke(Theme.text.opacity(selected ? 0.8 : 0), lineWidth: 3)
                                )
                        }
                    }
                }
            }
            .padding(.vertical, 4)

            SettingsDivider()
            SettingsToggleRow(icon: "🌙", label: "Dark Mode", sub: "Switch to dark background",
                              isOn: appState.settings.darkMode) {
                appState.settings.darkMode.toggle()
                appState.saveSettings()
            }
            SettingsDivider()
            SettingsToggleRow(icon: "🔤", label: "Large Text", sub: "Increase font sizes",
                              isOn: appState.settings.largeText) {
                appState.settings.largeText.toggle()
                appState.saveSettings()
            }
        }
    }

    // MARK: - Display

    func displaySection() -> some View {
        SettingsSection(title: "📈 Display") {
            SettingsPickerRow(icon: "💱", label: "Currency", selection: Binding(
                get: { appState.settings.currency },
                set: { appState.settings.currency = $0; appState.saveSettings() }
            ), options: [("USD", "USD ($)"), ("EUR", "EUR (€)"), ("ILS", "ILS (₪)"), ("GBP", "GBP (£)"), ("JPY", "JPY (¥)")])

            SettingsDivider()
            SettingsPickerRow(icon: "📊", label: "Default Chart Range", selection: Binding(
                get: { appState.settings.chartRange },
                set: { appState.settings.chartRange = $0; appState.saveSettings() }
            ), options: [("1mo", "1 Month"), ("3mo", "3 Months"), ("6mo", "6 Months"), ("1y", "1 Year")])

            SettingsDivider()
            SettingsPickerRow(icon: "🔢", label: "Sort Positions By", selection: Binding(
                get: { appState.settings.sortBy },
                set: { appState.settings.sortBy = $0; appState.saveSettings() }
            ), options: [("pnl", "P&L %"), ("value", "Value"), ("alpha", "A → Z"), ("newest", "Newest")])

            SettingsDivider()
            SettingsToggleRow(icon: "💰", label: "Show Portfolio Value", sub: "Display total $ value in header",
                              isOn: appState.settings.showValue) {
                appState.settings.showValue.toggle()
                appState.saveSettings()
            }
        }
    }

    // MARK: - Notifications

    func notificationsSection() -> some View {
        SettingsSection(title: "🔔 Notifications") {
            SettingsToggleRow(icon: "📈", label: "Price Alerts", sub: "Notify when target price is hit",
                              isOn: appState.settings.priceAlerts) {
                appState.settings.priceAlerts.toggle()
                appState.saveSettings()
                NotificationService.syncWithSettings(appState.settings)
            }
            SettingsDivider()
            SettingsToggleRow(icon: "📊", label: "Earnings Reminders", sub: "Alert before your stocks report",
                              isOn: appState.settings.earnings) {
                appState.settings.earnings.toggle(); appState.saveSettings()
            }
            SettingsDivider()
            SettingsToggleRow(icon: "🐋", label: "Whale Alerts", sub: "Big options activity in your stocks",
                              isOn: appState.settings.whaleAlerts) {
                appState.settings.whaleAlerts.toggle(); appState.saveSettings()
            }
            SettingsDivider()
            SettingsToggleRow(icon: "👥", label: "Social Activity", sub: "Likes, follows & comments",
                              isOn: appState.settings.socialActivity) {
                appState.settings.socialActivity.toggle(); appState.saveSettings()
            }
        }
    }

    // MARK: - Security

    func securitySection() -> some View {
        SettingsSection(title: "🛡️ Security") {
            SettingsToggleRow(icon: "🔐", label: "Face ID / Biometric Lock", sub: "Require authentication to open",
                              isOn: appState.settings.biometric) {
                appState.settings.biometric.toggle(); appState.saveSettings()
            }
            SettingsDivider()
            SettingsRow(icon: "🔑", label: "Change PIN", sub: "4-digit app lock") {}
            SettingsDivider()
            SettingsRow(icon: "📱", label: "Two-Factor Auth", sub: "Extra login security") {}
        }
    }

    // MARK: - Data

    func dataSection() -> some View {
        SettingsSection(title: "📂 Data & Export") {
            Button {
                let csv = appState.exportCSV()
                #if os(iOS)
                let url = FileManager.default.temporaryDirectory.appendingPathComponent("stalk-portfolio.csv")
                try? csv.write(to: url, atomically: true, encoding: .utf8)
                let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                    .windows.first?.rootViewController?.present(av, animated: true)
                #endif
            } label: {
                HStack {
                    Text("📤").font(.system(size: 20)).frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Export Portfolio to CSV")
                            .font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.text)
                        Text("Download your full trade history")
                            .font(.system(size: 11)).foregroundStyle(Theme.text3)
                    }
                    Spacer()
                    Text("Export")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(appState.accentColor)
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            SettingsDivider()

            Button { showClearConfirm = true } label: {
                HStack {
                    Text("🗑️").font(.system(size: 20)).frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clear All Data")
                            .font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.text)
                        Text("Wipe portfolio & reset app")
                            .font(.system(size: 11)).foregroundStyle(Theme.text3)
                    }
                    Spacer()
                    Text("Clear")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.loss)
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - About

    func aboutSection() -> some View {
        SettingsSection(title: "ℹ️ About") {
            HStack {
                Text("📱").font(.system(size: 20)).frame(width: 32)
                Text("Version").font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.text)
                Spacer()
                Text("1.0.0").font(.system(size: 13)).foregroundStyle(Theme.text3)
            }
            .padding(.vertical, 14)

            SettingsDivider()

            Button { showPremium = true } label: {
                HStack {
                    Text("⭐").font(.system(size: 20)).frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Upgrade to Pro")
                            .font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.text)
                        Text("Whale alerts, AI analysis & more")
                            .font(.system(size: 11)).foregroundStyle(Theme.text3)
                    }
                    Spacer()
                    Text("PRO")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(appState.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            SettingsDivider()
            SettingsRow(icon: "📄", label: "Privacy Policy", sub: nil) {}
            SettingsDivider()
            SettingsRow(icon: "📋", label: "Terms of Service", sub: nil) {}
        }
    }
}

// MARK: - Edit Field Sheet

struct EditFieldSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    let field: SettingsView.EditField
    @State private var value = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Edit \(field.title)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Theme.text)
                    .padding(.bottom, 16)

                TextField(field.title, text: $value)
                    .stalkInput()

                Button("Save") {
                    switch field {
                    case .name:     appState.settings.displayName = value
                    case .username: appState.settings.username = value
                    case .bio:      appState.settings.bio = value
                    }
                    appState.saveSettings()
                    dismiss()
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(appState.accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.top, 14)

                Button("Cancel") { dismiss() }
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.text3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)

                Spacer()
            }
            .padding(22)
            .background(Theme.bg)
            .onAppear {
                switch field {
                case .name:     value = appState.settings.displayName
                case .username: value = appState.settings.username
                case .bio:      value = appState.settings.bio
                }
            }
        }
    }
}

// MARK: - Reusable Components

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.text3)
                .textCase(.uppercase)
                .kerning(1.3)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border, lineWidth: 1))
            .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let label: String
    let sub: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(icon).font(.system(size: 20)).frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.text)
                    if let sub {
                        Text(sub).font(.system(size: 11)).foregroundStyle(Theme.text3)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text3)
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsToggleRow: View {
    @Environment(AppState.self) var appState
    let icon: String
    let label: String
    let sub: String
    let isOn: Bool
    let toggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(icon).font(.system(size: 20)).frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.text)
                Text(sub).font(.system(size: 11)).foregroundStyle(Theme.text3)
            }
            Spacer()
            Toggle("", isOn: Binding(get: { isOn }, set: { _ in toggle() }))
                .labelsHidden()
                .tint(appState.accentColor)
        }
        .padding(.vertical, 14)
    }
}

struct SettingsPickerRow: View {
    @Environment(AppState.self) var appState
    let icon: String
    let label: String
    @Binding var selection: String
    let options: [(String, String)]

    var currentLabel: String { options.first { $0.0 == selection }?.1 ?? selection }

    var body: some View {
        HStack(spacing: 12) {
            Text(icon).font(.system(size: 20)).frame(width: 32)
            Text(label).font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.text)
            Spacer()
            Picker("", selection: $selection) {
                ForEach(options, id: \.0) { val, label in
                    Text(label).tag(val)
                }
            }
            .pickerStyle(.menu)
            .tint(appState.accentColor)
        }
        .padding(.vertical, 14)
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider().padding(.horizontal, -4)
    }
}
