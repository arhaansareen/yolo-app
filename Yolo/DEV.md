# DEV.md

Developer guide for the Yolo iOS project.

## Build & Run

```bash
# Regenerate Xcode project after editing project.yml
cd ~/yolo_app/Yolo && xcodegen generate

# Type-check Swift files against iOS SDK (no simulator required)
swiftc -typecheck -sdk $(xcrun --show-sdk-path --sdk iphonesimulator) \
  -target arm64-apple-ios17.0-simulator Sources/**/*.swift

# Open in Xcode
open ~/yolo_app/Yolo/Yolo.xcodeproj
```

After any structural changes (new files, new targets), re-run `xcodegen generate` — the `.xcodeproj` is generated and not committed.

## Architecture

**State:** Single `@Observable` `AppState` class injected via `.environment(appState)` at the root. All views read it with `@Environment(AppState.self)`. No `ObservableObject`, no `@StateObject`.

**Navigation:** `NavigationStack` at `HomeView`. Group detail uses `navigationDestination(item:)`. Planning flow uses `fullScreenCover` stacked screen-by-screen (KickOff → Survey → WaitingRoom → AISuggestion → FinalPoll → PlanLocked). No router or coordinator — each screen owns its own `@State private var navigate = false` flag.

**Design system** lives in `Sources/Design/`:
- `Theme.swift` — `Color` extensions (`yoloGold`, `yoloSurface`, etc.), `YoloSpring` animation presets, `YoloRadius`/`YoloSpacing` constants, and two view modifiers: `.yoloCard()` and `.yoloGoldCard()`
- `Extensions.swift` — `PressEffectButtonStyle` and `GoldPressButtonStyle` for all button press feedback

**Components** in `Sources/Components/`:
- `AvatarView` / `StackedAvatars` / `MemberResponseDot` — member avatar rendering
- `YoloButton` — primary/secondary/ghost/destructive variants
- `StatusPill` / `ActivityPill` — group status and activity type tags

**Models** in `Sources/Models/Models.swift` — all structs with mock data as static extensions. No persistence yet; everything is in-memory.

## Platform Constraints

This is a SwiftUI app targeting iOS 17+. Never use hardcoded colors or custom web-like shadows; strictly rely on Apple HIG semantic colors and native materials.

## Key Conventions

- All user-facing strings are lowercase by design (brand voice).
- `withAnimation` closures that call `Set.insert()` or `Set.remove()` must prefix with `_ =` — both return non-Void and Swift will error on type inference otherwise.
- Spring animations: use `YoloSpring.snappy` for selections, `YoloSpring.bouncy` for momentum/reveal, `YoloSpring.smooth` for navigation transitions.
- New screens added to the planning flow go between `AISuggestionView` and `PlanLockedView` and use `fullScreenCover`.
- iOS 17+ only. Use `@Observable`, not `ObservableObject`. Use `.spring(response:dampingFraction:)` not the deprecated `.interactiveSpring()`.
