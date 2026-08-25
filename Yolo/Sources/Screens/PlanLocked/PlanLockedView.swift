import SwiftUI

struct PlanLockedView: View {
    let group: YoloGroup
    let suggestion: AISuggestion
    @Environment(\.dismiss) private var dismiss
    @State private var cardVisible    = false
    @State private var actionsVisible = false
    @State private var confettiActive = false
    @State private var showPostEvent  = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if confettiActive { ConfettiLayer().ignoresSafeArea().allowsHitTesting(false) }

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: YoloSpacing.xl) {
                    topSection
                    summaryCard
                    actions
                }
                .padding(.horizontal, YoloSpacing.md)
                Spacer()
                Button { showPostEvent = true } label: {
                    Text("view recap")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.yoloTextSecondary)
                }
                Button { dismiss() } label: {
                    Text("back to group")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.yoloTextTertiary)
                }
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(YoloSpring.bouncy.delay(0.2))  { cardVisible = true }
            withAnimation(YoloSpring.smooth.delay(0.65)) { actionsVisible = true }
            withAnimation(.easeOut(duration: 0.4).delay(0.15)) { confettiActive = true }
        }
    }

    private var topSection: some View {
        VStack(spacing: YoloSpacing.sm) {
            Image(systemName: "lock.fill")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(Color.yoloGold)
                .scaleEffect(cardVisible ? 1 : 0.3)
                .animation(YoloSpring.bouncy.delay(0.1), value: cardVisible)

            VStack(spacing: 5) {
                Text("it's official.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.white)
                Text("this is actually happening")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.yoloTextSecondary)
            }
            .opacity(cardVisible ? 1 : 0)
            .animation(YoloSpring.smooth.delay(0.25), value: cardVisible)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            Text(suggestion.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(suggestion.description)
                .font(.system(size: 14))
                .foregroundStyle(Color.yoloTextSecondary)

            Divider().background(Color.yoloBorder)

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("COST / PERSON")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.yoloTextTertiary)
                        .tracking(0.8)
                    Text(suggestion.estimatedCostPerPerson)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.yoloGold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("WHO'S IN")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.yoloTextTertiary)
                        .tracking(0.8)
                    StackedAvatars(members: group.members, size: 26)
                }
            }
        }
        .padding(YoloSpacing.md)
        .background(
            LinearGradient(colors: [Color.yoloGold.opacity(0.07), Color.yoloSurface],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                .strokeBorder(Color.yoloGold.opacity(0.28), lineWidth: 1)
        )
        .scaleEffect(cardVisible ? 1 : 0.92)
        .opacity(cardVisible ? 1 : 0)
        .animation(YoloSpring.smooth.delay(0.35), value: cardVisible)
    }

    private var actions: some View {
        VStack(spacing: YoloSpacing.sm) {
            YoloButton(title: "add to calendar", icon: "calendar.badge.plus", style: .primary) {}

            HStack(spacing: YoloSpacing.sm) {
                Button {} label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up").font(.system(size: 13))
                        Text("share").font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(Color.yoloGold)
                    .frame(maxWidth: .infinity).frame(height: 46)
                    .background(Color.yoloGold.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md))
                    .overlay(RoundedRectangle(cornerRadius: YoloRadius.md).strokeBorder(Color.yoloGold.opacity(0.2), lineWidth: 1))
                }
                .buttonStyle(PressEffectButtonStyle())

                Button {} label: {
                    HStack(spacing: 6) {
                        Image(systemName: "message").font(.system(size: 13))
                        Text("open gc").font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity).frame(height: 46)
                    .background(Color.yoloSurface2)
                    .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md))
                }
                .buttonStyle(PressEffectButtonStyle())
            }
        }
        .opacity(actionsVisible ? 1 : 0)
        .offset(y: actionsVisible ? 0 : 18)
        .animation(YoloSpring.smooth.delay(0.55), value: actionsVisible)
    }
}

private struct ConfettiPiece: View {
    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    let color: Color
    let startX: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 2).fill(color)
            .frame(width: 7, height: 11)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                position = CGPoint(x: startX, y: -20)
                withAnimation(.easeIn(duration: Double.random(in: 1.1...1.9))) {
                    position = CGPoint(x: startX + CGFloat.random(in: -60...60), y: UIScreen.main.bounds.height + 40)
                    opacity = 0
                    rotation = Double.random(in: 180...720)
                }
            }
    }
}

private struct ConfettiLayer: View {
    private let colors: [Color] = [.yoloGold, .yoloGoldLight, .white, .yoloGreen, .yoloAmber]
    var body: some View {
        ZStack {
            ForEach(0..<36, id: \.self) { i in
                ConfettiPiece(color: colors[i % colors.count],
                              startX: CGFloat.random(in: 0...UIScreen.main.bounds.width))
            }
        }
    }
}

#Preview {
    PlanLockedView(
        group: YoloGroup.mockData[0],
        suggestion: AISuggestion(id: UUID(), title: "dinner + bowling",
                                 description: "start with food, end at the lanes",
                                 why: "everyone wanted food",
                                 estimatedCostPerPerson: "$35–55",
                                 vibes: ["casual", "fun"], venue: nil)
    )
    .environment(AppState())
}
