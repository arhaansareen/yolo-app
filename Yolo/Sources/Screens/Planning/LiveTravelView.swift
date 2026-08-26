import SwiftUI
import MapKit

// MARK: - Travel Status

enum TravelStatus: Equatable {
    case notLeft
    case onTheWay(departure: Date, etaMinutes: Int)
    case arrived

    var label: String {
        switch self {
        case .notLeft:
            return "not left yet"
        case .onTheWay(let departure, let eta):
            let arrival = departure.addingTimeInterval(Double(eta * 60))
            let f = DateFormatter()
            f.dateFormat = "h:mm a"
            return "arrive ~\(f.string(from: arrival))"
        case .arrived:
            return "here"
        }
    }

    var color: Color {
        switch self {
        case .notLeft:   return .yoloTextTertiary
        case .onTheWay:  return .yoloAmber
        case .arrived:   return .yoloGreen
        }
    }

    var icon: String {
        switch self {
        case .notLeft:   return "clock"
        case .onTheWay:  return "car.fill"
        case .arrived:   return "checkmark.circle.fill"
        }
    }

    var isOnTheWay: Bool {
        if case .onTheWay = self { return true }
        return false
    }
}

// MARK: - View Model

@Observable
@MainActor
final class LiveTravelViewModel {
    var statuses: [UUID: TravelStatus] = [:]
    var etaMinutes: [UUID: Int] = [:]
    var isCalculating = true

    let meetupCoordinate = CLLocationCoordinate2D(latitude: 43.6426, longitude: -79.3871)
    let venueName = "pizzeria mercatto"
    let members: [Member]
    let currentUserId: UUID

    private let memberCoords: [String: CLLocationCoordinate2D] = [
        "arh":   .init(latitude: 43.6532, longitude: -79.3832),
        "jade":  .init(latitude: 43.6629, longitude: -79.4200),
        "ko":    .init(latitude: 43.6892, longitude: -79.3452),
        "priya": .init(latitude: 43.6441, longitude: -79.4041),
        "dez":   .init(latitude: 43.7182, longitude: -79.5181),
    ]

    init(members: [Member], currentUserId: UUID) {
        self.members = members
        self.currentUserId = currentUserId
        for m in members { statuses[m.id] = .notLeft }
    }

    var currentStatus: TravelStatus { statuses[currentUserId] ?? .notLeft }

    var onTheWayCount: Int { statuses.values.filter { $0.isOnTheWay }.count }
    var arrivedCount:  Int { statuses.values.filter { $0 == .arrived }.count }

    func calculateETAs() async {
        await withTaskGroup(of: (UUID, Int?).self) { group in
            for member in members {
                guard let coord = memberCoords[member.name] else { continue }
                group.addTask {
                    let req = MKDirections.Request()
                    req.source      = MKMapItem(placemark: MKPlacemark(coordinate: coord))
                    req.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.meetupCoordinate))
                    req.transportType = .automobile
                    let resp = try? await MKDirections(request: req).calculate()
                    let secs = resp?.routes.first?.expectedTravelTime
                    let mins = secs.map { Int($0 / 60) }
                    return (member.id, mins)
                }
            }
            for await (id, mins) in group {
                if let m = mins { etaMinutes[id] = m }
            }
        }
        isCalculating = false
    }

    func iAmLeaving() {
        let eta = etaMinutes[currentUserId] ?? 20
        withAnimation(YoloSpring.bouncy) {
            statuses[currentUserId] = .onTheWay(departure: Date(), etaMinutes: eta)
        }
    }

    func iArrived() {
        withAnimation(YoloSpring.bouncy) {
            statuses[currentUserId] = .arrived
        }
    }

    func resetDemo() {
        withAnimation(YoloSpring.smooth) {
            for m in members { statuses[m.id] = .notLeft }
        }
        simulateOthers()
    }

    // Demo: simulate other members trickling in
    func simulateOthers() {
        let others = members.filter { $0.id != currentUserId }
        for (i, member) in others.enumerated() {
            let leaveDelay = Double(i + 1) * 4.0
            let eta = etaMinutes[member.id] ?? Int.random(in: 12...28)
            Task {
                try? await Task.sleep(for: .seconds(leaveDelay))
                withAnimation(YoloSpring.bouncy) {
                    statuses[member.id] = .onTheWay(departure: Date(), etaMinutes: eta)
                }
                // Arrive after a short demo delay
                try? await Task.sleep(for: .seconds(Double(eta) * 0.3))
                withAnimation(YoloSpring.bouncy) {
                    statuses[member.id] = .arrived
                }
            }
        }
    }

    var cameraRegion: MapCameraPosition {
        let coords = members.compactMap { memberCoords[$0.name] }
        let all = coords + [meetupCoordinate]
        let lats = all.map(\.latitude)
        let lons = all.map(\.longitude)
        let cLat = ((lats.min() ?? 0) + (lats.max() ?? 0)) / 2
        let cLon = ((lons.min() ?? 0) + (lons.max() ?? 0)) / 2
        let sLat = ((lats.max() ?? 0) - (lats.min() ?? 0)) * 1.5
        let sLon = ((lons.max() ?? 0) - (lons.min() ?? 0)) * 1.5
        return .region(MKCoordinateRegion(
            center: .init(latitude: cLat, longitude: cLon),
            span:   .init(latitudeDelta: max(sLat, 0.02), longitudeDelta: max(sLon, 0.02))
        ))
    }

    func coord(for member: Member) -> CLLocationCoordinate2D? {
        memberCoords[member.name]
    }
}

// MARK: - Main View

struct LiveTravelView: View {
    let group: YoloGroup
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: LiveTravelViewModel

    init(group: YoloGroup) {
        self.group = group
        // Use first member as current user placeholder (AppState not available in init)
        let uid = Member.mockMembers.first!.id
        _viewModel = State(initialValue: LiveTravelViewModel(members: group.members, currentUserId: uid))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()

                Map(position: .constant(viewModel.cameraRegion)) {
                    ForEach(group.members, id: \.id) { member in
                        if let coord = viewModel.coord(for: member) {
                            Annotation(member.name, coordinate: coord) {
                                LiveMemberPin(
                                    member: member,
                                    status: viewModel.statuses[member.id] ?? .notLeft
                                )
                            }
                        }
                    }
                    Annotation("meetup", coordinate: viewModel.meetupCoordinate) {
                        MeetupStarPin()
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .tint(Color.yoloGold)
                .ignoresSafeArea()

                VStack { navBar; Spacer() }

                tray.frame(maxHeight: geo.size.height * 0.55)
            }
        }
        .task {
            await viewModel.calculateETAs()
            viewModel.simulateOthers()
        }
    }

    // MARK: - Nav

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.5), radius: 4)
            }
            .buttonStyle(PressEffectButtonStyle())

            Spacer()

            VStack(spacing: 2) {
                Text("we're heading there")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white)
                Text(viewModel.venueName)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.yoloTextSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Color.black.opacity(0.5))
            .clipShape(Capsule())

            Spacer()

            Button { viewModel.resetDemo() } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(PressEffectButtonStyle())
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 56)
    }

    // MARK: - Tray

    private var tray: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.yoloBorder)
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: YoloSpacing.md) {
                    statusSummary
                        .padding(.horizontal, YoloSpacing.md)
                    membersList
                        .padding(.horizontal, YoloSpacing.md)
                    myStatusButton
                        .padding(.horizontal, YoloSpacing.md)
                        .padding(.bottom, 36)
                }
                .padding(.top, 4)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.yoloBorder, lineWidth: 0.5)
                )
                .ignoresSafeArea(edges: .bottom)
        )
        .frame(maxWidth: .infinity)
    }

    // MARK: - Status Summary

    private var statusSummary: some View {
        HStack(spacing: YoloSpacing.sm) {
            summaryChip(
                count: viewModel.onTheWayCount,
                label: "on the way",
                color: .yoloAmber,
                icon: "car.fill"
            )
            summaryChip(
                count: viewModel.arrivedCount,
                label: "arrived",
                color: .yoloGreen,
                icon: "checkmark.circle.fill"
            )
            summaryChip(
                count: group.members.count - viewModel.onTheWayCount - viewModel.arrivedCount,
                label: "not left",
                color: .yoloTextTertiary,
                icon: "clock"
            )
        }
    }

    private func summaryChip(count: Int, label: String, color: Color, icon: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(count > 0 ? color : Color.yoloTextTertiary)
            Text("\(count)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(count > 0 ? color : Color.yoloTextTertiary)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color.yoloTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(count > 0 ? color.opacity(0.08) : Color.yoloSurface)
        .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous)
                .strokeBorder(count > 0 ? color.opacity(0.25) : Color.yoloBorder, lineWidth: 0.5)
        )
        .animation(YoloSpring.smooth, value: count)
    }

    // MARK: - Members List

    private var membersList: some View {
        VStack(spacing: 0) {
            ForEach(Array(group.members.enumerated()), id: \.element.id) { idx, member in
                if idx > 0 { Divider().background(Color.yoloBorder).padding(.leading, 52) }
                memberRow(member)
            }
        }
        .yoloCard(padding: 0)
    }

    private func memberRow(_ member: Member) -> some View {
        let status = viewModel.statuses[member.id] ?? .notLeft
        let isMe = member.id == viewModel.currentUserId

        return HStack(spacing: YoloSpacing.sm) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(member: member, size: 32)
                    .opacity(status == .notLeft ? 0.45 : 1.0)
                Circle()
                    .fill(status.color)
                    .frame(width: 9, height: 9)
                    .overlay(Circle().strokeBorder(Color.black, lineWidth: 1.5))
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(member.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(status == .notLeft ? Color.yoloTextSecondary : Color.white)
                    if isMe {
                        Text("you")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.yoloGold)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.yoloGold.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                Text(viewModel.isCalculating ? "calculating..." : status.label)
                    .font(.system(size: 11))
                    .foregroundStyle(status.color)
            }

            Spacer()

            Image(systemName: status.icon)
                .font(.system(size: 16))
                .foregroundStyle(status.color)
                .symbolEffect(.pulse, isActive: status.isOnTheWay)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.vertical, 12)
        .animation(YoloSpring.smooth, value: status.label)
    }

    // MARK: - My Status Button

    private var myStatusButton: some View {
        let status = viewModel.currentStatus

        return Group {
            switch status {
            case .notLeft:
                Button { viewModel.iAmLeaving() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "car.fill").font(.system(size: 15, weight: .bold))
                        Text("i'm leaving").font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(LinearGradient(
                        colors: [Color.yoloGoldLight, Color.yoloGold],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
                    .shadow(color: Color.yoloGold.opacity(0.3), radius: 12, y: 4)
                }
                .buttonStyle(GoldPressButtonStyle())

            case .onTheWay(let departure, let eta):
                let arrival = departure.addingTimeInterval(Double(eta * 60))
                let f: DateFormatter = {
                    let df = DateFormatter(); df.dateFormat = "h:mm a"; return df
                }()
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.yoloAmber)
                            .symbolEffect(.pulse)
                        Text("you're on the way · arrive ~\(f.string(from: arrival))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.yoloAmber)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.yoloAmber.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                            .strokeBorder(Color.yoloAmber.opacity(0.25), lineWidth: 1)
                    )

                    Button { viewModel.iArrived() } label: {
                        Text("i'm here")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.yoloTextSecondary)
                    }
                }

            case .arrived:
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.yoloGreen)
                    Text("you made it")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.yoloGreen)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.yoloGreen.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                        .strokeBorder(Color.yoloGreen.opacity(0.25), lineWidth: 1)
                )
            }
        }
        .animation(YoloSpring.bouncy, value: status.label)
    }
}

// MARK: - Map Pins

private struct LiveMemberPin: View {
    let member: Member
    let status: TravelStatus
    @State private var pulse = false

    var body: some View {
        ZStack {
            if status.isOnTheWay {
                Circle()
                    .fill(Color.yoloAmber.opacity(0.25))
                    .frame(width: 50, height: 50)
                    .scaleEffect(pulse ? 1.3 : 1.0)
                    .opacity(pulse ? 0 : 1)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.4).repeatForever(autoreverses: false)) {
                            pulse = true
                        }
                    }
            }

            Circle()
                .fill(status == .notLeft ? Color.yoloSurface2 : member.avatarColor)
                .frame(width: 34, height: 34)
                .overlay(Circle().strokeBorder(status.color, lineWidth: 2))
                .shadow(color: member.avatarColor.opacity(status == .notLeft ? 0 : 0.45), radius: 6, y: 2)

            Text(member.name.prefix(1).uppercased())
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(status == .notLeft ? Color.yoloTextTertiary : Color.black)
        }
        .animation(YoloSpring.bouncy, value: status.label)
    }
}

private struct MeetupStarPin: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.85))
                .frame(width: 38, height: 38)
                .overlay(Circle().strokeBorder(Color.yoloGold, lineWidth: 2))
            Image(systemName: "star.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.yoloGold)
        }
        .shadow(color: Color.yoloGold.opacity(0.4), radius: 8, y: 3)
    }
}

// MARK: - Preview

#Preview {
    LiveTravelView(group: YoloGroup.mockData[0])
        .environment(AppState())
}
