import SwiftUI

struct AvatarView: View {
    let member: Member
    var size: CGFloat = 36

    var body: some View {
        ZStack {
            Circle().fill(member.avatarColor.opacity(0.15))
            Circle().strokeBorder(member.avatarColor.opacity(0.5), lineWidth: 1)
            Text(String(member.name.prefix(1)).uppercased())
                .font(.system(size: size * 0.36, weight: .bold))
                .foregroundStyle(member.avatarColor)
        }
        .frame(width: size, height: size)
    }
}

struct StackedAvatars: View {
    let members: [Member]
    var size: CGFloat = 30
    var maxVisible: Int = 4

    private var visible: [Member] { Array(members.prefix(maxVisible)) }
    private var overflow: Int    { max(0, members.count - maxVisible) }

    var body: some View {
        HStack(spacing: -(size * 0.28)) {
            ForEach(Array(visible.enumerated()), id: \.element.id) { idx, member in
                AvatarView(member: member, size: size)
                    .overlay(Circle().strokeBorder(Color.black, lineWidth: 2))
                    .zIndex(Double(visible.count - idx))
            }
            if overflow > 0 {
                ZStack {
                    Circle().fill(Color.yoloSurface2)
                    Circle().strokeBorder(Color.black, lineWidth: 2)
                    Text("+\(overflow)")
                        .font(.system(size: size * 0.3, weight: .semibold))
                        .foregroundStyle(Color.yoloTextSecondary)
                }
                .frame(width: size, height: size)
            }
        }
    }
}

struct MemberResponseDot: View {
    let member: Member
    let hasResponded: Bool
    var size: CGFloat = 44

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                AvatarView(member: member, size: size)
                    .opacity(hasResponded ? 1 : 0.35)
                if hasResponded {
                    Circle()
                        .fill(Color.yoloGreen)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .black))
                                .foregroundStyle(.black)
                        )
                        .offset(x: size * 0.3, y: size * 0.3)
                }
            }
            Text(member.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(hasResponded ? Color.white : Color.yoloTextTertiary)
        }
    }
}
