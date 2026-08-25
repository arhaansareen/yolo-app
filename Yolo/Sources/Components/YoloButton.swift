import SwiftUI

struct YoloButton: View {
    let title: String
    var icon: String? = nil
    let style: ButtonVariant
    let action: () -> Void

    enum ButtonVariant { case primary, secondary, ghost, destructive }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: style == .secondary ? 1 : 0)
            )
        }
        .buttonStyle(GoldPressButtonStyle())
    }

    private var foreground: Color {
        switch style {
        case .primary:     return .black
        case .secondary:   return .yoloGold
        case .ghost:       return .yoloTextSecondary
        case .destructive: return .yoloRed
        }
    }
    private var background: Color {
        switch style {
        case .primary:     return .yoloGold
        case .secondary:   return .clear
        case .ghost:       return .clear
        case .destructive: return .yoloRed.opacity(0.1)
        }
    }
    private var borderColor: Color {
        switch style {
        case .secondary: return .yoloGold.opacity(0.35)
        default:         return .clear
        }
    }
}

struct YoloIconButton: View {
    let systemName: String
    var tint: Color = .yoloTextSecondary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(Color.yoloSurface2)
                .clipShape(Circle())
        }
        .buttonStyle(PressEffectButtonStyle())
    }
}
