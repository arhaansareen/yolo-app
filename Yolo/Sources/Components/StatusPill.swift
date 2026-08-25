import SwiftUI

struct StatusPill: View {
    let status: YoloGroup.GroupStatus

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(status.color)
                .frame(width: 6, height: 6)
            Text(status.label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(status.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(status.color.opacity(0.1))
        .clipShape(Capsule())
    }
}

struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.yoloGold : Color.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(isSelected ? Color.yoloGold.opacity(0.12) : Color.yoloSurface2)
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(isSelected ? Color.yoloGold : Color.yoloBorder, lineWidth: isSelected ? 1 : 0.5)
                )
        }
        .buttonStyle(PressEffectButtonStyle())
    }
}
