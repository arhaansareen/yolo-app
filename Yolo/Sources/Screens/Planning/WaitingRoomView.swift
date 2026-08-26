import SwiftUI

struct WaitingRoomView: View {
    let group: YoloGroup
    @Environment(\.dismiss) private var dismiss
    @State private var respondedIds: Set<UUID> = []
    @State private var navigate = false

    private var total:       Int    { group.members.count }
    private var responded:   Int    { respondedIds.count }
    private var progress:    Double { Double(responded) / Double(max(total, 1)) }
    private var allResponded: Bool  { responded == total }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                Spacer()
                VStack(spacing: YoloSpacing.xl) {
                    progressRing
                    membersGrid
                    nudgeButton
                }
                Spacer()
                bottomBar
            }
            .padding(.horizontal, YoloSpacing.md)
        }
        .fullScreenCover(isPresented: $navigate) {
            AISuggestionView(group: group)
        }
        .onAppear { simulateResponses() }
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
            Text("waiting room")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Color.clear.frame(width: 36)
        }
        .padding(.top, 60)
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.yoloBorder, lineWidth: 5)
                .frame(width: 120, height: 120)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.yoloGold, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(YoloSpring.smooth, value: progress)
            VStack(spacing: 2) {
                Text("\(responded)/\(total)")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.white)
                Text("voted")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextSecondary)
            }
        }
    }

    private var membersGrid: some View {
        VStack(spacing: YoloSpacing.md) {
            Text(allResponded ? "everyone's in." : "waiting on responses...")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(allResponded ? Color.yoloGold : Color.yoloTextSecondary)
                .animation(YoloSpring.smooth, value: allResponded)

            HStack(spacing: YoloSpacing.lg) {
                ForEach(group.members) { member in
                    MemberResponseDot(member: member, hasResponded: respondedIds.contains(member.id))
                }
            }
        }
    }

    private var nudgeButton: some View {
        Button {} label: {
            HStack(spacing: 6) {
                Image(systemName: "bell.badge")
                    .font(.system(size: 13))
                Text("poke the slackers")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(Color.yoloTextSecondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.yoloSurface)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(Color.yoloBorder, lineWidth: 0.5))
        }
        .buttonStyle(PressEffectButtonStyle())
        .opacity(allResponded ? 0 : 1)
        .animation(YoloSpring.smooth, value: allResponded)
    }

    private var bottomBar: some View {
        Group {
            if allResponded {
                YoloButton(title: "see suggestions", style: .primary) { navigate = true }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(.bottom, 48)
        .animation(YoloSpring.smooth, value: allResponded)
    }

    private func simulateResponses() {
        for (idx, member) in group.members.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(idx) * 0.8 + 0.6) {
                withAnimation(YoloSpring.bouncy) {
                    _ = respondedIds.insert(member.id)
                }
            }
        }
    }
}
