# Premium Feature Card Specs — Perplexity-Style
**Author:** Luna (UX Designer)
**Date:** 2026-06-09
**Status:** Ready for implementation

---

## Design Language

These new feature cards follow the same dark foundation as the rest of STALK (#0A0A0F bg, #111118 card) but push further into "information-dense premium" territory. Reference points:
- **Sector Heat Map:** Bloomberg Terminal color intensity grids
- **AI Market Context:** Perplexity answer cards, Linear update banners
- **Portfolio Health Score:** Robinhood Gold ring, but native Canvas — no third-party
- **Trending Tickers:** Nothing Phone notification panel density

No third-party dependencies. All Canvas, native SwiftUI animations, and system materials.

---

## 1. Sector Heat Map

### Color Logic

Map sector % change to a color using linear interpolation between `Theme.loss` and `Theme.gain`, passing through a neutral center.

```swift
extension Color {
    // pctChange: typically -5.0 to +5.0 range, clamp at ±5
    static func heatColor(for pctChange: Double) -> Color {
        let clamped = max(-5.0, min(5.0, pctChange))
        let normalized = (clamped + 5.0) / 10.0  // 0.0 (loss) to 1.0 (gain)

        if normalized < 0.5 {
            // Interpolate: Theme.loss -> neutral
            let t = normalized / 0.5  // 0.0 to 1.0
            // Theme.loss = #FF4757, neutral = #1A1A2E
            let r = 1.0 * (1 - t) + 0.102 * t
            let g = 0.278 * (1 - t) + 0.102 * t
            let b = 0.341 * (1 - t) + 0.180 * t
            return Color(red: r, green: g, blue: b)
        } else {
            // Interpolate: neutral -> Theme.gain
            let t = (normalized - 0.5) / 0.5  // 0.0 to 1.0
            // neutral = #1A1A2E, Theme.gain = #00D26A
            let r = 0.102 * (1 - t) + 0.0 * t
            let g = 0.102 * (1 - t) + 0.824 * t
            let b = 0.180 * (1 - t) + 0.416 * t
            return Color(red: r, green: g, blue: b)
        }
    }
}
```

**Intensity overlay:** On top of the heat color, multiply opacity by `min(1.0, abs(pctChange) / 3.0)` so a +0.1% sector tile looks barely colored, while a +4.5% sector glows bright.

### Tile Dimensions

Use a `LazyVGrid` with 3 columns:

```swift
// Grid setup
LazyVGrid(
    columns: [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6)
    ],
    spacing: 6
) {
    ForEach(sectors) { sector in
        SectorTile(sector: sector)
    }
}
```

Each tile:
- **Height:** 72pt fixed
- **Corner radius:** 12pt
- **Background:** `Color.heatColor(for: sector.changePercent)` with opacity 0.85
- **Border:** `Color.white.opacity(0.08)`, 1pt
- **Padding:** 10pt horizontal, 8pt vertical

### Tile Typography

```swift
struct SectorTile: View {
    let sector: SectorData  // (name: String, changePercent: Double, symbol: String)

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(sector.symbol)  // e.g. "⚡", "💻", "🏦"
                    .font(.system(size: 14))
                Spacer()
                Text(sector.changePercent.fmtPct())
                    .font(.system(size: 12, weight: .black))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            Text(sector.name)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)
                .textCase(.uppercase)
                .kerning(0.3)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(height: 72)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.heatColor(for: sector.changePercent))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}
```

### Sector Data Model

```swift
struct SectorData: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let changePercent: Double
}

// Static seed data (replace with API):
let SECTORS: [SectorData] = [
    SectorData(name: "Technology",   symbol: "💻", changePercent: 1.4),
    SectorData(name: "Energy",       symbol: "⚡", changePercent: -0.8),
    SectorData(name: "Financials",   symbol: "🏦", changePercent: 0.3),
    SectorData(name: "Healthcare",   symbol: "🏥", changePercent: -1.2),
    SectorData(name: "Consumer",     symbol: "🛒", changePercent: 2.1),
    SectorData(name: "Industrials",  symbol: "🏗️", changePercent: -0.1),
    SectorData(name: "Real Estate",  symbol: "🏢", changePercent: 0.7),
    SectorData(name: "Materials",    symbol: "⛏️", changePercent: -2.3),
    SectorData(name: "Utilities",    symbol: "💡", changePercent: 0.0),
]
```

### Card Shell

```swift
VStack(alignment: .leading, spacing: 14) {
    HStack {
        VStack(alignment: .leading, spacing: 2) {
            Text("Sector Heat Map")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.text)
            Text("Today's sector performance")
                .font(.system(size: 11))
                .foregroundStyle(Theme.text3)
        }
        Spacer()
        // Legend
        HStack(spacing: 4) {
            Text("Bear")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Theme.loss.opacity(0.8))
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [Theme.loss, Color(hex: "#1A1A2E"), Theme.gain],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .frame(width: 40, height: 6)
            Text("Bull")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Theme.gain.opacity(0.8))
        }
    }

    // Tile grid (see above)
    LazyVGrid(...) { ... }
}
.padding(18)
.background(Theme.card)
.clipShape(RoundedRectangle(cornerRadius: 24))
.overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border, lineWidth: 1))
```

---

## 2. AI Market Context Card

### Card Structure

This card looks like a "typed" AI answer — think Perplexity, but in a finance card. The text appears to type itself in on load.

```swift
struct AIMarketContextCard: View {
    let headline: String        // e.g. "Markets pulled back on Fed commentary"
    let body: String            // 2–3 sentence context paragraph
    let sources: [String]       // e.g. ["Reuters", "Bloomberg", "WSJ"]

    @State private var visibleCharCount = 0
    @State private var showCursor = true

    var displayedBody: String {
        String(body.prefix(visibleCharCount))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header with glass border gradient
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#5B5BD6"), Color(hex: "#818CF8")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    Text("✦")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("AI Market Context")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text("Powered by STALK AI")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.text3)
                }

                Spacer()

                // Live pill
                HStack(spacing: 4) {
                    Circle().fill(Theme.gain).frame(width: 6, height: 6)
                    Text("Live")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.gain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Theme.gainBg)
                .clipShape(Capsule())
            }
            .padding(.bottom, 14)

            // Headline
            Text(headline)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.text)
                .padding(.bottom, 10)

            // Typing body text + cursor
            HStack(alignment: .bottom, spacing: 0) {
                Text(displayedBody)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(4)

                if visibleCharCount < body.count {
                    Rectangle()
                        .fill(Theme.accent)
                        .frame(width: 2, height: 14)
                        .opacity(showCursor ? 1 : 0)
                        .animation(
                            .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                            value: showCursor
                        )
                }
            }
            .padding(.bottom, 14)

            // Source pills
            HStack(spacing: 6) {
                Text("Sources:")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.text3)

                ForEach(sources, id: \.self) { source in
                    Text(source)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.accent2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.accentBg)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(18)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    // Gradient border: indigo top-left, fade to transparent bottom-right
                    LinearGradient(
                        colors: [
                            Color(hex: "#5B5BD6").opacity(0.5),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Theme.accent.opacity(0.08), radius: 20, y: 6)
        .onAppear {
            showCursor = false  // Trigger cursor blink
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                showCursor = true
            }
            // Type in the body text character by character
            // 25ms per character — at this speed, ~2 sentences takes ~1.5 seconds
            for i in 0...body.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.018) {
                    visibleCharCount = i
                }
            }
        }
    }
}
```

**Typing speed:** 18ms per character. Adjust as needed. If the body is long (>150 chars), speed up to 10ms.

**Note:** The gradient border (indigo top-left fading to near-transparent) is the key premium detail that differentiates this from a plain card. Jordan: do not simplify this to a solid border stroke.

---

## 3. Portfolio Health Score

### Ring Chart via Canvas

```swift
struct PortfolioHealthRing: View {
    let score: Int  // 0–100

    private let lineWidth: CGFloat = 10
    private let ringSize: CGFloat = 90

    var ringColor: Color {
        switch score {
        case 80...100: return Theme.gain          // #00D26A — healthy
        case 60..<80:  return Color(hex: "#A3E635") // yellow-green — moderate
        case 40..<60:  return Theme.gold           // #F5A623 — caution
        default:       return Theme.loss           // #FF4757 — poor
        }
    }

    var grade: String {
        switch score {
        case 80...100: return "A"
        case 60..<80:  return "B"
        case 40..<60:  return "C"
        default:       return "D"
        }
    }

    var body: some View {
        ZStack {
            // Track ring (background)
            Canvas { context, size in
                let rect = CGRect(
                    x: lineWidth / 2,
                    y: lineWidth / 2,
                    width: size.width - lineWidth,
                    height: size.height - lineWidth
                )
                var path = Path()
                path.addArc(
                    center: CGPoint(x: size.width / 2, y: size.height / 2),
                    radius: (size.width - lineWidth) / 2,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(270),
                    clockwise: false
                )
                context.stroke(
                    path,
                    with: .color(.white.opacity(0.08)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            }

            // Score ring (filled arc)
            Canvas { context, size in
                let fillAngle = Double(score) / 100.0 * 360.0
                var path = Path()
                path.addArc(
                    center: CGPoint(x: size.width / 2, y: size.height / 2),
                    radius: (size.width - lineWidth) / 2,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(-90 + fillAngle),
                    clockwise: false
                )
                context.stroke(
                    path,
                    with: .color(ringColor),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            }
            .shadow(color: ringColor.opacity(0.5), radius: 6)
            // Glow shadow on the ring arc — makes it look lit from within

            // Center text
            VStack(spacing: 0) {
                Text(grade)
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(ringColor)
                Text("\(score)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.text3)
                    .monospacedDigit()
            }
        }
        .frame(width: ringSize, height: ringSize)
    }
}
```

### Full Health Score Card

```swift
struct PortfolioHealthCard: View {
    @Environment(AppState.self) var appState

    // Mirror the scoring logic currently in AIAgentCard.healthScore
    // (Jordan: extract this to AppState as a computed var)

    var score: Int { /* scoring logic */ }
    var insights: [String] { /* 2-3 short insight strings */ }

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            PortfolioHealthRing(score: score)

            VStack(alignment: .leading, spacing: 8) {
                Text("Portfolio Health")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.text)

                ForEach(insights, id: \.self) { insight in
                    HStack(alignment: .top, spacing: 6) {
                        Circle()
                            .fill(Theme.accent2)
                            .frame(width: 4, height: 4)
                            .padding(.top, 5)
                        Text(insight)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.text2)
                            .lineSpacing(2)
                    }
                }
            }
        }
        .padding(18)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border, lineWidth: 1))
    }
}
```

### Score Thresholds (copy from AIAgentCard, unify into AppState)

| Score | Grade | Ring Color |
|---|---|---|
| 80–100 | A | `#00D26A` (Theme.gain) |
| 60–79 | B | `#A3E635` |
| 40–59 | C | `#F5A623` (Theme.gold) |
| 0–39 | D | `#FF4757` (Theme.loss) |

---

## 4. Trending Ticker Rows

### Design Principle

Maximum information density. No wasted space. Each row communicates: ticker, name, price, change, and a 7-day sparkline — all in 52pt of height.

```swift
struct TrendingTickerRow: View {
    let rank: Int
    let ticker: String
    let name: String
    let price: Double
    let changePercent: Double
    let sparkline: [Double]   // 7 data points, recent prices
    let mentionCount: Int     // social mentions, optional

    var isUp: Bool { changePercent >= 0 }

    var body: some View {
        HStack(spacing: 0) {

            // Rank number
            Text("\(rank)")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(Theme.text4)
                .frame(width: 22, alignment: .leading)

            // Ticker + name
            VStack(alignment: .leading, spacing: 2) {
                Text(ticker)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.text)
                Text(name)
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.text3)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Sparkline (7-day mini chart)
            SparklineView(data: sparkline, color: isUp ? Theme.gain : Theme.loss)
                .frame(width: 48, height: 24)
                .padding(.trailing, 12)

            // Price + change
            VStack(alignment: .trailing, spacing: 2) {
                AnimatedPrice(value: price) { $0.fmtPrice() }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.text)

                Text(changePercent.fmtPct())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isUp ? Theme.gain : Theme.loss)
                    .monospacedDigit()
            }
        }
        .frame(height: 52)
        .contentShape(Rectangle())
    }
}
```

### Sparkline View (native Canvas, no third-party)

```swift
struct SparklineView: View {
    let data: [Double]
    let color: Color

    var body: some View {
        Canvas { context, size in
            guard data.count >= 2 else { return }

            let minVal = data.min() ?? 0
            let maxVal = data.max() ?? 1
            let range = max(maxVal - minVal, 0.01)

            let step = size.width / CGFloat(data.count - 1)

            var path = Path()
            for (i, val) in data.enumerated() {
                let x = CGFloat(i) * step
                let y = size.height - CGFloat((val - minVal) / range) * size.height
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            // Stroke the line
            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
            )

            // Fill below the line with gradient
            var fillPath = path
            fillPath.addLine(to: CGPoint(x: size.width, y: size.height))
            fillPath.addLine(to: CGPoint(x: 0, y: size.height))
            fillPath.closeSubpath()

            context.fill(
                fillPath,
                with: .linearGradient(
                    Gradient(colors: [color.opacity(0.2), color.opacity(0)]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 0, y: size.height)
                )
            )
        }
    }
}
```

### Trending Card Shell

```swift
struct TrendingTickersCard: View {
    let tickers: [TrendingItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Trending")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.text)
                    Text("Most watched right now")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text3)
                }
                Spacer()
                // Refresh timestamp
                Text("Updated 2m ago")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.text4)
            }
            .padding(.bottom, 12)

            VStack(spacing: 0) {
                ForEach(Array(tickers.enumerated()), id: \.element.ticker) { i, item in
                    TrendingTickerRow(
                        rank: i + 1,
                        ticker: item.ticker,
                        name: item.name,
                        price: item.price,
                        changePercent: item.changePercent,
                        sparkline: item.sparkline,
                        mentionCount: item.mentionCount
                    )

                    if i < tickers.count - 1 {
                        Divider()
                            .background(Theme.border)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border, lineWidth: 1))
    }
}
```

**Row height:** Fixed 52pt. No dynamic heights — this is a dense list, not a card grid.
**Divider:** `Theme.border` (white 6%) — barely visible, just enough to separate rows.
**No padding between rows:** The 52pt fixed height handles breathing room. Adding VStack spacing would ruin the density.
