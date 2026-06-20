import SwiftUI

struct CreatePostView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    @State private var contentType: ComposeType = .post
    @State private var postText = ""
    @State private var tickerInput = ""
    @State private var tickers: [String] = []
    @State private var sentiment = "Bullish"
    @State private var hasMedia = false
    @FocusState private var textFocused: Bool

    private let sentiments = ["Bullish", "Bearish", "Neutral"]
    private var maxChars: Int { contentType == .post ? 280 : 150 }

    var canPost: Bool {
        let hasText = !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if contentType == .post { return hasText }
        return hasMedia || hasText
    }

    enum ComposeType: String, CaseIterable {
        case post = "Post"
        case short = "Short"
        case video = "Video"

        var icon: String {
            switch self {
            case .post:  return "square.and.pencil"
            case .short: return "play.circle.fill"
            case .video: return "video.fill"
            }
        }
        var submitLabel: String {
            switch self {
            case .post:  return "Post"
            case .short: return "Share Short"
            case .video: return "Upload Video"
            }
        }
        var gradientColors: [Color] {
            switch self {
            case .post:  return [Color(hex: "#5B5BD6"), Color(hex: "#7C7CF0")]
            case .short: return [Color(hex: "#F43F5E"), Color(hex: "#E11D48")]
            case .video: return [Color(hex: "#7C3AED"), Color(hex: "#5B21B6")]
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Theme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Type selector ─────────────────────────────────────
                        typeSelector
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 20)

                        // ── Author row ────────────────────────────────────────
                        authorRow
                            .padding(.horizontal, 20)
                            .padding(.bottom, 18)

                        // ── Media area (Short / Video) ─────────────────────────
                        if contentType != .post {
                            mediaUploadArea
                                .padding(.horizontal, 20)
                                .padding(.bottom, 18)
                        }

                        // ── Caption / text ─────────────────────────────────────
                        captionEditor
                            .padding(.horizontal, 20)
                            .padding(.bottom, 6)

                        // ── Char counter ──────────────────────────────────────
                        HStack {
                            Spacer()
                            let remaining = maxChars - postText.count
                            ZStack {
                                Circle()
                                    .stroke(Theme.bg3, lineWidth: 2)
                                    .frame(width: 22, height: 22)
                                Circle()
                                    .trim(from: 0, to: CGFloat(postText.count) / CGFloat(maxChars))
                                    .stroke(remaining < 30 ? Theme.loss : Theme.accent, lineWidth: 2)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 22, height: 22)
                            }
                            Text("\(remaining)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(remaining < 30 ? Theme.loss : Theme.text3)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                        Divider().padding(.horizontal, 20)

                        // ── Ticker tags ───────────────────────────────────────
                        tickerSection
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 100)
                    }
                }

                // ── Sticky post button ────────────────────────────────────────
                postButton
            }
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.text2)
                }
            }
            .onAppear {
                if contentType == .post { textFocused = true }
            }
        }
    }

    // MARK: - Type Selector

    private var typeSelector: some View {
        HStack(spacing: 10) {
            ForEach(ComposeType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        contentType = type
                        hasMedia = false
                        if type == .post { textFocused = true }
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: type.icon)
                            .font(.system(size: 14, weight: .semibold))
                        Text(type.rawValue)
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(contentType == type ? .white : Theme.text3)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        contentType == type
                            ? AnyShapeStyle(LinearGradient(colors: type.gradientColors, startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(Theme.bg3)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(contentType == type ? Color.clear : Theme.border, lineWidth: 1)
                    )
                    .shadow(color: contentType == type ? type.gradientColors[0].opacity(0.35) : .clear, radius: 8, y: 3)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Author Row

    private var authorRow: some View {
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
                HStack(spacing: 6) {
                    Text(appState.settings.username)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.text3)
                    Text("·")
                        .foregroundStyle(Theme.text4)
                    Text(contentType.rawValue)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(contentType.gradientColors[0])
                }
            }

            Spacer()

            if contentType == .post {
                // Sentiment picker only for posts
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
        }
    }

    // MARK: - Media Upload Area

    private var mediaUploadArea: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                hasMedia.toggle()
            }
        } label: {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: hasMedia
                                ? contentType.gradientColors.map { $0.opacity(0.7) }
                                : [Theme.bg3, Theme.bg2],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: contentType == .short ? 260 : 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                hasMedia ? contentType.gradientColors[0].opacity(0.5) : Theme.border,
                                style: StrokeStyle(lineWidth: hasMedia ? 1.5 : 1, dash: hasMedia ? [] : [8, 4])
                            )
                    )

                if hasMedia {
                    // Mock "selected" state — shows a gradient thumbnail
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.15))
                                .frame(width: 56, height: 56)
                            Image(systemName: contentType == .short ? "play.fill" : "checkmark")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                                .offset(x: contentType == .short ? 2 : 0)
                        }
                        Text(contentType == .short ? "Short ready" : "Video ready")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Tap to change")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    // Abstract wave visual
                    .overlay(alignment: .bottomTrailing) {
                        Canvas { ctx, size in
                            var p = Path()
                            let w = size.width; let h = size.height
                            p.move(to: .init(x: 0, y: h * 0.7))
                            for x in stride(from: 0.0, to: w, by: 2) {
                                p.addLine(to: .init(x: x, y: h * 0.7 + sin(x * 0.04) * 14))
                            }
                            ctx.stroke(p, with: .color(.white.opacity(0.12)), lineWidth: 2)
                        }
                        .allowsHitTesting(false)
                    }
                    // Duration badge for shorts
                    if contentType == .short {
                        Text("0:15")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(.black.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .padding(12)
                    }
                } else {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(contentType.gradientColors[0].opacity(0.12))
                                .frame(width: 60, height: 60)
                                .overlay(Circle().stroke(contentType.gradientColors[0].opacity(0.25), lineWidth: 1))
                            Image(systemName: contentType == .short ? "video.circle.fill" : "arrow.up.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(contentType.gradientColors[0])
                        }

                        Text(contentType == .short ? "Add Short Video" : "Upload Video")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.text)

                        Text(contentType == .short
                             ? "Up to 60 seconds · Shot vertically"
                             : "Up to 10 minutes · MP4 or MOV")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.text3)

                        HStack(spacing: 8) {
                            mediaSourceChip("camera.fill", "Camera")
                            mediaSourceChip("photo.on.rectangle.angled", "Library")
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func mediaSourceChip(_ icon: String, _ label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 11, weight: .semibold))
            Text(label).font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(contentType.gradientColors[0])
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(contentType.gradientColors[0].opacity(0.10))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(contentType.gradientColors[0].opacity(0.25), lineWidth: 1))
    }

    // MARK: - Caption Editor

    private var captionEditor: some View {
        ZStack(alignment: .topLeading) {
            if postText.isEmpty {
                Text(contentType == .post
                     ? "What's your market take?"
                     : contentType == .short
                     ? "Add a caption…"
                     : "Describe your video…")
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
                .frame(minHeight: contentType == .post ? 120 : 72)
                .focused($textFocused)
                .onChange(of: postText) { _, new in
                    if new.count > maxChars { postText = String(new.prefix(maxChars)) }
                }
        }
    }

    // MARK: - Ticker Section

    private var tickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TAG STOCKS")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(Theme.text3)
                .tracking(1.5)

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
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Theme.accentBg)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Theme.accent.opacity(0.3), lineWidth: 1))
                        }
                    }
                }
            }

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
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Theme.accent)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(Theme.bg3)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if !appState.positions.isEmpty {
                Text("Your holdings")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text3)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(appState.positions.prefix(6)) { pos in
                            if !tickers.contains(pos.ticker) {
                                Button {
                                    if tickers.count < 6 { tickers.append(pos.ticker) }
                                } label: {
                                    Text("$\(pos.ticker)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(Theme.text2)
                                        .padding(.horizontal, 10).padding(.vertical, 6)
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
    }

    // MARK: - Post Button

    private var postButton: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                submitPost()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: contentType == .post ? "paperplane.fill" : contentType == .short ? "play.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text(contentType.submitLabel)
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    canPost
                        ? AnyShapeStyle(LinearGradient(colors: contentType.gradientColors, startPoint: .leading, endPoint: .trailing))
                        : AnyShapeStyle(Theme.bg3)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .shadow(color: canPost ? contentType.gradientColors[0].opacity(0.35) : .clear, radius: 10, y: 3)
            }
            .disabled(!canPost)
            .background(Theme.bg)
        }
    }

    // MARK: - Helpers

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
            sentiment: sentiment,
            contentType: contentType.rawValue.lowercased(),
            hasMedia: hasMedia
        )
        appState.addUserPost(post)
        dismiss()
    }

    private func sentimentColor(_ s: String) -> Color {
        switch s {
        case "Bullish": return Theme.gain
        case "Bearish": return Theme.loss
        default:        return Theme.accent
        }
    }
}
