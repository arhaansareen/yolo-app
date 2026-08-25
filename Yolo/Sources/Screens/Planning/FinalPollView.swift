import SwiftUI

struct FinalPollView: View {
    let group: YoloGroup
    let suggestion: AISuggestion
    @Environment(\.dismiss) private var dismiss
    @State private var votes: [UUID: VoteChoice] = [:]
    @State private var myVote: VoteChoice?
    @State private var navigate = false

    enum VoteChoice { case yes, softYes, no }

    private var yesCount:     Int { votes.values.filter { $0 == .yes }.count }
    private var softYesCount: Int { votes.values.filter { $0 == .softYes }.count }
    private var noCount:      Int { votes.values.filter { $0 == .no }.count }
    private var totalVoted:   Int { votes.count }
    private var isLocked:    Bool { Double(yesCount) / Double(max(group.members.count, 1)) >= 0.8 }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                ScrollView(showsIndicators: false) {
                    VStack(spacing: YoloSpacing.lg) {
                        planCard
                        voteSection
                        resultsSection
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, YoloSpacing.sm)
                    .padding(.bottom, 120)
                }
                bottomBar
            }
        }
        .fullScreenCover(isPresented: $navigate) {
            PlanLockedView(group: group, suggestion: suggestion)
        }
        .onAppear { simulateVotes() }
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
            Text("the poll")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Color.clear.frame(width: 38)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.sm)
    }

    private var planCard: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            Text("THE PLAN")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.yoloGold)
                .tracking(1)

            Text(suggestion.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.white)

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
                    StackedAvatars(members: group.members, size: 24)
                }
            }
        }
        .yoloGoldCard()
    }

    private var voteSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            Text("are you in?")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)

            HStack(spacing: YoloSpacing.sm) {
                VoteButton(label: "Yes", sublabel: "i'll be there", color: .yoloGreen,
                           icon: "checkmark", isSelected: myVote == .yes) {
                    withAnimation(YoloSpring.bouncy) { myVote = .yes; votes[UUID()] = .yes }
                }
                VoteButton(label: "Maybe", sublabel: "soft yes", color: .yoloAmber,
                           icon: "questionmark", isSelected: myVote == .softYes) {
                    withAnimation(YoloSpring.bouncy) { myVote = .softYes; votes[UUID()] = .softYes }
                }
                VoteButton(label: "Can't", sublabel: "can't make it", color: .yoloRed,
                           icon: "xmark", isSelected: myVote == .no) {
                    withAnimation(YoloSpring.bouncy) { myVote = .no; votes[UUID()] = .no }
                }
            }
        }
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            HStack {
                SectionHeader(title: "live results")
                Spacer()
                Text("\(totalVoted)/\(group.members.count) voted")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextSecondary)
            }

            VStack(spacing: YoloSpacing.xs) {
                ResultBar(label: "Yes",   count: yesCount,     total: group.members.count, color: .yoloGreen)
                ResultBar(label: "Maybe", count: softYesCount, total: group.members.count, color: .yoloAmber)
                ResultBar(label: "Can't", count: noCount,      total: group.members.count, color: .yoloRed)
            }

            if isLocked {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.yoloGreen)
                    Text("80%+ voted yes — this is happening.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .padding(YoloSpacing.md)
                .background(Color.yoloGreen.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md))
                .overlay(RoundedRectangle(cornerRadius: YoloRadius.md).strokeBorder(Color.yoloGreen.opacity(0.2), lineWidth: 1))
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .yoloCard()
    }

    private var bottomBar: some View {
        VStack {
            YoloButton(title: isLocked ? "lock it in" : "lock in anyway",
                       style: isLocked ? .primary : .secondary) {
                navigate = true
            }
            .padding(.horizontal, YoloSpacing.md)
            .padding(.bottom, 36)
        }
        .background(
            LinearGradient(colors: [Color.black, Color.black.opacity(0)], startPoint: .bottom, endPoint: .top)
                .frame(height: 100).ignoresSafeArea(), alignment: .bottom
        )
    }

    private func simulateVotes() {
        let choices: [VoteChoice] = [.yes, .yes, .yes, .softYes, .no]
        for (idx, member) in group.members.dropFirst().enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(idx) * 0.7 + 0.6) {
                withAnimation(YoloSpring.smooth) { votes[member.id] = choices[idx % choices.count] }
            }
        }
    }
}

private struct VoteButton: View {
    let label: String
    let sublabel: String
    let color: Color
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: isSelected ? "\(icon).circle.fill" : "\(icon).circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? color : Color.yoloTextTertiary)
                Text(label)
                    .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(isSelected ? color : Color.white)
                Text(sublabel)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? color : Color.yoloTextTertiary)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding(.vertical, 16)
            .background(isSelected ? color.opacity(0.15) : Color.yoloSurface)
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: YoloRadius.md)
                    .strokeBorder(isSelected ? color : Color.yoloBorder, lineWidth: isSelected ? 1 : 0.5)
            )
            .scaleEffect(isSelected ? 1.03 : 1)
        }
        .buttonStyle(PressEffectButtonStyle())
    }
}

private struct ResultBar: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    private var fraction: Double { Double(count) / Double(max(total, 1)) }

    var body: some View {
        HStack(spacing: YoloSpacing.sm) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.yoloTextSecondary)
                .frame(width: 44, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.yoloBorder)
                    RoundedRectangle(cornerRadius: 3).fill(color)
                        .frame(width: geo.size.width * fraction)
                        .animation(YoloSpring.smooth, value: fraction)
                }
            }
            .frame(height: 6)
            Text("\(count)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 18, alignment: .trailing)
        }
    }
}
