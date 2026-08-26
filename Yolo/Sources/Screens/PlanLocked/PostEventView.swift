import SwiftUI

struct PostEventView: View {
    let group: YoloGroup
    @Environment(\.dismiss) private var dismiss
    @State private var showPhotoAlbum = false
    @State private var selectedRating: Int? = nil
    @State private var showRatingConfirm = false
    @State private var attendance: [UUID: Bool?] = [:]  // true=showed, false=flaked, nil=undecided

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
                    let memberStatus = attendance[member.id] ?? nil
                    HStack(spacing: YoloSpacing.sm) {
                        AvatarView(member: member, size: 32)
                            .opacity(memberStatus == false ? 0.35 : 1.0)
                        Text(member.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(memberStatus == false ? Color.yoloTextTertiary : Color.white)
                        Spacer()
                        HStack(spacing: 6) {
                            Button {
                                withAnimation(YoloSpring.bouncy) {
                                    attendance[member.id] = attendance[member.id] == true ? nil : true
                                }
                            } label: {
                                Text("showed")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(memberStatus == true ? Color.yoloGreen : Color.yoloTextTertiary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(memberStatus == true ? Color.yoloGreen.opacity(0.15) : Color.yoloSurface2)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().strokeBorder(memberStatus == true ? Color.yoloGreen.opacity(0.5) : Color.yoloBorder, lineWidth: 0.5))
                            }
                            .buttonStyle(PressEffectButtonStyle())

                            Button {
                                withAnimation(YoloSpring.bouncy) {
                                    attendance[member.id] = attendance[member.id] == false ? nil : false
                                }
                            } label: {
                                Text("flaked")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(memberStatus == false ? Color.yoloRed : Color.yoloTextTertiary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(memberStatus == false ? Color.yoloRed.opacity(0.15) : Color.yoloSurface2)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().strokeBorder(memberStatus == false ? Color.yoloRed.opacity(0.5) : Color.yoloBorder, lineWidth: 0.5))
                            }
                            .buttonStyle(PressEffectButtonStyle())
                        }
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.vertical, 11)
                }
            }
            .yoloCard(padding: 0)
        }
    }

    private var nextPlanCTA: some View {
        YoloButton(title: "save recap", style: .primary) {
            dismiss()
        }
    }
}

#Preview {
    PostEventView(group: YoloGroup.mockData[0])
}
