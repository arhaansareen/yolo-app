import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showCreateGroup = false
    @State private var selectedGroup: YoloGroup?
    @State private var selectedTab: Tab = .home

    enum Tab { case home, activity, profile }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()

                TabContent(selectedTab: selectedTab, selectedGroup: $selectedGroup, showCreateGroup: $showCreateGroup)

                YoloTabBar(selected: $selectedTab)
            }
            .navigationDestination(item: $selectedGroup) { group in
                GroupHomeView(group: group)
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupView()
            }
        }
        .tint(.yoloGold)
    }
}

private struct TabContent: View {
    let selectedTab: HomeView.Tab
    @Binding var selectedGroup: YoloGroup?
    @Binding var showCreateGroup: Bool

    var body: some View {
        switch selectedTab {
        case .home:     GroupsFeedView(selectedGroup: $selectedGroup, showCreateGroup: $showCreateGroup)
        case .activity: ActivityTabView()
        case .profile:  ProfileTabView()
        }
    }
}

// MARK: - Groups Feed

struct GroupsFeedView: View {
    @Environment(AppState.self) private var appState
    @Binding var selectedGroup: YoloGroup?
    @Binding var showCreateGroup: Bool
    @State private var appeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                feedHeader
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, 60)
                    .padding(.bottom, YoloSpacing.lg)

                if let nudge = appState.groups.first(where: { $0.status == .idle && $0.linkCount > 3 }) {
                    nudgeBanner(nudge)
                        .padding(.horizontal, YoloSpacing.md)
                        .padding(.bottom, YoloSpacing.md)
                }

                VStack(alignment: .leading, spacing: YoloSpacing.xs) {
                    SectionHeader(title: "your groups")
                        .padding(.horizontal, YoloSpacing.md)
                        .padding(.bottom, YoloSpacing.sm)

                    ForEach(Array(appState.groups.enumerated()), id: \.element.id) { idx, group in
                        GroupCard(group: group)
                            .padding(.horizontal, YoloSpacing.md)
                            .onTapGesture { selectedGroup = group }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(YoloSpring.smooth.delay(Double(idx) * 0.055), value: appeared)
                    }
                }

                Color.clear.frame(height: 110)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            newGroupFAB
                .padding(.trailing, YoloSpacing.md)
                .padding(.bottom, 90)
        }
        .onAppear { withAnimation { appeared = true } }
    }

    private var feedHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("yolo.")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(Color.yoloGold)
                Text("make the plan real.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.yoloTextSecondary)
            }
            Spacer()
            Button {} label: {
                AvatarView(member: appState.currentUser, size: 38)
            }
        }
    }

    private func nudgeBanner(_ group: YoloGroup) -> some View {
        HStack(spacing: YoloSpacing.sm) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.yoloGold)
                .frame(width: 40, height: 40)
                .background(Color.yoloGold.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("time to link up")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white)
                Text("\(group.name) hasn't hung out in a while")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.yoloTextTertiary)
        }
        .yoloCard()
    }

    private var newGroupFAB: some View {
        Button { showCreateGroup = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 54, height: 54)
                .background(Color.yoloGold)
                .clipShape(Circle())
                .shadow(color: Color.yoloGold.opacity(0.35), radius: 14, y: 5)
        }
        .buttonStyle(GoldPressButtonStyle())
    }
}

// MARK: - Group Card

struct GroupCard: View {
    let group: YoloGroup

    private var accentColor: Color { group.members.first?.avatarColor ?? .yoloGold }

    var body: some View {
        VStack(spacing: 0) {
            colorBand
            cardBody
        }
        .background(Color.yoloSurface)
        .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                .strokeBorder(Color.yoloBorder, lineWidth: 0.5)
        )
        .padding(.bottom, YoloSpacing.xs)
        .buttonStyle(PressEffectButtonStyle())
    }

    private var colorBand: some View {
        LinearGradient(
            colors: [accentColor.opacity(0.5), accentColor.opacity(0.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 3)
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.white)
                    Text(group.lastActivityText)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.yoloTextSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 12)
                StatusPill(status: group.status)
            }

            HStack {
                StackedAvatars(members: group.members, size: 26)
                Spacer()
                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.yoloTextTertiary)
                        Text("\(group.members.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.yoloTextSecondary)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.yoloGold)
                        Text("\(group.linkCount)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.yoloGold)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Placeholder tabs

struct ActivityTabView: View {
    var body: some View {
        VStack(spacing: YoloSpacing.sm) {
            Spacer()
            Image(systemName: "bell.slash")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(Color.yoloTextTertiary)
            Text("no activity yet")
                .font(.system(size: 15))
                .foregroundStyle(Color.yoloTextSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct ProfileTabView: View {
    @Environment(AppState.self) private var appState
    @State private var freeSlots: Set<String> = []

    private let days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    private let slots = ["morning", "afternoon", "evening"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: YoloSpacing.lg) {

                // Avatar header
                VStack(spacing: YoloSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(Color.yoloGold)
                            .frame(width: 52, height: 52)
                        Text("A")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    Text("arh")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text("the anchor")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.yoloGold)
                }
                .padding(.top, 72)

                // 3 stat cards
                HStack(spacing: YoloSpacing.sm) {
                    StatTile(value: "14", label: "links")
                    StatTile(value: "92%", label: "show-up")
                    StatTile(value: "3", label: "groups")
                }
                .padding(.horizontal, YoloSpacing.md)

                // 7x3 availability heatmap
                VStack(alignment: .leading, spacing: YoloSpacing.sm) {
                    SectionHeader(title: "availability")

                    VStack(spacing: 6) {
                        // day headers
                        HStack(spacing: 4) {
                            Color.clear.frame(width: 72)
                            ForEach(days, id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.yoloTextTertiary)
                                    .frame(maxWidth: .infinity)
                            }
                        }

                        // rows per time slot
                        ForEach(slots, id: \.self) { slot in
                            HStack(spacing: 4) {
                                Text(slot)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.yoloTextSecondary)
                                    .frame(width: 72, alignment: .leading)
                                ForEach(days, id: \.self) { day in
                                    let key = "\(day)-\(slot)"
                                    let isFree = freeSlots.contains(key)
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(isFree ? Color.yoloGold : Color.yoloSurface2)
                                        .frame(height: 28)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                .strokeBorder(isFree ? Color.yoloGold.opacity(0.4) : Color.yoloBorder, lineWidth: 0.5)
                                        )
                                        .onTapGesture {
                                            withAnimation(YoloSpring.snappy) {
                                                if freeSlots.contains(key) {
                                                    freeSlots.remove(key)
                                                } else {
                                                    freeSlots.insert(key)
                                                }
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .padding(YoloSpacing.md)
                    .background(Color.yoloSurface)
                    .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                            .strokeBorder(Color.yoloBorder, lineWidth: 0.5)
                    )
                }
                .padding(.horizontal, YoloSpacing.md)

                // Settings rows
                VStack(spacing: 0) {
                    ForEach(["notifications", "privacy", "connected accounts"], id: \.self) { row in
                        VStack(spacing: 0) {
                            HStack {
                                Text(row)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.yoloTextTertiary)
                            }
                            .padding(.horizontal, YoloSpacing.md)
                            .padding(.vertical, 14)

                            if row != "connected accounts" {
                                Divider()
                                    .background(Color.yoloBorder)
                                    .padding(.leading, YoloSpacing.md)
                            }
                        }
                    }
                }
                .background(Color.yoloSurface)
                .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                        .strokeBorder(Color.yoloBorder, lineWidth: 0.5)
                )
                .padding(.horizontal, YoloSpacing.md)

                Color.clear.frame(height: 100)
            }
        }
        .background(Color.black)
    }
}

private struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.yoloTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, YoloSpacing.md)
        .yoloCard()
    }
}

// MARK: - Tab Bar

struct YoloTabBar: View {
    @Binding var selected: HomeView.Tab

    var body: some View {
        HStack(spacing: 0) {
            tabItem(icon: "house.fill",       label: "home",     tab: .home)
            tabItem(icon: "bell.fill",         label: "activity", tab: .activity)
            tabItem(icon: "person.fill",       label: "profile",  tab: .profile)
        }
        .padding(.horizontal, YoloSpacing.xl)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Color.yoloSurface
                .overlay(
                    Rectangle()
                        .fill(Color.yoloBorder)
                        .frame(height: 0.5),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabItem(icon: String, label: String, tab: HomeView.Tab) -> some View {
        let isActive = selected == tab
        return Button {
            withAnimation(YoloSpring.snappy) { selected = tab }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isActive ? .bold : .regular))
                    .foregroundStyle(isActive ? Color.yoloGold : Color.yoloTextTertiary)
                Text(label)
                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? Color.yoloGold : Color.yoloTextTertiary)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressEffectButtonStyle())
    }
}

#Preview {
    HomeView()
        .environment(AppState())
}
