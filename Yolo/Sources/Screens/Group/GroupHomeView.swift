import SwiftUI

struct GroupHomeView: View {
    let group: YoloGroup
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showPlanning = false
    @State private var showAvailability = false
    @State private var showInvite = false
    @State private var showMapTriangulation = false
    @State private var showBigTrip = false
    @State private var showAccountabilityDashboard = false

    private var accentColor: Color { group.members.first?.avatarColor ?? .yoloGold }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    VStack(spacing: YoloSpacing.md) {
                        statsRow
                        planCTA
                        findSpotRow
                        availabilityRow
                        bigTripRow
                        accountabilitySection
                        recentSection
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, YoloSpacing.lg)
                    Color.clear.frame(height: 40)
                }
            }
        }
        .hideNavigationBar()
        .fullScreenCover(isPresented: $showPlanning) {
            KickOffView(group: group)
        }
        .sheet(isPresented: $showAvailability) {
            AvailabilityView(group: group)
        }
        .sheet(isPresented: $showInvite) {
            InviteView(group: group)
        }
        .sheet(isPresented: $showMapTriangulation) {
            MapTriangulationView(group: group, onConfirm: { showMapTriangulation = false })
        }
        .sheet(isPresented: $showBigTrip) {
            BigTripView(group: group)
        }
        .sheet(isPresented: $showAccountabilityDashboard) {
            AccountabilityDashboardView(group: group)
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [accentColor.opacity(0.25), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 260)
            .ignoresSafeArea(edges: .top)

            VStack(spacing: YoloSpacing.sm) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .frame(width: 38, height: 38)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    Spacer()
                    StatusPill(status: group.status)
                    Spacer()
                    YoloIconButton(systemName: "person.badge.plus") { showInvite = true }
                }
                .padding(.horizontal, YoloSpacing.md)
                .padding(.top, 56)

                VStack(spacing: 8) {
                    Text(group.name)
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                    StackedAvatars(members: group.members, size: 32)
                }
                .padding(.bottom, YoloSpacing.lg)
            }
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: YoloSpacing.sm) {
            StatBlock(value: "\(group.linkCount)", label: "links", icon: "link", tint: .yoloGold)
            StatBlock(value: "\(group.members.count)", label: "members", icon: "person.2.fill", tint: accentColor)
            StatBlock(
                value: {
                    let avg = group.members.map(\.showUpRate).reduce(0,+) / Double(max(group.members.count,1))
                    return avg.asPercent()
                }(),
                label: "show-up",
                icon: "checkmark.seal.fill",
                tint: .yoloGreen
            )
        }
    }

    // MARK: - Plan CTA

    private var planCTA: some View {
        Button { showPlanning = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 15, weight: .bold))
                Text("start a plan")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(colors: [Color.yoloGoldLight, Color.yoloGold], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
            .shadow(color: Color.yoloGold.opacity(0.25), radius: 12, y: 4)
        }
        .buttonStyle(GoldPressButtonStyle())
    }

    private var findSpotRow: some View {
        Button { showMapTriangulation = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "map.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.yoloGold)
                Text("find the fairest spot")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.white)
                Spacer()
                Text("new")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.yoloGold)
                    .clipShape(Capsule())
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextTertiary)
            }
            .padding(.horizontal, YoloSpacing.md)
            .frame(height: 48)
            .background(Color.yoloSurface)
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous).strokeBorder(Color.yoloBorder, lineWidth: 0.5))
        }
        .buttonStyle(PressEffectButtonStyle())
    }

    private var availabilityRow: some View {
        Button { showAvailability = true } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.yoloGold)
                    .frame(width: 6, height: 6)
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.yoloGold)
                Text("who's free this weekend?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextTertiary)
            }
            .padding(.horizontal, YoloSpacing.md)
            .frame(height: 48)
            .background(Color.yoloSurface)
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                    .strokeBorder(Color.yoloBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(PressEffectButtonStyle())
    }

    private var bigTripRow: some View {
        Button { showBigTrip = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "suitcase.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.yoloGold)
                Text("big trip mode")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextTertiary)
            }
            .padding(.horizontal, YoloSpacing.md)
            .frame(height: 48)
            .background(Color.yoloSurface)
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                    .strokeBorder(Color.yoloBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(PressEffectButtonStyle())
    }

    // MARK: - Accountability

    @State private var selectedMember: Member? = nil

    private var accountabilitySection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "accountability", action: "see all") {
                showAccountabilityDashboard = true
            }

            VStack(spacing: 0) {
                ForEach(Array(group.members.sorted { $0.showUpRate > $1.showUpRate }.enumerated()), id: \.element.id) { idx, member in
                    if idx > 0 { Divider().background(Color.yoloBorder).padding(.leading, 56) }
                    Button { selectedMember = member } label: {
                        AccountabilityRow(member: member, rank: idx + 1)
                    }
                    .buttonStyle(PressEffectButtonStyle())
                }
            }
            .yoloCard(padding: 0)
            .sheet(item: $selectedMember) { member in
                MemberProfileView(member: member, groupName: group.name)
            }
        }
    }

    // MARK: - Recent

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "recent")

            VStack(spacing: 0) {
                RecentRow(icon: "bolt.fill", iconColor: .yoloAmber,
                          text: "\(group.members.first?.name ?? "someone") started a plan", time: "now")
                Divider().background(Color.yoloBorder).padding(.leading, 52)
                RecentRow(icon: "checkmark.circle.fill", iconColor: .yoloGreen,
                          text: "3/\(group.members.count) confirmed the last plan", time: "2d")
                Divider().background(Color.yoloBorder).padding(.leading, 52)
                RecentRow(icon: "link", iconColor: .yoloGold,
                          text: "\(group.linkCount) total links as a crew", time: "")
            }
            .yoloCard(padding: 0)
        }
    }
}

// MARK: - Sub-components

private struct StatBlock: View {
    let value: String
    let label: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.yoloTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .yoloCard()
    }
}

private struct AccountabilityRow: View {
    let member: Member
    let rank: Int

    private var rateColor: Color {
        member.showUpRate > 0.8 ? .yoloGreen : member.showUpRate > 0.5 ? .yoloAmber : .yoloRed
    }

    var body: some View {
        HStack(spacing: YoloSpacing.sm) {
            Text("\(rank)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.yoloTextTertiary)
                .frame(width: 16)

            AvatarView(member: member, size: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white)
                Text(member.title.rawValue)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.yoloTextSecondary)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.yoloBorder)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(rateColor)
                            .frame(width: geo.size.width * member.showUpRate)
                    }
                }
                .frame(height: 3)
                .frame(maxWidth: 120)
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
    }
}

private struct RecentRow: View {
    let icon: String
    let iconColor: Color
    let text: String
    let time: String

    var body: some View {
        HStack(spacing: YoloSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Color.white)
                .lineLimit(2)

            Spacer()

            if !time.isEmpty {
                Text(time)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.yoloTextTertiary)
            }
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.vertical, 12)
    }
}

#Preview {
    GroupHomeView(group: YoloGroup.mockData[0])
        .environment(AppState())
}
