import SwiftUI
import MapKit

// MARK: - Transport Mode

enum TransportMode: String, CaseIterable, Identifiable {
    case drive   = "drive"
    case transit = "transit"
    case walk    = "walk"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .drive:   return "car.fill"
        case .transit: return "tram.fill"
        case .walk:    return "figure.walk"
        }
    }

    var mkType: MKDirectionsTransportType {
        switch self {
        case .drive:   return .automobile
        case .transit: return .transit
        case .walk:    return .walking
        }
    }
}

// MARK: - View Model

@Observable
@MainActor
final class MapTriangulationViewModel {
    var travelTimesByMode: [TransportMode: [UUID: TimeInterval]] = [:]
    var selectedMode: TransportMode = .drive
    var isCalculating: Bool = false

    let meetupCoordinate = CLLocationCoordinate2D(latitude: 43.6426, longitude: -79.3871)
    let venueName        = "pizzeria mercatto"
    let venueAddress     = "16 wellington st e, toronto"

    let memberCoordinates: [(Member, CLLocationCoordinate2D)]

    init(members: [Member]) {
        let coords: [String: CLLocationCoordinate2D] = [
            "arh":   .init(latitude: 43.6532, longitude: -79.3832),
            "jade":  .init(latitude: 43.6629, longitude: -79.4200),
            "ko":    .init(latitude: 43.6892, longitude: -79.3452),
            "priya": .init(latitude: 43.6441, longitude: -79.4041),
            "dez":   .init(latitude: 43.7182, longitude: -79.5181),
        ]
        self.memberCoordinates = members.compactMap { m in
            coords[m.name].map { (m, $0) }
        }
    }

    var currentTimes: [UUID: TimeInterval] {
        travelTimesByMode[selectedMode] ?? [:]
    }

    func selectMode(_ mode: TransportMode) async {
        selectedMode = mode
        guard travelTimesByMode[mode] == nil else { return }
        isCalculating = true
        await calculateTimes(for: mode)
        isCalculating = false
    }

    func calculateInitial() async {
        isCalculating = true
        await calculateTimes(for: .drive)
        isCalculating = false
    }

    private func calculateTimes(for mode: TransportMode) async {
        var results: [UUID: TimeInterval] = [:]
        await withTaskGroup(of: (UUID, TimeInterval?).self) { group in
            for (member, coord) in memberCoordinates {
                group.addTask {
                    let req = MKDirections.Request()
                    req.source      = MKMapItem(placemark: MKPlacemark(coordinate: coord))
                    req.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.meetupCoordinate))
                    req.transportType = mode.mkType
                    let resp = try? await MKDirections(request: req).calculate()
                    return (member.id, resp?.routes.first?.expectedTravelTime)
                }
            }
            for await (id, time) in group {
                if let t = time { results[id] = t }
            }
        }
        travelTimesByMode[mode] = results
    }

    func minutes(for member: Member) -> Int? {
        currentTimes[member.id].map { Int($0 / 60) }
    }

    func timeColor(_ mins: Int) -> Color {
        mins < 20 ? .yoloGreen : mins <= 35 ? .yoloAmber : .yoloRed
    }

    var fairnessScore: Double {
        let times = currentTimes.values.map { $0 }
        guard times.count > 1 else { return 1.0 }
        let avg = times.reduce(0, +) / Double(times.count)
        let maxDev = times.map { abs($0 - avg) }.max() ?? 0
        return max(0, min(1, 1 - maxDev / max(avg, 1)))
    }

    var fairnessPercent: String { "\(Int(fairnessScore * 100))%" }

    var fairnessLabel: String {
        switch fairnessScore {
        case 0.8...: return "travel times are well balanced — no one gets stuck with a long ride"
        case 0.6...: return "mostly fair, but someone has a noticeably longer commute"
        default:     return "big variance — worth trying a different spot"
        }
    }

    var avgMinutes: Int? {
        let times = currentTimes.values.map { $0 }
        guard !times.isEmpty else { return nil }
        return Int(times.reduce(0, +) / Double(times.count) / 60)
    }

    var cameraRegion: MapCameraPosition {
        let lats = memberCoordinates.map { $0.1.latitude  } + [meetupCoordinate.latitude]
        let lons = memberCoordinates.map { $0.1.longitude } + [meetupCoordinate.longitude]
        let cLat = ((lats.min() ?? 0) + (lats.max() ?? 0)) / 2
        let cLon = ((lons.min() ?? 0) + (lons.max() ?? 0)) / 2
        let sLat = ((lats.max() ?? 0) - (lats.min() ?? 0)) * 1.5
        let sLon = ((lons.max() ?? 0) - (lons.min() ?? 0)) * 1.5
        return .region(MKCoordinateRegion(
            center: .init(latitude: cLat, longitude: cLon),
            span:   .init(latitudeDelta: max(sLat, 0.02), longitudeDelta: max(sLon, 0.02))
        ))
    }
}

// MARK: - Main View

struct MapTriangulationView: View {
    let group: YoloGroup
    var onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MapTriangulationViewModel

    init(group: YoloGroup, onConfirm: @escaping () -> Void) {
        self.group    = group
        self.onConfirm = onConfirm
        _viewModel = State(initialValue: MapTriangulationViewModel(members: group.members))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()

                // Map fills full height, tray overlaps from bottom
                Map(position: .constant(viewModel.cameraRegion)) {
                    ForEach(viewModel.memberCoordinates, id: \.0.id) { member, coord in
                        Annotation(member.name, coordinate: coord) {
                            MemberMapPin(member: member)
                        }
                    }
                    Annotation("meetup", coordinate: viewModel.meetupCoordinate) {
                        MeetupPin()
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .tint(Color.yoloGold)
                .ignoresSafeArea()

                // Nav overlay
                VStack {
                    navBar
                    Spacer()
                }

                // Bottom tray — maxHeight forces ScrollView to actually scroll
                bottomTray
                    .frame(maxHeight: geo.size.height * 0.58)
            }
        }
        .task { await viewModel.calculateInitial() }
    }

    // MARK: - Nav Bar

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

            Text("find the spot")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.5))
                .clipShape(Capsule())

            Spacer()
            Color.clear.frame(width: 28, height: 28)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 56)
    }

    // MARK: - Bottom Tray

    private var bottomTray: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.yoloBorder)
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 4)

            // Mode picker
            modePicker
                .padding(.horizontal, YoloSpacing.md)
                .padding(.bottom, 4)

            ScrollView(showsIndicators: false) {
                VStack(spacing: YoloSpacing.md) {
                    venueCard
                        .padding(.horizontal, YoloSpacing.md)

                    membersCard
                        .padding(.horizontal, YoloSpacing.md)

                    fairnessCard
                        .padding(.horizontal, YoloSpacing.md)

                    confirmButton
                        .padding(.horizontal, YoloSpacing.md)
                        .padding(.bottom, 36)
                }
                .padding(.top, YoloSpacing.sm)
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

    // MARK: - Mode Picker

    private var modePicker: some View {
        HStack(spacing: 6) {
            ForEach(TransportMode.allCases) { mode in
                Button {
                    Task { await viewModel.selectMode(mode) }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 12, weight: .medium))
                        Text(mode.rawValue)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(viewModel.selectedMode == mode ? Color.black : Color.yoloTextSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        viewModel.selectedMode == mode
                            ? Color.yoloGold
                            : Color.yoloSurface2
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(PressEffectButtonStyle())
                .animation(YoloSpring.snappy, value: viewModel.selectedMode)
            }
        }
    }

    // MARK: - Venue Card

    private var venueCard: some View {
        HStack(spacing: YoloSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: YoloRadius.sm, style: .continuous)
                    .fill(Color.yoloGold.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "star.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.yoloGold)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.venueName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.white)
                Text(viewModel.venueAddress)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextSecondary)
            }

            Spacer()

            if let avg = viewModel.avgMinutes, !viewModel.isCalculating {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("avg")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.yoloTextTertiary)
                        .tracking(0.6)
                    Text("\(avg) min")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.yoloGold)
                }
            }
        }
        .padding(YoloSpacing.md)
        .background(Color.yoloGold.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous)
                .strokeBorder(Color.yoloGold.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Members Card

    private var membersCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(group.members.enumerated()), id: \.element.id) { idx, member in
                if idx > 0 {
                    Divider().background(Color.yoloBorder).padding(.leading, 52)
                }
                memberRow(member: member)
            }
        }
        .yoloCard(padding: 0)
    }

    private func memberRow(member: Member) -> some View {
        HStack(spacing: YoloSpacing.sm) {
            AvatarView(member: member, size: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.white)
                HStack(spacing: 4) {
                    Image(systemName: viewModel.selectedMode.icon)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.yoloTextTertiary)
                    Text(viewModel.selectedMode.rawValue)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.yoloTextTertiary)
                }
            }

            Spacer()

            if viewModel.isCalculating {
                SkeletonCapsule()
            } else if let mins = viewModel.minutes(for: member) {
                TravelBadge(minutes: mins, color: viewModel.timeColor(mins))
            } else {
                Text("n/a")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.yoloTextTertiary)
            }
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.vertical, 12)
    }

    // MARK: - Fairness Card

    private var fairnessCard: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            HStack {
                Image(systemName: "scale.3d")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.yoloGold)
                Text("fairness score")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white)
                Spacer()
                Text(viewModel.isCalculating ? "..." : viewModel.fairnessPercent)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.yoloGold)
                    .animation(YoloSpring.smooth, value: viewModel.fairnessPercent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.yoloBorder)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(
                            colors: [Color.yoloGold.opacity(0.7), Color.yoloGold],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: geo.size.width * viewModel.fairnessScore)
                        .animation(YoloSpring.smooth, value: viewModel.fairnessScore)
                }
            }
            .frame(height: 6)

            Text(viewModel.isCalculating ? "calculating..." : viewModel.fairnessLabel)
                .font(.system(size: 11))
                .foregroundStyle(Color.yoloTextSecondary)
        }
        .yoloCard()
    }

    // MARK: - Confirm Button

    private var confirmButton: some View {
        Button { onConfirm() } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                Text("confirm this spot")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(Color.black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(LinearGradient(
                colors: [Color.yoloGoldLight, Color.yoloGold],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.lg, style: .continuous))
            .shadow(color: Color.yoloGold.opacity(0.25), radius: 12, y: 4)
        }
        .buttonStyle(GoldPressButtonStyle())
    }
}

// MARK: - Sub-components

private struct MemberMapPin: View {
    let member: Member

    var body: some View {
        ZStack {
            Circle()
                .fill(member.avatarColor)
                .frame(width: 34, height: 34)
                .shadow(color: member.avatarColor.opacity(0.5), radius: 6, y: 2)
            Text(member.name.prefix(1).uppercased())
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.black)
        }
    }
}

private struct MeetupPin: View {
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

private struct TravelBadge: View {
    let minutes: Int
    let color: Color

    var body: some View {
        Text("\(minutes) min")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

private struct SkeletonCapsule: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.yoloSurface2)
            .frame(width: 60, height: 22)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        colors: [.clear, Color.white.opacity(0.06), .clear],
                        startPoint: UnitPoint(x: phase - 0.3, y: 0.5),
                        endPoint:   UnitPoint(x: phase + 0.3, y: 0.5)
                    ))
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.3
                }
            }
    }
}

// MARK: - Preview

#Preview {
    MapTriangulationView(group: YoloGroup.mockData[0]) {}
}
