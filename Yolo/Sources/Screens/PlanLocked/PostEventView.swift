import SwiftUI

struct PostEventView: View {
    let group: YoloGroup
    @Environment(\.dismiss) private var dismiss
    @State private var showPhotoAlbum = false
    @State private var selectedRating: Int? = nil
    @State private var showRatingConfirm = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                ScrollView(showsIndicators: false) {
                    VStack(spacing: YoloSpacing.lg) {
                        memoryCard
                        ratingSection
                        photoTeaser
                        whoShowedUp
                        nextPlanCTA
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, YoloSpacing.md)
                }
            }
        }
        .sheet(isPresented: $showPhotoAlbum) {
            PhotoAlbumView(group: group)
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
            Text("that happened")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Color.clear.frame(width: 36)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.md)
    }

    private var memoryCard: some View {
        VStack(spacing: YoloSpacing.md) {
            Image(systemName: "star.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.yoloGold)

            Text("link #\(group.linkCount) complete")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.yoloGold)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color.yoloGold.opacity(0.1))
                .clipShape(Capsule())

            Text(group.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.center)

            Text("dinner at nobu")
                .font(.system(size: 16))
                .foregroundStyle(Color.yoloTextSecondary)

            StackedAvatars(members: group.members.filter { $0.showUpRate > 0.5 }, size: 32)

            Text("\(group.members.filter { $0.showUpRate > 0.5 }.count)/\(group.members.count) showed up")
                .font(.system(size: 13))
                .foregroundStyle(Color.yoloTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, YoloSpacing.xl)
        .background(
            ZStack {
                Color.yoloSurface
                LinearGradient(
                    colors: [Color.yoloGold.opacity(0.08), Color.clear],
                    startPoint: .top, endPoint: .bottom
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: YoloRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: YoloRadius.xl, style: .continuous)
                .strokeBorder(Color.yoloGold.opacity(0.2), lineWidth: 1)
        )
    }

    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "how was it?")
            HStack(spacing: YoloSpacing.sm) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(YoloSpring.bouncy) { selectedRating = star }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(YoloSpring.smooth) { showRatingConfirm = true }
                        }
                    } label: {
                        Image(systemName: star <= (selectedRating ?? 0) ? "star.fill" : "star")
                            .font(.system(size: 28))
                            .foregroundStyle(star <= (selectedRating ?? 0) ? Color.yoloGold : Color.yoloBorder)
                            .scaleEffect(star <= (selectedRating ?? 0) ? 1.1 : 1.0)
                    }
                    .buttonStyle(PressEffectButtonStyle())
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(YoloSpacing.md)
            .yoloCard()

            if showRatingConfirm {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.yoloGreen)
                    Text("logged. the crew can see this.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.yoloTextSecondary)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var photoTeaser: some View {
        Button { showPhotoAlbum = true } label: {
            HStack(spacing: YoloSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.yoloGold.opacity(0.1))
                        .frame(width: 52, height: 52)
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.yoloGold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("add photos")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white)
                    Text("keep the memory alive")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.yoloTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextTertiary)
            }
            .padding(YoloSpacing.md)
            .yoloCard()
        }
        .buttonStyle(PressEffectButtonStyle())
    }

    private var whoShowedUp: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "roll call")
            VStack(spacing: 0) {
                ForEach(Array(group.members.enumerated()), id: \.element.id) { idx, member in
                    if idx > 0 { Divider().background(Color.yoloBorder).padding(.leading, 56) }
                    let showed = member.showUpRate > 0.5
                    HStack(spacing: YoloSpacing.sm) {
                        AvatarView(member: member, size: 32)
                            .opacity(showed ? 1.0 : 0.35)
                        Text(member.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(showed ? Color.white : Color.yoloTextTertiary)
                        Spacer()
                        Image(systemName: showed ? "checkmark.circle.fill" : "xmark.circle")
                            .font(.system(size: 16))
                            .foregroundStyle(showed ? Color.yoloGreen : Color.yoloRed.opacity(0.5))
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.vertical, 11)
                }
            }
            .yoloCard(padding: 0)
        }
    }

    private var nextPlanCTA: some View {
        VStack(spacing: YoloSpacing.sm) {
            Text("don't let the streak die")
                .font(.system(size: 13))
                .foregroundStyle(Color.yoloTextSecondary)

            Button { dismiss() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                    Text("plan the next one")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(colors: [Color.yoloGoldLight, Color.yoloGold],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
                .shadow(color: Color.yoloGold.opacity(0.25), radius: 12, y: 4)
            }
            .buttonStyle(GoldPressButtonStyle())
        }
    }
}

#Preview {
    PostEventView(group: YoloGroup.mockData[0])
}
