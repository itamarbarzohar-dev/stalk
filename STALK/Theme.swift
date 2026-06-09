import SwiftUI

enum Theme {
    // MARK: - Backgrounds
    static let bg          = Color(hex: "#0A0A0F")   // primary app bg
    static let bg2         = Color(hex: "#0F0F17")   // secondary bg, inside cards
    static let bg3         = Color(hex: "#141420")   // tertiary bg, nested containers

    // MARK: - Cards
    static let card        = Color(hex: "#111118")
    static let cardRaised  = Color(hex: "#16161F")
    static let border      = Color.white.opacity(0.06)
    static let borderActive = Color.white.opacity(0.14)

    // MARK: - Text
    static let text        = Color(hex: "#F2F2F7")
    static let text2       = Color(hex: "#A8A8B8")
    static let text3       = Color(hex: "#5C5C72")
    static let text4       = Color(hex: "#3A3A50")

    // MARK: - Semantic
    static let accent      = Color(hex: "#5B5BD6")
    static let accent2     = Color(hex: "#7C7CF0")
    static let gain        = Color(hex: "#00D26A")
    static let loss        = Color(hex: "#FF4757")
    static let gold        = Color(hex: "#F5A623")

    // MARK: - Semantic dim fills
    static var gainBg: Color   { gain.opacity(0.12) }
    static var lossBg: Color   { loss.opacity(0.12) }
    static var accentBg: Color { accent.opacity(0.12) }
    static var goldBg: Color   { gold.opacity(0.15) }

    // MARK: - Alloc bar
    static let allocColors: [Color] = [
        Color(hex: "#5B5BD6"), Color(hex: "#7C7CF0"), Color(hex: "#A78BFA"),
        Color(hex: "#818CF8"), Color(hex: "#60A5FA"), Color(hex: "#34D399"),
    ]

    // MARK: - Gradients
    static let accentGradient = LinearGradient(
        colors: [Color(hex: "#5B5BD6"), Color(hex: "#7C7CF0")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gainGradient = LinearGradient(
        colors: [Color(hex: "#00D26A"), Color(hex: "#00B85C")],
        startPoint: .leading, endPoint: .trailing
    )
    static let lossGradient = LinearGradient(
        colors: [Color(hex: "#FF4757"), Color(hex: "#E03040")],
        startPoint: .leading, endPoint: .trailing
    )
    static let goldGradient = LinearGradient(
        colors: [Color(hex: "#F5A623"), Color(hex: "#E8952A")],
        startPoint: .leading, endPoint: .trailing
    )
}

// MARK: - Card ViewModifiers

struct STALKCard: ViewModifier {
    var radius: CGFloat = 20
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(Theme.border, lineWidth: 1))
            .shadow(color: .black.opacity(0.40), radius: 8, x: 0, y: 2)
    }
}

struct STALKCardRaised: ViewModifier {
    var radius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(Theme.cardRaised)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(Theme.borderActive, lineWidth: 1.5))
            .shadow(color: .black.opacity(0.55), radius: 16, x: 0, y: 6)
    }
}

extension View {
    func stalkCard(radius: CGFloat = 20, padding: CGFloat = 16) -> some View {
        modifier(STALKCard(radius: radius, padding: padding))
    }
    func stalkCardRaised(radius: CGFloat = 20) -> some View {
        modifier(STALKCardRaised(radius: radius))
    }
}

// MARK: - Color Init

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Formatting

extension Double {
    func fmtPrice() -> String { String(format: "$%.2f", self) }
    func fmtPct() -> String { (self >= 0 ? "+" : "") + String(format: "%.2f%%", self) }
    func fmtChange() -> String { (self >= 0 ? "+" : "") + String(format: "$%.2f", self) }
}
