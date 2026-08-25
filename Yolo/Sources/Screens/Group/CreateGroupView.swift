import SwiftUI

struct CreateGroupView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var groupName = ""
    @State private var selectedVibe: YoloGroup.GroupVibe = .chaotic
    @State private var step = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
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
                    Text("new group")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, YoloSpacing.lg)
                .padding(.top, YoloSpacing.lg)

                ScrollView {
                    VStack(alignment: .leading, spacing: YoloSpacing.xl) {
                        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
                            Text("what do you\ncall yourselves?")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(Color.white)
                            YoloTextField(placeholder: "the usual suspects...", text: $groupName)
                        }

                        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
                            Text("what's the vibe?")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.white)
                            Text("helps the ai suggest the right stuff")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.yoloTextSecondary)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: YoloSpacing.sm) {
                                ForEach(YoloGroup.GroupVibe.allCases, id: \.self) { vibe in
                                    VibeButton(vibe: vibe, isSelected: selectedVibe == vibe) {
                                        withAnimation(YoloSpring.bouncy) { selectedVibe = vibe }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
                            HStack {
                                Text("add your crew")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color.white)
                                Spacer()
                                Text("optional")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.yoloTextTertiary)
                            }

                            ShareLinkCard()
                        }
                    }
                    .padding(.horizontal, YoloSpacing.lg)
                    .padding(.top, YoloSpacing.xl)
                    .padding(.bottom, 120)
                }

                VStack(spacing: YoloSpacing.sm) {
                    YoloButton(title: "create group →", style: groupName.count >= 2 ? .primary : .ghost) {
                        let newGroup = YoloGroup(
                            id: UUID(),
                            name: groupName.lowercased(),
                            members: [appState.currentUser],
                            status: .idle,
                            lastActivityText: "just created",
                            linkCount: 0,
                            currentPlan: nil,
                            vibe: selectedVibe
                        )
                        appState.addGroup(newGroup)
                        dismiss()
                    }
                    .disabled(groupName.count < 2)
                }
                .padding(.horizontal, YoloSpacing.lg)
                .padding(.bottom, 36)
            }
        }
    }
}

private struct VibeButton: View {
    let vibe: YoloGroup.GroupVibe
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(vibe.rawValue)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.black : Color.white)
                .multilineTextAlignment(.center)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.yoloGold : Color.yoloSurface)
                .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous)
                        .strokeBorder(isSelected ? Color.clear : Color.yoloBorder, lineWidth: 0.5)
                )
        }
        .buttonStyle(PressEffectButtonStyle())
    }
}

private struct ShareLinkCard: View {
    var body: some View {
        HStack(spacing: YoloSpacing.sm) {
            Image(systemName: "link")
                .font(.system(size: 16))
                .foregroundStyle(Color.yoloGold)
                .frame(width: 40, height: 40)
                .background(Color.yoloGold.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("invite link")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white)
                Text("share after creating the group")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextSecondary)
            }

            Spacer()

            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 14))
                .foregroundStyle(Color.yoloTextTertiary)
        }
        .yoloCard()
    }
}
