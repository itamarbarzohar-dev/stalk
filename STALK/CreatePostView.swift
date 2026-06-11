import SwiftUI

struct CreatePostView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    @State private var postText = ""
    @State private var tickerInput = ""
    @State private var tickers: [String] = []
    @State private var sentiment = "Bullish"
    @FocusState private var textFocused: Bool

    private let sentiments = ["Bullish", "Bearish", "Neutral"]
    private let maxChars = 280

    var canPost: Bool { !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Theme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // ── Author row ───────────────────────────────────────
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Theme.accentGradient)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text(String(appState.settings.displayName.prefix(1)).uppercased())
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundStyle(.white)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(appState.settings.displayName)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Theme.text)
                                Text(appState.settings.username)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.text3)
                            }

                            Spacer()

                            // Sentiment picker
                            HStack(spacing: 0) {
                                ForEach(sentiments, id: \.self) { s in
                                    Button {
                                        sentiment = s
                                    } label: {
                                        Text(s)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(sentiment == s ? .white : Theme.text3)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(sentiment == s ? sentimentColor(s) : Color.clear)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .background(Theme.bg3)
                            .clipShape(Capsule())
                        }

                        // ── Post text ────────────────────────────────────────
                        ZStack(alignment: .topLeading) {
                            if postText.isEmpty {
                                Text("What's your market take?")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Theme.text4)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                            TextEditor(text: $postText)
                                .font(.system(size: 16))
                                .foregroundStyle(Theme.text)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 120)
                                .focused($textFocused)
                                .onChange(of: postText) { _, new in
                                    if new.count > maxChars {
                                        postText = String(new.prefix(maxChars))
                                    }
                                }
                        }

                        // ── Char counter ─────────────────────────────────────
                        HStack {
                            Spacer()
                            let remaining = maxChars - postText.count
                            Text("\(remaining)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(remaining < 40 ? Theme.loss : Theme.text3)
                        }

                        Divider().background(Theme.border)

                        // ── Ticker tags ──────────────────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TAG STOCKS")
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(Theme.text3)
                                .tracking(1.5)

                            // Existing tags
                            if !tickers.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(tickers, id: \.self) { ticker in
                                            HStack(spacing: 4) {
                                                Text("$\(ticker)")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundStyle(Theme.accent)
                                                Button {
                                                    tickers.removeAll { $0 == ticker }
                                                } label: {
                                                    Image(systemName: "xmark")
                                                        .font(.system(size: 9, weight: .bold))
                                                        .foregroundStyle(Theme.text3)
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Theme.accentBg)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(Theme.accent.opacity(0.3), lineWidth: 1))
                                        }
                                    }
                                }
                            }

                            // Add ticker input
                            HStack(spacing: 8) {
                                Text("$")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Theme.text3)
                                TextField("AAPL, NVDA…", text: $tickerInput)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.text)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                                    .submitLabel(.done)
                                    .onSubmit { addTicker() }
                                    .onChange(of: tickerInput) { _, new in
                                        tickerInput = new.uppercased().filter { $0.isLetter || $0 == "." }
                                    }
                                if !tickerInput.isEmpty {
                                    Button { addTicker() } label: {
                                        Text("Add")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Theme.accent)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Theme.bg3)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            // Suggest user's own holdings
                            if !appState.positions.isEmpty {
                                Text("Your holdings")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.text3)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(appState.positions.prefix(6)) { pos in
                                            if !tickers.contains(pos.ticker) {
                                                Button {
                                                    if tickers.count < 6 {
                                                        tickers.append(pos.ticker)
                                                    }
                                                } label: {
                                                    Text("$\(pos.ticker)")
                                                        .font(.system(size: 12, weight: .semibold))
                                                        .foregroundStyle(Theme.text2)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 6)
                                                        .background(Theme.bg3)
                                                        .clipShape(Capsule())
                                                        .overlay(Capsule().stroke(Theme.border, lineWidth: 1))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                // ── Post button ──────────────────────────────────────────────
                VStack(spacing: 0) {
                    Divider().background(Theme.border)
                    Button {
                        submitPost()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Post")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canPost ? Theme.accentGradient : LinearGradient(colors: [Theme.text4, Theme.text4], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .disabled(!canPost)
                    .background(Theme.bg)
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.text2)
                }
            }
            .onAppear { textFocused = true }
        }
    }

    private func addTicker() {
        let t = tickerInput.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty, !tickers.contains(t), tickers.count < 6 else {
            tickerInput = ""
            return
        }
        tickers.append(t)
        tickerInput = ""
    }

    private func submitPost() {
        let post = UserPost(
            text: postText.trimmingCharacters(in: .whitespacesAndNewlines),
            tickers: tickers,
            sentiment: sentiment
        )
        appState.addUserPost(post)
        dismiss()
    }

    private func sentimentColor(_ s: String) -> Color {
        switch s {
        case "Bullish": return Theme.gain
        case "Bearish": return Theme.loss
        default: return Theme.accent
        }
    }
}
