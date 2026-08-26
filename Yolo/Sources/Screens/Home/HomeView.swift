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

// MARK: - Activity Tab

struct ActivityTabView: View {
    @Environment(AppState.self) private var appState

    private struct ActivityItem: Identifiable {
        let id = UUID()
        let icon: String
        let iconColor: Color
        let title: String
        let subtitle: String
        let time: String
        let isUnread: Bool
    }

    private let items: [ActivityItem] = [
        ActivityItem(icon: "lock.fill",             iconColor: .yoloGold,  title: "the usual suspects locked in", subtitle: "dinner + bowling · saturday 7pm",     time: "just now", isUnread: true),
        ActivityItem(icon: "person.fill.checkmark", iconColor: .yoloGreen, title: "jade voted yes",               subtitle: "sunset patio drinks poll",             time: "2m ago",   isUnread: true),
        ActivityItem(icon: "flame.fill",            iconColor: .yoloGold,  title: "7-link streak!",               subtitle: "the usual suspects · keep it going",   time: "1h ago",   isUnread: false),
        ActivityItem(icon: "bell.fill",             iconColor: .yoloAmber, title: "ko hasn't responded",          subtitle: "the poll closes in 3 hours",           time: "3h ago",   isUnread: false),
        ActivityItem(icon: "checkmark.circle.fill", iconColor: .yoloGreen, title: "plan confirmed",               subtitle: "bowling at splitsville · last friday", time: "2d ago",   isUnread: false),
        ActivityItem(icon: "xmark.circle.fill",     iconColor: .yoloRed,   title: "priya flaked",                 subtitle: "cottage weekend · updated her score",  time: "5d ago",   isUnread: false),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("activity")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text("what's happening with your crew")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.yoloTextSecondary)
                }
                .padding(.horizontal, YoloSpacing.md)
                .padding(.top, 64)
                .padding(.bottom, YoloSpacing.lg)

                if items.isEmpty {
                    EmptyStateView(
                        icon: "bell.slash",
                        title: "all caught up",
                        subtitle: "activity from your groups will show here"
                    )
                    .padding(.top, YoloSpacing.xxl)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                            if idx > 0 {
                                Divider()
                                    .background(Color.yoloBorder)
                                    .padding(.leading, YoloSpacing.md + 6 + YoloSpacing.sm + 40 + YoloSpacing.sm)
                            }
                            activityRow(item)
                        }
                    }
                }

                Color.clear.frame(height: 110)
            }
        }
        .background(Color.black)
    }

    private func activityRow(_ item: ActivityItem) -> some View {
        HStack(alignment: .top, spacing: YoloSpacing.sm) {
            Circle()
                .fill(item.isUnread ? Color.yoloGold : Color.clear)
                .frame(width: 6, height: 6)
                .padding(.top, 17)

            ZStack {
                Circle()
                    .fill(item.iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: item.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(item.iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white)
                Text(item.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.yoloTextSecondary)
                    .lineLimit(1)
                Text(item.time)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.yoloTextTertiary)
            }
            .padding(.top, 2)

            Spacer()
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.vertical, 12)
    }
}

struct ProfileTabView: View {
    @Environment(AppState.self) private var appState
    @State private var freeSlots: Set<String> = []
    @State private var showSettings = false

    private let days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    private let slots = ["morning", "afternoon", "evening"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: YoloSpacing.lg) {

                // Avatar header
                VStack(spacing: YoloSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(appState.currentUser.avatarColor)
                            .frame(width: 52, height: 52)
                        Text(appState.currentUser.name.prefix(1).uppercased())
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    Text(appState.currentUser.name)
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
                            Button { showSettings = true } label: {
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
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PressEffectButtonStyle())

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
        .sheet(isPresented: $showSettings) { SettingsView() }
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
