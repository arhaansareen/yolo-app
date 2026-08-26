import SwiftUI

struct AccountabilityDashboardView: View {
    let group: YoloGroup
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTitle: Member.MemberTitle? = nil

    private var sortedMembers: [Member] {
        group.members.sorted { $0.showUpRate > $1.showUpRate }
    }

    private var flakeMembers: [Member] {
        group.members.filter { $0.flakeCount > 0 }.sorted { $0.flakeCount > $1.flakeCount }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: YoloSpacing.lg) {
                        streakCard
                        leaderboardSection
                        if !flakeMembers.isEmpty {
                            flakeSection
                        }
                        titlesSection
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, YoloSpacing.md)
                }
            }
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 36, height: 36)
                    .background(Color.yoloSurface2)
                    .clipShape(Circle())
            }
            Spacer()
            Text("accountability")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Color.clear.frame(width: 36)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.md)
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        VStack(spacing: YoloSpacing.sm) {
            Image(systemName: "flame.fill")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color.yoloGold)
            Text("7")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(Color.white)
            Text("link streak")
                .font(.system(size: 14))
                .foregroundStyle(Color.yoloTextSecondary)
            Text("\(group.name) · active since jan 2024")
                .font(.system(size: 12))
                .foregroundStyle(Color.yoloTextTertiary)
            StreakBadge(count: 7, label: "consecutive plans")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, YoloSpacing.lg)
        .yoloGoldCard()
    }

    // MARK: - Leaderboard

    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "the leaderboard")
            VStack(spacing: 0) {
                ForEach(Array(sortedMembers.enumerated()), id: \.element.id) { idx, member in
                    if idx > 0 {
                        Divider().background(Color.yoloBorder).padding(.leading, 56)
                    }
                    DetailedAccountabilityRow(member: member, rank: idx + 1)
                }
            }
            .yoloCard(padding: 0)
        }
    }

    // MARK: - Flake Hall of Shame

    private var flakeSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.xs) {
            SectionHeader(title: "l board")
            Text("the hall of shame. take the L, do better.")
                .font(.system(size: 12))
                .foregroundStyle(Color.yoloTextTertiary)
                .padding(.bottom, YoloSpacing.xs)
            VStack(spacing: 0) {
                ForEach(Array(flakeMembers.enumerated()), id: \.element.id) { idx, member in
                    if idx > 0 {
                        Divider().background(Color.yoloBorder).padding(.leading, 48)
                    }
                    FlakeRow(member: member)
                }
            }
            .yoloCard(padding: 0)
        }
    }

    // MARK: - Titles History

    private var titlesSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "titles history")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: YoloSpacing.sm) {
                    ForEach(Member.MemberTitle.allCases, id: \.self) { title in
                        let holder = group.members.first { $0.title == title }
                        Button {
                            withAnimation(YoloSpring.snappy) {
                                selectedTitle = selectedTitle == title ? nil : title
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(title.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(selectedTitle == title ? Color.black : Color.white)
                                if let holder {
                                    Text(holder.name)
                                        .font(.system(size: 11))
                                        .foregroundStyle(selectedTitle == title ? Color.black.opacity(0.7) : Color.yoloTextSecondary)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(selectedTitle == title ? Color.yoloGold : Color.yoloSurface2)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(selectedTitle == title ? Color.clear : Color.yoloBorder, lineWidth: 0.5))
                        }
                        .buttonStyle(PressEffectButtonStyle())
                    }
                }
                .padding(.horizontal, YoloSpacing.md)
            }
        }
    }
}

// MARK: - Detailed Accountability Row

private struct DetailedAccountabilityRow: View {
    let member: Member
    let rank: Int

    private var rateColor: Color {
        member.showUpRate > 0.8 ? .yoloGreen : member.showUpRate > 0.5 ? .yoloAmber : .yoloRed
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: YoloSpacing.sm) {
                Text("\(rank)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.yoloTextTertiary)
                    .frame(width: 16)

                AvatarView(member: member, size: 36)

                VStack(alignment: .leading, spacing: 3) {
                    Text(member.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white)
                    Text(member.title.rawValue)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.yoloTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(member.showUpRate.asPercent())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(rateColor)
                    if member.flakeCount > 0 {
                        Text("\(member.flakeCount) flakes")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.yoloTextTertiary)
                    }
                }
            }
            .padding(.horizontal, YoloSpacing.md)
            .padding(.vertical, 12)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.yoloBorder)
                        .frame(height: 3)
                    Rectangle()
                        .fill(rateColor)
                        .frame(width: geo.size.width * member.showUpRate, height: 3)
                }
            }
            .frame(height: 3)
        }
    }
}

// MARK: - Flake Row

private struct FlakeRow: View {
    let member: Member

    var body: some View {
        HStack(spacing: YoloSpacing.sm) {
            AvatarView(member: member, size: 32)
                .opacity(0.7)

            Text(member.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.white)

            Spacer()

            Text("\(member.flakeCount) Ls")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.yoloAmber)

            Text(member.title.rawValue)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.yoloTextSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.yoloSurface2)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(Color.yoloBorder, lineWidth: 0.5))
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.vertical, 12)
    }
}

// MARK: - MemberTitle allCases

extension Member.MemberTitle: CaseIterable {
    static var allCases: [Member.MemberTitle] {
        [.anchor, .wildcard, .ghost, .hypeman, .planner, .surpriseGuest]
    }
}

#Preview {
    AccountabilityDashboardView(group: YoloGroup.mockData[0])
        .environment(AppState())
}
