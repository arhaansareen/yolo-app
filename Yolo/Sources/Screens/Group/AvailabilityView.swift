import SwiftUI

struct AvailabilityView: View {
    let group: YoloGroup
    @Environment(\.dismiss) private var dismiss

    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let timeSlots = ["Morning", "Afternoon", "Evening"]

    private let mockAvailability: [[Int]] = [
        [3, 1, 4],
        [1, 2, 3],
        [4, 4, 2],
        [2, 1, 4],
        [3, 3, 5],
        [5, 4, 3],
        [2, 3, 4],
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: YoloSpacing.lg) {
                        headerSection
                        heatmapSection
                        bestTimesSection
                        memberBreakdown
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, YoloSpacing.md)
                }
            }
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
            Text("availability")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Color.clear.frame(width: 38)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.md)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("who's free this week")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(Color.white)
            Text("based on \(group.members.count) members")
                .font(.system(size: 14))
                .foregroundStyle(Color.yoloTextSecondary)
        }
    }

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "availability heatmap")

            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    Text("").frame(width: 70)
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.yoloTextTertiary)
                            .frame(maxWidth: .infinity)
                    }
                }

                ForEach(Array(timeSlots.enumerated()), id: \.offset) { tIdx, slot in
                    HStack(spacing: 2) {
                        Text(slot)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.yoloTextSecondary)
                            .frame(width: 70, alignment: .leading)

                        ForEach(0..<7, id: \.self) { dIdx in
                            let count = mockAvailability[dIdx][tIdx]
                            let total = group.members.count
                            let fraction = Double(count) / Double(max(total, 1))
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(heatColor(fraction: fraction))
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .overlay(
                                    Text("\(count)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(fraction > 0.5 ? Color.black : Color.yoloTextSecondary)
                                )
                        }
                    }
                }
            }
            .padding(YoloSpacing.md)
            .background(Color.yoloSurface)
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                    .strokeBorder(Color.yoloBorder, lineWidth: 0.5)
            )

            HStack(spacing: YoloSpacing.sm) {
                Text("fewer")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.yoloTextTertiary)
                ForEach([0.1, 0.3, 0.6, 0.85, 1.0], id: \.self) { f in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(heatColor(fraction: f))
                        .frame(width: 18, height: 12)
                }
                Text("more")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.yoloTextTertiary)
            }
        }
    }

    private var bestTimesSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "best windows")
            VStack(spacing: YoloSpacing.xs) {
                BestTimeRow(day: "Saturday", slot: "Morning", count: 5, total: group.members.count, rank: 1)
                BestTimeRow(day: "Friday", slot: "Evening", count: 4, total: group.members.count, rank: 2)
                BestTimeRow(day: "Saturday", slot: "Afternoon", count: 4, total: group.members.count, rank: 3)
            }
            .yoloCard(padding: 0)
        }
    }

    private var memberBreakdown: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "who hasn't responded")
            VStack(spacing: 0) {
                ForEach(Array(group.members.suffix(2).enumerated()), id: \.element.id) { idx, member in
                    if idx > 0 { Divider().background(Color.yoloBorder).padding(.leading, 56) }
                    HStack(spacing: YoloSpacing.sm) {
                        AvatarView(member: member, size: 32)
                            .opacity(0.4)
                        Text(member.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.yoloTextSecondary)
                        Spacer()
                        Button {} label: {
                            Text("nudge")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.yoloGold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.yoloGold.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(PressEffectButtonStyle())
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.vertical, 11)
                }
            }
            .yoloCard(padding: 0)
        }
    }

    private func heatColor(fraction: Double) -> Color {
        if fraction > 0.8 { return Color.yoloGold }
        if fraction > 0.6 { return Color.yoloGold.opacity(0.55) }
        if fraction > 0.35 { return Color.yoloGold.opacity(0.25) }
        return Color.yoloSurface2
    }
}

private struct BestTimeRow: View {
    let day: String
    let slot: String
    let count: Int
    let total: Int
    let rank: Int

    var body: some View {
        HStack(spacing: YoloSpacing.sm) {
            ZStack {
                Circle()
                    .fill(rank == 1 ? Color.yoloGold : Color.yoloSurface2)
                    .frame(width: 28, height: 28)
                    .shadow(color: rank == 1 ? Color.yoloGold.opacity(0.4) : Color.clear, radius: 6)
                Text("\(rank)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(rank == 1 ? Color.black : Color.yoloTextSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(day) \(slot)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white)
                Text("\(count)/\(total) free")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextSecondary)
            }

            Spacer()

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.yoloBorder)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(rank == 1 ? Color.yoloGold : Color.yoloGold.opacity(0.4))
                        .frame(width: geo.size.width * Double(count) / Double(max(total, 1)))
                }
            }
            .frame(width: 80, height: 6)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.vertical, 12)
    }
}
