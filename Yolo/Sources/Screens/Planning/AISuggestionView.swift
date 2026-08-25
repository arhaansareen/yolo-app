import SwiftUI

struct AISuggestionView: View {
    let group: YoloGroup
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIdx: Int?
    @State private var expandedIdx: Int?
    @State private var navigate = false
    @State private var rerollsLeft = 2
    @State private var isLoading = true
    @State private var loadingProgress: Double = 0

    private let suggestions: [AISuggestion] = [
        AISuggestion(id: UUID(), title: "dinner + bowling",
                     description: "start with food, end at the lanes",
                     why: "4/5 wanted food, 3/5 were down for an activity — this satisfies both.",
                     estimatedCostPerPerson: "$35–55", vibes: ["casual", "competitive", "2–3 hrs"], venue: nil),
        AISuggestion(id: UUID(), title: "rooftop bar",
                     description: "drinks with a view, everyone within 20 min",
                     why: "3/5 picked going out, mid budget across the board, and the spot is central.",
                     estimatedCostPerPerson: "$25–40", vibes: ["social", "low effort", "1–2 hrs"], venue: nil),
        AISuggestion(id: UUID(), title: "hosted night in",
                     description: "someone hosts. snacks, drinks, good time.",
                     why: "2 people flagged low effort — this is the path of least resistance.",
                     estimatedCostPerPerson: "$10–20", vibes: ["chill", "flexible"], venue: nil),
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if isLoading { loadingView } else { contentView }
        }
        .fullScreenCover(isPresented: $navigate) {
            FinalPollView(group: group, suggestion: suggestions[selectedIdx ?? 0])
        }
        .onAppear { simulateLoading() }
    }

    private var loadingView: some View {
        VStack(spacing: YoloSpacing.xl) {
            Spacer()
            VStack(spacing: YoloSpacing.sm) {
                Image(systemName: "brain")
                    .font(.system(size: 44, weight: .ultraLight))
                    .foregroundStyle(Color.yoloGold)
                Text("AI is figuring it out")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.white)
                Text("reading all \(group.members.count) votes")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.yoloTextSecondary)
            }
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3).fill(Color.yoloBorder).frame(height: 3)
                RoundedRectangle(cornerRadius: 3).fill(Color.yoloGold)
                    .frame(width: UIScreen.main.bounds.width * 0.65 * loadingProgress, height: 3)
                    .animation(YoloSpring.smooth, value: loadingProgress)
            }
            .frame(width: UIScreen.main.bounds.width * 0.65)
            Spacer()
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            navBar
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: YoloSpacing.md) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI picked these.")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.white)
                        Text("based on everyone's votes")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.yoloTextSecondary)
                    }

                    ForEach(Array(suggestions.enumerated()), id: \.element.id) { idx, suggestion in
                        SuggestionCard(
                            suggestion: suggestion,
                            isSelected: selectedIdx == idx,
                            isExpanded: expandedIdx == idx,
                            isTopPick: idx == 0,
                            onSelect: {
                                withAnimation(YoloSpring.smooth) {
                                    selectedIdx  = selectedIdx  == idx ? nil : idx
                                    expandedIdx  = expandedIdx  == idx ? nil : idx
                                }
                            }
                        )
                    }

                    if rerollsLeft > 0 {
                        Button { rerollsLeft -= 1 } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 13, weight: .medium))
                                Text("not feeling these? re-roll (\(rerollsLeft) left)")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundStyle(Color.yoloTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.yoloSurface)
                            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md))
                            .overlay(RoundedRectangle(cornerRadius: YoloRadius.md).strokeBorder(Color.yoloBorder, lineWidth: 0.5))
                        }
                        .buttonStyle(PressEffectButtonStyle())
                    }
                }
                .padding(.horizontal, YoloSpacing.md)
                .padding(.top, YoloSpacing.sm)
                .padding(.bottom, 120)
            }
            bottomBar
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
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.sm)
    }

    private var bottomBar: some View {
        VStack {
            YoloButton(title: "put it to a vote", style: selectedIdx != nil ? .primary : .ghost) {
                navigate = true
            }
            .disabled(selectedIdx == nil)
            .padding(.horizontal, YoloSpacing.md)
            .padding(.bottom, 36)
        }
        .background(
            LinearGradient(colors: [Color.black, Color.black.opacity(0)], startPoint: .bottom, endPoint: .top)
                .frame(height: 100).ignoresSafeArea()
            , alignment: .bottom
        )
    }

    private func simulateLoading() {
        for (i, step) in [0.3, 0.65, 0.88, 1.0].enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) { loadingProgress = step }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(YoloSpring.smooth) { isLoading = false }
        }
    }
}

private struct SuggestionCard: View {
    let suggestion: AISuggestion
    let isSelected: Bool
    let isExpanded: Bool
    let isTopPick: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: YoloSpacing.sm) {
                HStack(alignment: .top, spacing: YoloSpacing.sm) {
                    VStack(alignment: .leading, spacing: 4) {
                        if isTopPick {
                            Text("TOP PICK")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.yoloGold)
                                .tracking(1.2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.yoloGold.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        Text(suggestion.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.white)
                        Text(suggestion.description)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.yoloTextSecondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    ZStack {
                        Circle().fill(isSelected ? Color.yoloGold : Color.yoloBorder).frame(width: 22, height: 22)
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(Color.black)
                        }
                    }
                }

                HStack(spacing: YoloSpacing.sm) {
                    ForEach(suggestion.vibes, id: \.self) { vibe in
                        Text(vibe)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.yoloTextSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yoloSurface2)
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Text(suggestion.estimatedCostPerPerson + "/person")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.yoloGold)
                }

                if isExpanded {
                    Divider().background(Color.yoloBorder)
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.yoloGold)
                        Text(suggestion.why)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.yoloTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(YoloSpacing.md)
            .background(isSelected ? Color.yoloGold.opacity(0.06) : Color.yoloSurface)
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.yoloGold : (isTopPick ? Color.yoloGold : Color.yoloBorder),
                        lineWidth: isSelected ? 1 : (isTopPick ? 1 : 0.5)
                    )
            )
        }
        .buttonStyle(PressEffectButtonStyle())
    }
}

#Preview {
    AISuggestionView(group: YoloGroup.mockData[0])
        .environment(AppState())
}
