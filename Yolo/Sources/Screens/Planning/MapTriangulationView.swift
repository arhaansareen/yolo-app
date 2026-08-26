import SwiftUI
import MapKit

// MARK: - View Model

@Observable
@MainActor
final class MapTriangulationViewModel {
    var travelTimes: [UUID: TimeInterval] = [:]
    var isCalculating: Bool = true

    let meetupCoordinate = CLLocationCoordinate2D(latitude: 43.6426, longitude: -79.3871)
    let venueName = "pizzeria mercatto"
    let venueAddress = "16 wellington st e"

    let memberCoordinates: [(Member, CLLocationCoordinate2D)]

    init(members: [Member]) {
        let coords: [String: CLLocationCoordinate2D] = [
            "arh":   CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
            "jade":  CLLocationCoordinate2D(latitude: 43.6629, longitude: -79.4200),
            "ko":    CLLocationCoordinate2D(latitude: 43.6892, longitude: -79.3452),
            "priya": CLLocationCoordinate2D(latitude: 43.6441, longitude: -79.4041),
            "dez":   CLLocationCoordinate2D(latitude: 43.7182, longitude: -79.5181),
        ]
        self.memberCoordinates = members.compactMap { member in
            guard let coord = coords[member.name] else { return nil }
            return (member, coord)
        }
    }

    func calculateTravelTimes() async {
        await withTaskGroup(of: (UUID, TimeInterval?).self) { group in
            for (member, coordinate) in memberCoordinates {
                group.addTask {
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.meetupCoordinate))
                    request.transportType = .automobile
                    let directions = MKDirections(request: request)
                    let response = try? await directions.calculate()
                    let time = response?.routes.first?.expectedTravelTime
                    return (member.id, time)
                }
            }
            for await (id, time) in group {
                travelTimes[id] = time
            }
        }
        isCalculating = false
    }

    func travelMinutes(for member: Member) -> Int? {
        guard let seconds = travelTimes[member.id] else { return nil }
        return Int(seconds / 60)
    }

    func timeColor(minutes: Int) -> Color {
        if minutes < 20 { return .yoloGreen }
        if minutes <= 35 { return .yoloAmber }
        return .yoloRed
    }

    /// Camera region that fits all member pins + meetup point
    var cameraRegion: MapCameraPosition {
        let lats = memberCoordinates.map { $0.1.latitude } + [meetupCoordinate.latitude]
        let lons = memberCoordinates.map { $0.1.longitude } + [meetupCoordinate.longitude]
        let minLat = lats.min() ?? meetupCoordinate.latitude
        let maxLat = lats.max() ?? meetupCoordinate.latitude
        let minLon = lons.min() ?? meetupCoordinate.longitude
        let maxLon = lons.max() ?? meetupCoordinate.longitude
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        let spanLat = (maxLat - minLat) * 1.4
        let spanLon = (maxLon - minLon) * 1.4
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: max(spanLat, 0.02), longitudeDelta: max(spanLon, 0.02))
        )
        return .region(region)
    }
}

// MARK: - Main View

struct MapTriangulationView: View {
    let group: YoloGroup
    var onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MapTriangulationViewModel
    @State private var trayOffset: CGFloat = 0

    init(group: YoloGroup, onConfirm: @escaping () -> Void) {
        self.group = group
        self.onConfirm = onConfirm
        _viewModel = State(initialValue: MapTriangulationViewModel(members: group.members))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            // Zone 1 — Map
            GeometryReader { geo in
                Map(position: .constant(viewModel.cameraRegion)) {
                    // Member annotations
                    ForEach(viewModel.memberCoordinates, id: \.0.id) { member, coordinate in
                        Annotation(member.name, coordinate: coordinate) {
                            MemberMapPin(member: member)
                        }
                    }
                    // Meetup venue pin
                    Annotation("meetup", coordinate: viewModel.meetupCoordinate) {
                        MeetupPin()
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .tint(Color.yoloGold)
                .frame(height: geo.size.height * 0.58)
                .ignoresSafeArea(edges: .top)
            }

            // Nav bar overlay
            VStack {
                navBar
                Spacer()
            }

            // Zone 2 — Bottom tray
            bottomTray
                .offset(y: trayOffset)
        }
        .task {
            await viewModel.calculateTravelTimes()
        }
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

            // Balance the layout
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
                .padding(.bottom, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: YoloSpacing.md) {
                    // Section header
                    HStack {
                        SectionHeader(title: "the spot")
                        Spacer()
                    }
                    .padding(.horizontal, YoloSpacing.md)

                    // Venue gold card
                    venueCard
                        .padding(.horizontal, YoloSpacing.md)

                    // Member rows
                    membersCard
                        .padding(.horizontal, YoloSpacing.md)

                    // Fairness score
                    fairnessCard
                        .padding(.horizontal, YoloSpacing.md)

                    // CTA
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
        )
        .frame(maxWidth: .infinity)
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

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.yoloGold)
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
                    Divider()
                        .background(Color.yoloBorder)
                        .padding(.leading, 52)
                }
                memberRow(member: member)
            }
        }
        .yoloCard(padding: 0)
    }

    private func memberRow(member: Member) -> some View {
        HStack(spacing: YoloSpacing.sm) {
            AvatarView(member: member, size: 28)

            Text(member.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.white)

            Spacer()

            if viewModel.isCalculating {
                SkeletonCapsule()
            } else if let minutes = viewModel.travelMinutes(for: member) {
                TravelBadge(minutes: minutes, color: viewModel.timeColor(minutes: minutes))
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
                Text("87%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.yoloGold)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.yoloBorder)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color.yoloGold.opacity(0.7), Color.yoloGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * 0.87)
                }
            }
            .frame(height: 6)

            Text("travel times are well balanced — no one gets stuck with a long ride")
                .font(.system(size: 11))
                .foregroundStyle(Color.yoloTextSecondary)
        }
        .yoloCard()
    }

    // MARK: - Confirm Button

    private var confirmButton: some View {
        Button {
            onConfirm()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                Text("confirm this spot")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(Color.black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: [Color.yoloGoldLight, Color.yoloGold],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
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
                .frame(width: 32, height: 32)
                .shadow(color: member.avatarColor.opacity(0.5), radius: 6, y: 2)
            Text(String(member.name.prefix(1)).uppercased())
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.black)
        }
    }
}

private struct MeetupPin: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.8))
                .frame(width: 36, height: 36)
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
            .frame(width: 56, height: 22)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.white.opacity(0.06), Color.clear],
                            startPoint: UnitPoint(x: phase - 0.3, y: 0.5),
                            endPoint: UnitPoint(x: phase + 0.3, y: 0.5)
                        )
                    )
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
