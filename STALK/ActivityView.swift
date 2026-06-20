import SwiftUI

struct ActivityView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    var todayItems: [ActivityItem]    { appState.notifications.filter(\.isToday) }
    var thisWeekItems: [ActivityItem] { appState.notifications.filter { !$0.isToday } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !todayItems.isEmpty {
                        sectionHeader("Today")
                        VStack(spacing: 0) {
                            ForEach(Array(todayItems.enumerated()), id: \.element.id) { i, item in
                                ActivityRow(item: item)
                                    .staggerEntrance(index: i)
                                if i < todayItems.count - 1 {
                                    Divider().padding(.leading, 66)
                                }
                            }
                        }
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }

                    if !thisWeekItems.isEmpty {
                        sectionHeader("This Week")
                        VStack(spacing: 0) {
                            ForEach(Array(thisWeekItems.enumerated()), id: \.element.id) { i, item in
                                ActivityRow(item: item)
                                    .staggerEntrance(index: i + (todayItems.count))
                                if i < thisWeekItems.count - 1 {
                                    Divider().padding(.leading, 66)
                                }
                            }
                        }
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }

                    Color.clear.frame(height: 40)
                }
                .padding(.top, 10)
            }
            .background(Theme.bg)
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.text3)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(Theme.text3)
            .kerning(2.0)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
    }
}

struct ActivityRow: View {
    let item: ActivityItem

    var iconInfo: (symbol: String, color: Color) {
        switch item.type {
        case .copied:     return ("doc.on.doc.fill",           Theme.accent)
        case .followed:   return ("person.fill.badge.plus",    Color(hex: "#22C55E"))
        case .copyPnl:    return ("chart.line.uptrend.xyaxis", Theme.nanoBanana)
        case .earnings:   return ("calendar.badge.exclamationmark", Color(hex: "#F59E0B"))
        case .whale:      return ("waveform.path.ecg",         Color(hex: "#F43F5E"))
        case .friendPost: return ("bubble.left.and.bubble.right.fill", Theme.accent)
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconInfo.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: iconInfo.symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(iconInfo.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Group {
                    Text(item.actor)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.text)
                    + Text(" \(item.detail)")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.text2)
                }
                .lineLimit(2)

                HStack(spacing: 6) {
                    if let value = item.value {
                        Text(value)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(value.hasPrefix("+") ? Theme.gain : value.hasPrefix("-") ? Theme.loss : Theme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background((value.hasPrefix("+") ? Theme.gain : Theme.accent).opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Text(item.timeAgo)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.text4)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
