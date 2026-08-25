import SwiftUI

struct PhotoAlbumView: View {
    let group: YoloGroup
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    private let columns = [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                tabPicker
                ScrollView(showsIndicators: false) {
                    if selectedTab == 0 {
                        photoGrid
                    } else {
                        memoriesSection
                    }
                    Color.clear.frame(height: 40)
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
            VStack(spacing: 2) {
                Text(group.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white)
                Text("\(group.linkCount) links")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.yoloTextTertiary)
            }
            Spacer()
            Button {} label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.yoloTextSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.yoloSurface2)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.md)
    }

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(["photos", "memories"], id: \.self) { tab in
                let idx = tab == "photos" ? 0 : 1
                Button { withAnimation(YoloSpring.smooth) { selectedTab = idx } } label: {
                    VStack(spacing: 8) {
                        Text(tab)
                            .font(.system(size: 14, weight: selectedTab == idx ? .semibold : .regular))
                            .foregroundStyle(selectedTab == idx ? Color.white : Color.yoloTextTertiary)
                        Rectangle()
                            .fill(selectedTab == idx ? Color.yoloGold : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, YoloSpacing.md)
        .overlay(alignment: .bottom) {
            Divider().background(Color.yoloBorder)
        }
    }

    private var photoGrid: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            emptyPhotoState
                .padding(.horizontal, YoloSpacing.md)
                .padding(.top, YoloSpacing.lg)
        }
    }

    private var emptyPhotoState: some View {
        VStack(spacing: YoloSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.yoloSurface2)
                    .frame(width: 80, height: 80)
                Image(systemName: "camera")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.yoloTextTertiary)
            }
            .padding(.top, 60)

            Text("no photos yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white)
            Text("be the first to add one from this plan.")
                .font(.system(size: 14))
                .foregroundStyle(Color.yoloTextSecondary)
                .multilineTextAlignment(.center)

            Button {} label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("add photos")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color.black)
                .frame(height: 48)
                .padding(.horizontal, 24)
                .background(Color.yoloGold)
                .clipShape(Capsule())
            }
            .buttonStyle(GoldPressButtonStyle())
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }

    private var memoriesSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.lg) {
            ForEach(Array(mockMemories.enumerated()), id: \.offset) { _, memory in
                MemoryCard(memory: memory, members: group.members)
            }
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, YoloSpacing.md)
    }

    private var mockMemories: [(String, String, String)] {
        [
            ("dinner at nobu", "last saturday", "3/\(group.members.count) showed"),
            ("cottage weekend", "last month", "\(group.members.count)/\(group.members.count) showed"),
            ("bowling night", "6 weeks ago", "4/\(group.members.count) showed"),
        ]
    }
}

private struct MemoryCard: View {
    let memory: (String, String, String)
    let members: [Member]

    var body: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.0)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                    Text(memory.1)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.yoloTextTertiary)
                }
                Spacer()
                Text(memory.2)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.yoloGold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.yoloGold.opacity(0.1))
                    .clipShape(Capsule())
            }

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.yoloSurface2)
                .frame(height: 140)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.yoloTextTertiary)
                        Text("no photos")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.yoloTextTertiary)
                    }
                )

            StackedAvatars(members: Array(members.prefix(3)), size: 24)
        }
        .padding(YoloSpacing.md)
        .yoloCard()
    }
}

#Preview {
    PhotoAlbumView(group: YoloGroup.mockData[0])
}
