import SwiftUI
import UIKit

enum Theme {
    // MARK: - Backgrounds
    static var bg: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(hex: "#0A0A0F") : UIColor(hex: "#F2F2F7") })
    }
    static var bg2: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(hex: "#0F0F17") : UIColor(hex: "#FFFFFF") })
    }
    static var bg3: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(hex: "#141420") : UIColor(hex: "#E8E8EE") })
    }

    // MARK: - Cards
    static var card: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(hex: "#111118") : UIColor(hex: "#FFFFFF") })
    }
    static var cardRaised: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(hex: "#16161F") : UIColor(hex: "#F5F5FA") })
    }
    static var border: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.09)
            : UIColor.black.withAlphaComponent(0.10) })
    }
    static var borderActive: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.18)
            : UIColor.black.withAlphaComponent(0.18) })
    }

    // MARK: - Tab bar
    static var tabBar: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(hex: "#0D0D14").withAlphaComponent(0.97)
            : UIColor(hex: "#F8F8FE").withAlphaComponent(0.97) })
    }

    // MARK: - Text
    static var text: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(hex: "#F2F2F7") : UIColor(hex: "#1C1C1E") })
    }
    static var text2: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(hex: "#A8A8B8") : UIColor(hex: "#636366") })
    }
    static var text3: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(hex: "#5C5C72") : UIColor(hex: "#AEAEB2") })
    }
    static var text4: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(hex: "#3A3A50") : UIColor(hex: "#C7C7CC") })
    }

    // MARK: - Semantic (work on both modes)
    static let accent     = Color(hex: "#5B5BD6")
    static let accent2    = Color(hex: "#7C7CF0")
    static let gain       = Color(hex: "#00D26A")
    static let loss       = Color(hex: "#FF4757")
    static let gold       = Color(hex: "#F5A623")
    static let nanoBanana = Color(hex: "#D4F03C")

    // MARK: - Semantic dim fills
    static var gainBg:         Color { gain.opacity(0.12) }
    static var lossBg:         Color { loss.opacity(0.12) }
    static var accentBg:       Color { accent.opacity(0.12) }
    static var goldBg:         Color { gold.opacity(0.15) }
    static var nanoBananaBg:   Color { nanoBanana.opacity(0.12) }

    // MARK: - Shadow & Overlay
    static var shadow: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor.black.withAlphaComponent(0.50)
            : UIColor.black.withAlphaComponent(0.12) })
    }
    static var overlay: Color {
        Color(UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor.black.withAlphaComponent(0.40)
            : UIColor.black.withAlphaComponent(0.15) })
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Alloc bar — nano banana leads
    static let allocColors: [Color] = [
        Color(hex: "#D4F03C"), Color(hex: "#5B5BD6"), Color(hex: "#7C7CF0"),
        Color(hex: "#A78BFA"), Color(hex: "#60A5FA"), Color(hex: "#34D399"),
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
    static let nanoBananaGradient = LinearGradient(
        colors: [Color(hex: "#D4F03C"), Color(hex: "#A8D020")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let aiHeroGradient = LinearGradient(
        colors: [
            Color(hex: "#06080F"),
            Color(hex: "#0C1220"),
            Color(hex: "#0F1930"),
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let autopilotHeroGradient = LinearGradient(
        colors: [
            Color(hex: "#0D0726"),
            Color(hex: "#1A0938"),
            Color(hex: "#2D1B6B"),
            Color(hex: "#5B3BA8"),
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

// MARK: - Card ViewModifiers

struct STALKCard: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var radius: CGFloat = 20
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(Theme.border, lineWidth: 1))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.40 : 0.08), radius: 8, x: 0, y: 2)
    }
}

struct STALKCardRaised: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var radius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(Theme.cardRaised)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(Theme.borderActive, lineWidth: 1.5))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.55 : 0.10), radius: 16, x: 0, y: 6)
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

extension UIColor {
    convenience init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

// MARK: - Premium Icon Container

struct PremiumIconView: View {
    let symbol: String
    let colors: [Color]
    var size: CGFloat = 44
    var iconSize: CGFloat = 20
    var radius: CGFloat? = nil

    var body: some View {
        let r = radius ?? size * 0.26
        ZStack {
            RoundedRectangle(cornerRadius: r)
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size, height: size)
            Image(systemName: symbol)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
        }
    }
}

// MARK: - Formatting

extension Double {
    func fmtPrice() -> String { String(format: "$%.2f", self) }
    func fmtPct() -> String { (self >= 0 ? "+" : "") + String(format: "%.2f%%", self) }
    func fmtChange() -> String { (self >= 0 ? "+" : "") + String(format: "$%.2f", self) }
    func fmtCompact() -> String {
        let v = abs(self)
        let prefix = self < 0 ? "-" : ""
        switch v {
        case 1_000_000_000...: return "\(prefix)$\(String(format: "%.1f", v / 1_000_000_000))B"
        case 1_000_000...:     return "\(prefix)$\(String(format: "%.1f", v / 1_000_000))M"
        case 1_000...:         return "\(prefix)$\(String(format: "%.1f", v / 1_000))K"
        default:               return fmtPrice()
        }
    }
}
