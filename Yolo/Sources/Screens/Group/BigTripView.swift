import SwiftUI

struct BigTripView: View {
    let group: YoloGroup
    @Environment(\.dismiss) private var dismiss
    @State private var checkedItems: Set<String> = []
    @State private var showInvite = false

    private let packingItems = [
        "sunscreen", "bug spray", "cooler", "portable speaker",
        "cash", "ID", "swimsuit", "extra towels"
    ]

    private let tripExpenses: [(String, String, Double, Int)] = [
        // (description, payer, total, splitBy)
        ("groceries", "arh", 120, 5),
        ("gas", "jade", 80, 3),
        ("kayak rental", "ko", 150, 5),
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                ScrollView(showsIndicators: false) {
                    VStack(spacing: YoloSpacing.lg) {
                        tripHeaderCard
                        itinerarySection
                        packingSection
                        costsSection
                        needToKnowSection
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, YoloSpacing.md)
                }
            }
        }
        .sheet(isPresented: $showInvite) {
            InviteView(group: group)
        }
    }

    // MARK: - Nav Bar

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
            Text("big trip")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Button { showInvite = true } label: {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.yoloTextSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.yoloSurface2)
                    .clipShape(Circle())
            }
            .buttonStyle(PressEffectButtonStyle())
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.md)
    }

    // MARK: - Trip Header Card

    private var tripHeaderCard: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("cottage weekend")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text("aug 30 - sep 1")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.yoloGold)
                }
                Spacer()
                Image(systemName: "suitcase.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.yoloGold)
            }
            Divider().background(Color.yoloBorderGold)
            HStack {
                StackedAvatars(members: group.members, size: 28)
                Spacer()
                Text("\(group.members.count) going · 3 days")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextSecondary)
            }
        }
        .yoloGoldCard()
    }

    // MARK: - Itinerary

    private let itinerary: [(String, [String])] = [
        ("sat aug 30", ["drive up · depart 10am", "groceries + bbq · arrive noon", "campfire night"]),
        ("sun aug 31", ["lake morning", "kayaking", "downtown dinner"]),
        ("mon sep 1", ["pack up · head home by noon"]),
    ]

    private var itinerarySection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "itinerary")
            VStack(spacing: YoloSpacing.sm) {
                ForEach(Array(itinerary.enumerated()), id: \.offset) { dayIdx, day in
                    VStack(alignment: .leading, spacing: YoloSpacing.xs) {
                        Text(day.0)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.yoloGold)
                            .padding(.bottom, 2)
                        ForEach(day.1, id: \.self) { item in
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.yoloGold.opacity(0.15))
                                        .frame(width: 24, height: 24)
                                    Text("\(dayIdx + 1)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(Color.yoloGold)
                                }
                                Text(item)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.white)
                                Spacer()
                            }
                        }
                        Button {} label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("add item")
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(Color.yoloTextTertiary)
                            .padding(.top, 2)
                        }
                        .buttonStyle(PressEffectButtonStyle())
                    }
                    .padding(YoloSpacing.md)
                    .background(Color.yoloSurface2)
                    .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous))
                }
            }
        }
    }

    // MARK: - Packing List

    private var packingSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "packing list")
            VStack(spacing: 0) {
                ForEach(packingItems, id: \.self) { item in
                    let isChecked = checkedItems.contains(item)
                    Button {
                        withAnimation(YoloSpring.snappy) {
                            if isChecked { checkedItems.remove(item) }
                            else { checkedItems.insert(item) }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundStyle(isChecked ? Color.yoloGold : Color.yoloBorder)
                            Text(item)
                                .font(.system(size: 14))
                                .foregroundStyle(isChecked ? Color.yoloTextSecondary : Color.white)
                                .strikethrough(isChecked, color: Color.yoloTextSecondary)
                            Spacer()
                        }
                        .padding(.horizontal, YoloSpacing.md)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(PressEffectButtonStyle())
                    if item != packingItems.last {
                        Divider().background(Color.yoloBorder).padding(.leading, 52)
                    }
                }
                Divider().background(Color.yoloBorder).padding(.leading, 52)
                Button {} label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .semibold))
                        Text("add item")
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(Color.yoloTextTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PressEffectButtonStyle())
            }
            .yoloCard(padding: 0)
        }
    }

    // MARK: - Costs

    private var costsSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "costs")

            // Budget card
            VStack(alignment: .leading, spacing: YoloSpacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("estimated per person")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.yoloTextSecondary)
                        Text("$180")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.yoloGold)
                    }
                    Spacer()
                    Text("\(group.members.count) people · $\(180 * group.members.count) total budget")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.yoloTextSecondary)
                        .multilineTextAlignment(.trailing)
                }

                // Progress bar
                let spent: CGFloat = 320
                let budget: CGFloat = 900
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(Color.yoloBorder)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.yoloGold)
                                .frame(width: geo.size.width * min(spent / budget, 1.0))
                        }
                    }
                    .frame(height: 5)
                    HStack {
                        Text("$\(Int(spent)) spent")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.yoloTextSecondary)
                        Spacer()
                        Text("$\(Int(budget)) budget")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.yoloTextSecondary)
                    }
                }
            }
            .yoloCard()

            // Expense rows
            VStack(spacing: 0) {
                ForEach(Array(tripExpenses.enumerated()), id: \.offset) { idx, expense in
                    let payerMember = group.members.first(where: { $0.name == expense.1 }) ?? group.members[0]
                    let yourShare = expense.2 / Double(expense.3)

                    HStack(spacing: 12) {
                        AvatarView(member: payerMember, size: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(expense.0)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.white)
                            Text("paid by \(expense.1) · split \(expense.3) ways")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.yoloTextSecondary)
                        }
                        Spacer()
                        Text("$\(String(format: "%.2f", yourShare))")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.yoloGold)
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.vertical, 12)

                    if idx < tripExpenses.count - 1 {
                        Divider().background(Color.yoloBorder).padding(.leading, 56)
                    }
                }
            }
            .yoloCard(padding: 0)

            // Add expense button
            Button {} label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("add expense")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.yoloGold)
                .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
            }
            .buttonStyle(GoldPressButtonStyle())
        }
    }

    // MARK: - Need to Know

    private var needToKnowSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "need to know")
            VStack(spacing: 0) {
                infoRow(icon: "calendar", text: "check-in: sat aug 30 · 2pm", hasChevron: false)
                Divider().background(Color.yoloBorder).padding(.leading, 48)
                infoRow(icon: "mappin", text: "123 lakeshore rd, muskoka", hasChevron: false)
                Divider().background(Color.yoloBorder).padding(.leading, 48)
                infoRow(icon: "doc.text", text: "booking confirmation · tap to view", hasChevron: true)
            }
            .yoloCard(padding: 0)
        }
    }

    private func infoRow(icon: String, text: String, hasChevron: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.yoloGold)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Color.white)
                .lineLimit(2)
            Spacer()
            if hasChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.yoloTextTertiary)
            }
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.vertical, 14)
    }
}

#Preview {
    BigTripView(group: YoloGroup.mockData[1])
}
