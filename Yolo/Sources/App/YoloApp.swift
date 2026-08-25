import SwiftUI

@main
struct YoloApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.isOnboardingComplete {
                HomeView()
            } else {
                SplashView()
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: appState.isOnboardingComplete)
    }
}
