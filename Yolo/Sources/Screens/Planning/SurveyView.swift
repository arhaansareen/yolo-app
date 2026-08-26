import SwiftUI

struct SurveyView: View {
    let group: YoloGroup
    let activityType: ActivityType
    let timeframe: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedActivities: Set<ActivityType> = []
    @State private var selectedBudget: PlanResponse.BudgetTier = .low
    @State private var selectedDays: Set<Int> = []
    @State private var effortLevel: PlanResponse.EffortLevel = .medium
    @State private var selectedDietary: Set<Member.DietaryTag> = []
    @State private var navigate = false

    private let days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: YoloSpacing.xl) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("what are you feeling?")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(Color.white)
                            Text("pick everything that sounds good")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.yoloTextSecondary)
                        }

                        activitiesSection
                        budgetSection
                        availabilitySection
                        effortSection
                        dietarySection
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, YoloSpacing.md)
                    .padding(.bottom, 120)
                }

                bottomBar
            }
        }
        .fullScreenCover(isPresented: $navigate) {
            WaitingRoomView(group: group)
        }
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 38, height: 38)
                    .background(Color.yoloSurface2)
                    .clipShape(Circle())
            }
            Spacer()
            Text("your vote")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Color.clear.frame(width: 38)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.md)
    }

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "what sounds good")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: YoloSpacing.sm) {
                ForEach(ActivityType.allCases) { activity in
                    let isSelected = selectedActivities.contains(activity)
                    Button {
                        withAnimation(YoloSpring.bouncy) {
                            if isSelected { _ = selectedActivities.remove(activity) }
                            else { _ = selectedActivities.insert(activity) }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: activity.icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(isSelected ? Color.black : Color.yoloGold)
                                .frame(width: 28)
                            Text(activity.rawValue)
                                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? Color.black : Color.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
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
        }
    }

    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "budget per person")
            HStack(spacing: YoloSpacing.sm) {
                ForEach(PlanResponse.BudgetTier.allCases, id: \.self) { tier in
                    Button {
                        withAnimation(YoloSpring.snappy) { selectedBudget = tier }
                    } label: {
                        Text(tier.rawValue)
                            .font(.system(size: 12, weight: selectedBudget == tier ? .semibold : .regular))
                            .foregroundStyle(selectedBudget == tier ? Color.black : Color.white)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(selectedBudget == tier ? Color.yoloGold : Color.yoloSurface)
                            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.sm, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: YoloRadius.sm, style: .continuous)
                                    .strokeBorder(selectedBudget == tier ? Color.clear : Color.yoloBorder, lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(PressEffectButtonStyle())
                }
            }
        }
    }

    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "when are you free")
            HStack(spacing: YoloSpacing.xs) {
                ForEach(Array(days.enumerated()), id: \.offset) { idx, day in
                    let isSelected = selectedDays.contains(idx)
                    Button {
                        withAnimation(YoloSpring.bouncy) {
                            if isSelected { _ = selectedDays.remove(idx) }
                            else { _ = selectedDays.insert(idx) }
                        }
                    } label: {
                        Text(day)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(isSelected ? Color.black : Color.yoloTextSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(isSelected ? Color.yoloGold : Color.yoloSurface)
                            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.sm, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: YoloRadius.sm, style: .continuous)
                                    .strokeBorder(isSelected ? Color.clear : Color.yoloBorder, lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(PressEffectButtonStyle())
                }
            }
        }
    }

    private var effortSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "how much effort can you give?")
            HStack(spacing: YoloSpacing.sm) {
                ForEach(PlanResponse.EffortLevel.allCases, id: \.self) { level in
                    Button {
                        withAnimation(YoloSpring.snappy) { effortLevel = level }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: level.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(effortLevel == level ? Color.black : Color.yoloGold)
                            Text(level.rawValue)
                                .font(.system(size: 12, weight: effortLevel == level ? .semibold : .regular))
                                .foregroundStyle(effortLevel == level ? Color.black : Color.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(effortLevel == level ? Color.yoloGold : Color.yoloSurface)
                        .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous)
                                .strokeBorder(effortLevel == level ? Color.clear : Color.yoloBorder, lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(PressEffectButtonStyle())
                }
            }
        }
    }

    private var dietarySection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "any dietary needs?")
            Text("we'll filter venue suggestions for the whole group")
                .font(.system(size: 12))
                .foregroundStyle(Color.yoloTextSecondary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: YoloSpacing.xs) {
                ForEach(Member.DietaryTag.allCases, id: \.self) { tag in
                    let isSelected = selectedDietary.contains(tag)
                    Button {
                        withAnimation(YoloSpring.bouncy) {
                            if isSelected { selectedDietary.remove(tag) }
                            else { selectedDietary.insert(tag) }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: tag.icon)
                                .font(.system(size: 12))
                                .foregroundStyle(isSelected ? Color.yoloGold : Color.yoloTextSecondary)
                            Text(tag.rawValue)
                                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? Color.white : Color.yoloTextSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(isSelected ? Color.yoloGold.opacity(0.1) : Color.yoloSurface)
                        .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous)
                                .strokeBorder(isSelected ? Color.yoloGold : Color.yoloBorder, lineWidth: isSelected ? 1 : 0.5)
                        )
                    }
                    .buttonStyle(PressEffectButtonStyle())
                }
            }
        }
    }

    private var bottomBar: some View {
        VStack {
            YoloButton(title: "submit my vote", style: .primary) { navigate = true }
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
