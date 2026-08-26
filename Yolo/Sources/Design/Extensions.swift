import SwiftUI

extension Double {
    func asPercent() -> String { "\(Int(self * 100))%" }
}

struct PressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.82 : 1.0)
            .animation(YoloSpring.snappy, value: configuration.isPressed)
    }
}

struct GoldPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? -0.06 : 0)
            .animation(YoloSpring.snappy, value: configuration.isPressed)
    }
}

struct SectionHeader: View {
    let title: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.yoloTextTertiary)
                .tracking(1.2)
            Spacer()
            if let action, let onAction {
                Button(action: onAction) {
                    Text(action)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.yoloGold)
                }
            }
        }
    }
}

// MARK: - Map card style (for meetup result tray)

struct YoloMapCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.yoloSurface)
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.xl, style: .continuous))
            .shadow(color: Color.black.opacity(0.5), radius: 20, y: -4)
    }
}

extension View {
    func yoloMapCard() -> some View { modifier(YoloMapCardModifier()) }
}

// MARK: - Reusable components

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: YoloSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color.yoloTextTertiary)
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.yoloTextSecondary)
                    .multilineTextAlignment(.center)
            }
            if let action, let onAction {
                Button(action: onAction) {
                    Text(action)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.yoloGold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.yoloGold.opacity(0.1))
                        .clipShape(Capsule())
                }
                .buttonStyle(PressEffectButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, YoloSpacing.xl)
    }
}

struct StreakBadge: View {
    let count: Int
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.yoloGold)
            Text("\(count) streak")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Color.yoloTextSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.yoloGold.opacity(0.08))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.yoloGold.opacity(0.2), lineWidth: 1))
    }
}

struct PermissionPromptCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionLabel: String
    let onAction: () -> Void
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: YoloSpacing.md) {
            HStack(spacing: YoloSpacing.md) {
                ZStack {
                    Circle().fill(Color.yoloGold.opacity(0.12)).frame(width: 44, height: 44)
                    Image(systemName: icon).font(.system(size: 18)).foregroundStyle(Color.yoloGold)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.white)
                    Text(subtitle).font(.system(size: 12)).foregroundStyle(Color.yoloTextSecondary)
                }
                Spacer()
            }
            HStack(spacing: YoloSpacing.sm) {
                if let onDismiss {
                    Button("later") { onDismiss() }
                        .font(.system(size: 14))
                        .foregroundStyle(Color.yoloTextTertiary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.yoloSurface2)
                        .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md))
                }
                Button(action: onAction) {
                    Text(actionLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.yoloGold)
                        .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md))
                }
                .buttonStyle(GoldPressButtonStyle())
            }
        }
        .padding(YoloSpacing.md)
        .yoloCard()
    }
}
