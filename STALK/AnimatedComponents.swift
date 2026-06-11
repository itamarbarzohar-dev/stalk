import SwiftUI

// Animated price that transitions smoothly when value changes
struct AnimatedPrice: View {
    let value: Double
    var format: (Double) -> String = { $0.fmtPrice() }
    var font: Font = .system(size: 15, weight: .bold)
    var color: Color = Theme.text

    var body: some View {
        Text(format(value))
            .font(font)
            .foregroundStyle(color)
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)
    }
}

// Animated percent change with color that flips green/red
struct AnimatedChangeLabel: View {
    let value: Double  // e.g. 2.34 means +2.34%
    var font: Font = .system(size: 13, weight: .bold)

    var color: Color { value >= 0 ? Theme.gain : Theme.loss }

    var body: some View {
        Text(value.fmtPct())
            .font(font)
            .foregroundStyle(color)
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)
    }
}

// Card stagger entrance modifier
struct StaggerEntrance: ViewModifier {
    let index: Int
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
            .onAppear {
                let delay = min(Double(index) * 0.06, 0.30)
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75).delay(delay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func staggerEntrance(index: Int) -> some View {
        modifier(StaggerEntrance(index: index))
    }
}
