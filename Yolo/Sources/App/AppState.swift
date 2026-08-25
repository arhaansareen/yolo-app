import SwiftUI
import Observation

@Observable
class AppState {
    var isOnboardingComplete: Bool = true
    var currentUser: Member = Member(
        id: UUID(),
        name: "arh",
        colorHex: "C9A84C",
        showUpRate: 0.92,
        flakeCount: 1,
        title: .anchor
    )
    var groups: [YoloGroup] = YoloGroup.mockData
    var selectedGroupId: UUID?

    var selectedGroup: YoloGroup? {
        guard let id = selectedGroupId else { return nil }
        return groups.first { $0.id == id }
    }

    func completeOnboarding(name: String) {
        currentUser.name = name.lowercased()
        isOnboardingComplete = true
    }

    func addGroup(_ group: YoloGroup) {
        groups.insert(group, at: 0)
    }

    func updateGroupStatus(_ groupId: UUID, status: YoloGroup.GroupStatus) {
        if let idx = groups.firstIndex(where: { $0.id == groupId }) {
            groups[idx].status = status
        }
    }
}
