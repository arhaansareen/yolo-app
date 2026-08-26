import SwiftUI

struct Member: Identifiable, Hashable, Equatable {
    let id: UUID
    var name: String
    var colorHex: String
    var showUpRate: Double
    var flakeCount: Int
    var title: MemberTitle
    var dietaryTags: [DietaryTag] = []

    var avatarColor: Color { Color(hex: colorHex) }

    enum MemberTitle: String {
        case anchor = "the anchor"
        case wildcard = "the wildcard"
        case ghost = "the ghost"
        case hypeman = "the hypeman"
        case planner = "the planner"
        case surpriseGuest = "the surprise guest"
    }

    enum DietaryTag: String, CaseIterable, Codable, Hashable {
        case vegetarian = "vegetarian"
        case vegan = "vegan"
        case halalOnly = "halal only"
        case kosher = "kosher"
        case glutenFree = "gluten free"
        case dairyFree = "dairy free"
        case nutAllergy = "nut allergy"
        case pescatarian = "pescatarian"

        var icon: String {
            switch self {
            case .vegetarian, .vegan: return "leaf.fill"
            case .halalOnly, .kosher: return "moon.stars.fill"
            case .glutenFree: return "allergens"
            case .dairyFree: return "drop.fill"
            case .nutAllergy: return "exclamationmark.triangle.fill"
            case .pescatarian: return "fish.fill"
            }
        }
    }
}

struct YoloGroup: Identifiable, Hashable {
    let id: UUID
    var name: String
    var members: [Member]
    var status: GroupStatus
    var lastActivityText: String
    var linkCount: Int
    var currentPlan: Plan?
    var vibe: GroupVibe

    enum GroupStatus {
        case planning, lockedIn, happened, dead, idle

        var label: String {
            switch self {
            case .planning: return "planning"
            case .lockedIn: return "locked in"
            case .happened: return "happened"
            case .dead: return "dead"
            case .idle: return "idle"
            }
        }

        var color: Color {
            switch self {
            case .planning: return .yoloAmber
            case .lockedIn: return .yoloGreen
            case .happened: return .yoloTextSecondary
            case .dead: return .yoloRed
            case .idle: return .yoloBorder
            }
        }

    }

    enum GroupVibe: String, CaseIterable {
        case goOut = "we go out"
        case outdoorsy = "outdoorsy"
        case homebody = "homebody types"
        case chaotic = "chaotic mix"
    }
}

struct Plan: Identifiable, Hashable {
    let id: UUID
    var activityType: ActivityType
    var timeframe: String
    var venue: Venue?
    var date: Date?
    var responses: [PlanResponse]
    var status: PlanStatus
    var aiSuggestions: [AISuggestion]

    enum PlanStatus {
        case surveying, waiting, suggesting, polling, locked
    }
}

enum ActivityType: String, CaseIterable, Identifiable {
    case food = "food"
    case activity = "activity"
    case goingOut = "going out"
    case movie = "movie"
    case trip = "trip"
    case surprise = "surprise me"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food:      return "fork.knife"
        case .activity:  return "figure.bowling"
        case .goingOut:  return "wineglass"
        case .movie:     return "film"
        case .trip:      return "car.fill"
        case .surprise:  return "sparkles"
        }
    }
}

struct PlanResponse: Identifiable, Hashable {
    let id: UUID
    let memberId: UUID
    var preferences: [ActivityType]
    var budgetTier: BudgetTier
    var availableDays: Set<Int>
    var effortLevel: EffortLevel

    enum BudgetTier: String, CaseIterable {
        case free = "$0–20"
        case low = "$20–50"
        case mid = "$50–100"
        case high = "$100+"
    }

    enum EffortLevel: String, CaseIterable {
        case low = "low"
        case medium = "medium"
        case high = "high"

        var icon: String {
            switch self {
            case .low:    return "tortoise.fill"
            case .medium: return "figure.walk"
            case .high:   return "flame.fill"
            }
        }
    }
}

struct Venue: Identifiable, Hashable {
    let id: UUID
    var name: String
    var category: String
    var address: String
    var rating: Double
    var priceLevel: Int
    var fairnessScore: Double
    var travelTimes: [String: Int]
    var photoColor: String
}

struct AISuggestion: Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var why: String
    var estimatedCostPerPerson: String
    var vibes: [String]
    var venue: Venue?
}

extension Member {
    static let mockMembers: [Member] = [
        Member(id: UUID(), name: "arh", colorHex: "C9A84C", showUpRate: 0.92, flakeCount: 1, title: .anchor, dietaryTags: []),
        Member(id: UUID(), name: "jade", colorHex: "7B68EE", showUpRate: 0.78, flakeCount: 3, title: .wildcard, dietaryTags: [.vegetarian]),
        Member(id: UUID(), name: "ko", colorHex: "20B2AA", showUpRate: 0.45, flakeCount: 8, title: .ghost, dietaryTags: []),
        Member(id: UUID(), name: "priya", colorHex: "FF6B9D", showUpRate: 0.98, flakeCount: 0, title: .hypeman, dietaryTags: [.halalOnly]),
        Member(id: UUID(), name: "dez", colorHex: "FF8C42", showUpRate: 0.65, flakeCount: 4, title: .surpriseGuest, dietaryTags: [.glutenFree]),
    ]
}

extension YoloGroup {
    static let mockData: [YoloGroup] = [
        YoloGroup(
            id: UUID(),
            name: "the usual suspects",
            members: Member.mockMembers,
            status: .planning,
            lastActivityText: "arh wants to plan something",
            linkCount: 14,
            currentPlan: nil,
            vibe: .goOut
        ),
        YoloGroup(
            id: UUID(),
            name: "cottage crew",
            members: Array(Member.mockMembers.prefix(3)),
            status: .lockedIn,
            lastActivityText: "locked in for saturday",
            linkCount: 6,
            currentPlan: nil,
            vibe: .outdoorsy
        ),
        YoloGroup(
            id: UUID(),
            name: "film club",
            members: Array(Member.mockMembers.suffix(3)),
            status: .idle,
            lastActivityText: "last linked 3 weeks ago",
            linkCount: 22,
            currentPlan: nil,
            vibe: .homebody
        ),
    ]
}
