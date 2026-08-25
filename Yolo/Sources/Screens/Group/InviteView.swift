import SwiftUI

struct InviteView: View {
    let group: YoloGroup
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false
    @State private var showQR = false

    private let inviteLink = "yolo.app/join/the-usual-suspects-x7k2"

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: YoloSpacing.lg) {
                        inviteCard
                        linkRow
                        membersSection
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, YoloSpacing.lg)
                }
            }
        }
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.yoloTextSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.yoloSurface2)
                    .clipShape(Circle())
            }
            Spacer()
            Text("invite people")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Color.clear.frame(width: 36)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.md)
    }

    private var inviteCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: YoloRadius.xl, style: .continuous)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: YoloRadius.xl, style: .continuous)
                        .strokeBorder(Color.yoloGold.opacity(0.3), lineWidth: 1)
                )

            VStack(spacing: YoloSpacing.md) {
                Text("yolo.")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(colors: [Color.yoloGoldLight, Color.yoloGold],
                                       startPoint: .leading, endPoint: .trailing)
                    )

                Text(group.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.white)

                StackedAvatars(members: group.members, size: 32)

                Text("\(group.members.count) members · \(group.linkCount) links")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.yoloTextSecondary)

                VStack(spacing: 4) {
                    Text("you're invited to join the group.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.yoloTextSecondary)
                    Text(inviteLink)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.yoloGold.opacity(0.7))
                }
                .padding(.top, 4)
            }
            .padding(YoloSpacing.xl)
        }
        .frame(maxWidth: .infinity)
    }

    private var linkRow: some View {
        VStack(spacing: YoloSpacing.sm) {
            Button {
                UIPasteboard.general.string = inviteLink
                withAnimation(YoloSpring.bouncy) { copied = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(YoloSpring.smooth) { copied = false }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 14, weight: .semibold))
                    Text(copied ? "copied!" : "copy invite link")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(copied ? Color.yoloGreen : Color.black)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(copied ? Color.yoloGreen : Color.yoloGold)
                .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
            }
            .buttonStyle(GoldPressButtonStyle())
            .animation(YoloSpring.smooth, value: copied)

            HStack(spacing: YoloSpacing.sm) {
                shareButton(icon: "message.fill", label: "iMessage", color: Color(hex: "34C759"))
                shareButton(icon: "square.and.arrow.up", label: "more", color: .yoloSurface2)
            }
        }
    }

    private func shareButton(icon: String, label: String, color: Color) -> some View {
        Button {} label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.yoloTextSecondary)
            }
        }
        .buttonStyle(PressEffectButtonStyle())
        .frame(maxWidth: .infinity)
    }

    private var membersSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "already in the group")
            VStack(spacing: 0) {
                ForEach(Array(group.members.enumerated()), id: \.element.id) { idx, member in
                    if idx > 0 { Divider().background(Color.yoloBorder).padding(.leading, 56) }
                    HStack(spacing: YoloSpacing.sm) {
                        AvatarView(member: member, size: 32)
                        Text(member.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.white)
                        Spacer()
                        Text(member.title.rawValue)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.yoloTextTertiary)
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.vertical, 11)
                }
            }
            .yoloCard(padding: 0)
        }
    }
}
