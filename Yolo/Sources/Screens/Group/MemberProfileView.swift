import SwiftUI

struct MemberProfileView: View {
    let member: Member
    let groupName: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                ScrollView(showsIndicators: false) {
                    VStack(spacing: YoloSpacing.lg) {
                        heroSection
                        statsGrid
                        reputationSection
                        historySection
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, YoloSpacing.md)
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
            Text(member.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Color.clear.frame(width: 36)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.md)
    }

    private var heroSection: some View {
        VStack(spacing: YoloSpacing.sm) {
            ZStack {
                Circle()
                    .fill(member.avatarColor.opacity(0.15))
                    .frame(width: 96, height: 96)
                Text(String(member.name.prefix(1)).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(member.avatarColor)
            }

            Text(member.name)
                .font(.system(size: 26, weight: .black))
                .foregroundStyle(Color.white)

            HStack(spacing: 6) {
                Circle()
                    .fill(titleColor)
                    .frame(width: 6, height: 6)
                Text(member.title.rawValue)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.yoloTextSecondary)
            }

            Text("in \(groupName)")
                .font(.system(size: 12))
                .foregroundStyle(Color.yoloTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, YoloSpacing.lg)
        .yoloCard()
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: YoloSpacing.sm) {
            MemberStatTile(
                value: member.showUpRate.asPercent(),
                label: "show-up rate",
                icon: "checkmark.circle.fill",
                tint: showUpColor
            )
            MemberStatTile(
                value: "\(member.flakeCount)",
                label: "total flakes",
                icon: "xmark.circle.fill",
                tint: member.flakeCount == 0 ? .yoloGreen : member.flakeCount < 3 ? .yoloAmber : .yoloRed
            )
            MemberStatTile(
                value: "14",
                label: "plans joined",
                icon: "calendar.badge.checkmark",
                tint: .yoloGold
            )
            MemberStatTile(
                value: "3",
                label: "plans started",
                icon: "bolt.fill",
                tint: .yoloAmber
            )
        }
    }

    private var reputationSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "reputation")
            VStack(spacing: YoloSpacing.sm) {
                ReputationBar(label: "reliability", value: member.showUpRate, color: showUpColor)
                ReputationBar(label: "energy", value: 0.75, color: .yoloAmber)
                ReputationBar(label: "planning", value: member.title == .planner ? 0.95 : 0.4, color: .yoloGold)
            }
            .padding(YoloSpacing.md)
            .yoloCard()
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "recent plans")
            VStack(spacing: 0) {
                ForEach(mockHistory, id: \.0) { item in
                    HStack(spacing: YoloSpacing.sm) {
                        Image(systemName: item.2 ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(item.2 ? Color.yoloGreen : Color.yoloRed)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.0)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.white)
                            Text(item.1)
                                .font(.system(size: 11))
                                .foregroundStyle(Color.yoloTextTertiary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.vertical, 12)
                    if item.0 != mockHistory.last?.0 {
                        Divider().background(Color.yoloBorder).padding(.leading, 48)
                    }
                }
            }
            .yoloCard(padding: 0)
        }
    }

    private var showUpColor: Color {
        member.showUpRate > 0.8 ? .yoloGreen : member.showUpRate > 0.5 ? .yoloAmber : .yoloRed
    }

    private var titleColor: Color {
        switch member.title {
        case .anchor, .hypeman: return .yoloGreen
        case .wildcard, .surpriseGuest: return .yoloAmber
        case .ghost: return .yoloRed
        case .planner: return .yoloGold
        }
    }

    private var mockHistory: [(String, String, Bool)] {
        [
            ("dinner at nobu", "last saturday", true),
            ("bowling night", "2 weeks ago", member.flakeCount > 2 ? false : true),
            ("cottage weekend", "last month", true),
            ("rooftop drinks", "6 weeks ago", member.flakeCount > 1 ? false : true),
        ]
    }
}

private struct MemberStatTile: View {
    let value: String
    let label: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.yoloTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(YoloSpacing.md)
        .yoloCard()
    }
}

private struct ReputationBar: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.yoloTextSecondary)
                Spacer()
                Text(value.asPercent())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.yoloBorder)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geo.size.width * value)
                }
            }
            .frame(height: 5)
        }
    }
}

#Preview {
    MemberProfileView(member: Member.mockMembers[0], groupName: "the usual suspects")
}
