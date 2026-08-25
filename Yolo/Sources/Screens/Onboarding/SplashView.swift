import SwiftUI

struct SplashView: View {
    @Environment(AppState.self) private var appState
    @State private var logoOpacity: Double = 0
    @State private var logoScale: Double = 0.85
    @State private var glowOpacity: Double = 0
    @State private var navigateToWelcome = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                RadialGradient(
                    colors: [Color.yoloGold.opacity(0.08), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 280
                )
                .ignoresSafeArea()
                .opacity(glowOpacity)

                Text("yolo.")
                    .font(.system(size: 52, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.yoloGoldLight, Color.yoloGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)
            }
            .navigationDestination(isPresented: $navigateToWelcome) {
                WelcomeView()
            }
        }
        .onAppear {
            withAnimation(YoloSpring.slow.delay(0.2)) {
                logoOpacity = 1
                logoScale = 1
            }
            withAnimation(.easeInOut(duration: 1.2).delay(0.4)) {
                glowOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                navigateToWelcome = true
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(AppState())
}
