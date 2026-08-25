import SwiftUI

struct ProfileSetupView: View {
    @Environment(AppState.self) private var appState
    @State private var name = ""
    @State private var city = ""
    @State private var selectedColorHex = "C9A84C"
    @FocusState private var nameFocused: Bool

    private let avatarColors = ["C9A84C", "7B68EE", "20B2AA", "FF6B9D", "FF8C42", "34C759", "FF453A", "00BFFF"]

    private var previewMember: Member {
        Member(id: UUID(), name: name.isEmpty ? "you" : name.lowercased(), colorHex: selectedColorHex, showUpRate: 1, flakeCount: 0, title: .anchor)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: YoloSpacing.xl) {
                    Text("set up your\nprofile.")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.white)
                        .padding(.top, 72)

                    AvatarView(member: previewMember, size: 80)
                        .frame(maxWidth: .infinity)
                        .animation(YoloSpring.bouncy, value: selectedColorHex)

                    HStack(spacing: YoloSpacing.sm) {
                        ForEach(avatarColors, id: \.self) { hex in
                            Button {
                                withAnimation(YoloSpring.bouncy) { selectedColorHex = hex }
                            } label: {
                                ZStack {
                                    Circle().fill(Color(hex: hex).opacity(0.2))
                                    Circle().strokeBorder(Color(hex: hex).opacity(0.6), lineWidth: 1.5)
                                    if selectedColorHex == hex {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundStyle(Color(hex: hex))
                                    }
                                }
                                .frame(width: 32, height: 32)
                                .scaleEffect(selectedColorHex == hex ? 1.15 : 1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: YoloSpacing.md) {
                        YoloTextField(placeholder: "your name (lowercase is fine)", text: $name)
                            .focused($nameFocused)

                        YoloTextField(placeholder: "your city", text: $city)
                    }

                    Text("your city helps us find spots that are fair for the whole group.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.yoloTextTertiary)
                }
                .padding(.horizontal, YoloSpacing.lg)
                .padding(.bottom, 120)
            }

            VStack {
                Spacer()
                YoloButton(title: "done →", style: name.count >= 2 ? .primary : .ghost) {
                    appState.completeOnboarding(name: name)
                }
                .disabled(name.count < 2)
                .padding(.horizontal, YoloSpacing.lg)
                .padding(.bottom, 48)
                .background(
                    LinearGradient(colors: [Color.black, Color.black.opacity(0)], startPoint: .bottom, endPoint: .top)
                        .frame(height: 120)
                        .ignoresSafeArea()
                    , alignment: .bottom
                )
            }
        }
        .hideNavigationBar()
        .onAppear { nameFocused = true }
    }
}

struct YoloTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.yoloTextTertiary))
            .font(.system(size: 16))
            .foregroundStyle(Color.white)
            .padding(YoloSpacing.md)
            .background(Color.yoloSurface)
            .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous)
                    .strokeBorder(text.isEmpty ? Color.yoloBorder : Color.yoloBorderGold, lineWidth: 1)
            )
    }
}
