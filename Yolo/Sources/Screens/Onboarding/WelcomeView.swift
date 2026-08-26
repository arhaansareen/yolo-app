import SwiftUI

struct WelcomeView: View {
    @State private var currentPage = 0
    @State private var navigateToAuth = false

    private let slides: [String] = [
        "the gc talks big. yolo makes it real.",
        "everyone votes. ai picks. you show up.",
        "no more chasing people for e-transfers.",
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    TabView(selection: $currentPage) {
                        ForEach(Array(slides.enumerated()), id: \.offset) { idx, slide in
                            SlideCard(text: slide)
                                .tag(idx)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 320)

                    Spacer()

                    VStack(spacing: YoloSpacing.lg) {
                        HStack(spacing: 6) {
                            ForEach(0..<slides.count, id: \.self) { i in
                                if i == currentPage {
                                    Capsule()
                                        .fill(Color.yoloGold)
                                        .frame(width: 18, height: 8)
                                        .animation(YoloSpring.snappy, value: currentPage)
                                } else {
                                    Circle()
                                        .fill(Color.yoloTextTertiary)
                                        .frame(width: 6, height: 6)
                                        .animation(YoloSpring.snappy, value: currentPage)
                                }
                            }
                        }

                        VStack(spacing: YoloSpacing.sm) {
                            YoloButton(title: "let's go →", style: .primary) {
                                navigateToAuth = true
                            }

                            Button("already have an account") {
                                navigateToAuth = true
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Color.yoloTextTertiary)
                        }
                    }
                    .padding(.horizontal, YoloSpacing.lg)
                    .padding(.bottom, 48)
                }
            }
            .hideNavigationBar()
            .navigationDestination(isPresented: $navigateToAuth) {
                PhoneAuthView()
            }
        }
    }
}

private struct SlideCard: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.md) {
            Text(text)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color.white)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, YoloSpacing.xl)
    }
}

#Preview {
    WelcomeView()
        .environment(AppState())
}
