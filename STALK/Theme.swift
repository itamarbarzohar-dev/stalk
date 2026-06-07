import SwiftUI

enum Theme {
    static let accent = Color(hex: "#5B5BD6")
    static let accent2 = Color(hex: "#8B7CF6")
    static let gain = Color(hex: "#059669")
    static let loss = Color(hex: "#E5534B")
    static let gainBg = Color(hex: "#ECFDF5")
    static let lossBg = Color(hex: "#FEF2F2")
    static let bg = Color(hex: "#F7F8FC")
    static let bg2 = Color(hex: "#EEEEF5")
    static let card = Color.white
    static let text = Color(hex: "#18181B")
    static let text2 = Color(hex: "#52525B")
    static let text3 = Color(hex: "#A1A1AA")
    static let border = Color(hex: "#EBEBF0")
    static let gold = Color(hex: "#D97706")
    static let goldBg = Color(hex: "#FFFBEB")

    static let allocColors: [Color] = [
        Color(hex: "#5B5BD6"), Color(hex: "#8B7CF6"), Color(hex: "#C4B5FD"),
        Color(hex: "#818CF8"), Color(hex: "#A5B4FC"), Color(hex: "#E0E7FF"),
    ]

    static let accentGradient = LinearGradient(
        colors: [Color(hex: "#5B5BD6"), Color(hex: "#8B7CF6")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

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

extension Double {
    func fmtPrice() -> String { String(format: "$%.2f", self) }
    func fmtPct() -> String { (self >= 0 ? "+" : "") + String(format: "%.2f%%", self) }
    func fmtChange() -> String { (self >= 0 ? "+" : "") + String(format: "$%.2f", self) }
}
