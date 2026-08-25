import SwiftUI

struct KickOffView: View {
    let group: YoloGroup
    @Environment(\.dismiss) private var dismiss
    @State private var selectedActivity: ActivityType?
    @State private var selectedTimeframe: String?
    @State private var deadline = ""
    @State private var navigate = false

    private let timeframes = ["tonight", "this weekend", "next week", "TBD"]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: YoloSpacing.xl) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("what are we doing?")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(Color.white)
                            Text("for \(group.name)")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.yoloTextSecondary)
                        }

                        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
                            SectionHeader(title: "vibe")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: YoloSpacing.sm) {
                                ForEach(ActivityType.allCases) { activity in
                                    ActivityTile(activity: activity, isSelected: selectedActivity == activity) {
                                        withAnimation(YoloSpring.bouncy) { selectedActivity = activity }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
                            SectionHeader(title: "when")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: YoloSpacing.sm) {
                                    ForEach(timeframes, id: \.self) { tf in
                                        ChipButton(title: tf, isSelected: selectedTimeframe == tf) {
                                            withAnimation(YoloSpring.snappy) { selectedTimeframe = tf }
                                        }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
                            SectionHeader(title: "deadline", action: "optional") {}
                            YoloTextField(placeholder: "e.g. friday 8pm", text: $deadline)
                        }
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, YoloSpacing.md)
                    .padding(.bottom, 120)
                }

                bottomBar
            }
        }
        .fullScreenCover(isPresented: $navigate) {
            SurveyView(group: group, activityType: selectedActivity ?? .surprise, timeframe: selectedTimeframe ?? "TBD")
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
            Text("new plan")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Color.clear.frame(width: 36)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.md)
    }

    private var bottomBar: some View {
        VStack {
            YoloButton(title: "send to the group", style: selectedActivity != nil ? .primary : .ghost) {
                navigate = true
            }
            .disabled(selectedActivity == nil)
            .shadow(color: Color.yoloGold.opacity(0.25), radius: 12, y: 4)
            .padding(.horizontal, YoloSpacing.md)
            .padding(.bottom, 36)
        }
        .background(
            LinearGradient(colors: [Color.black, Color.black.opacity(0)], startPoint: .bottom, endPoint: .top)
                .frame(height: 100).ignoresSafeArea()
            , alignment: .bottom
        )
    }
}

private struct ActivityTile: View {
    let activity: ActivityType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: activity.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.yoloGold)
                Text(activity.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.yoloGold : Color.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 82)
            .background(isSelected ? Color.yoloGold.opacity(0.1) : Color.yoloSurface)
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                    .strokeBorder(isSelected ? Color.yoloGold : Color.yoloBorder, lineWidth: isSelected ? 1 : 0.5)
            )
            .scaleEffect(isSelected ? 1.03 : 1)
        }
        .buttonStyle(PressEffectButtonStyle())
    }
}

#Preview {
    KickOffView(group: YoloGroup.mockData[0])
        .environment(AppState())
}
