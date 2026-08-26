import SwiftUI

struct PhoneAuthView: View {
    @State private var phoneNumber = ""
    @State private var navigateToProfile = false
    @FocusState private var fieldFocused: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: YoloSpacing.sm) {
                    Text("what's your number?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.white)

                    Text("we'll text you a code. no passwords, ever.")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.yoloTextSecondary)
                }
                .padding(.top, 72)
                .padding(.horizontal, YoloSpacing.lg)

                Spacer()

                VStack(spacing: YoloSpacing.md) {
                    PhoneField(number: $phoneNumber)
                        .focused($fieldFocused)

                    YoloButton(
                        title: "continue →",
                        style: phoneNumber.count >= 10 ? .primary : .ghost
                    ) {
                        navigateToProfile = true
                    }
                    .disabled(phoneNumber.count < 10)
                }
                .padding(.horizontal, YoloSpacing.lg)
                .padding(.bottom, 48)
            }
        }
        .hideNavigationBar()
        .onAppear { fieldFocused = true }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileSetupView()
        }
    }
}

private struct PhoneField: View {
    @Binding var number: String

    var body: some View {
        HStack(spacing: YoloSpacing.sm) {
            Text("+1")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.leading, YoloSpacing.md)

            Rectangle()
                .fill(Color.yoloBorder)
                .frame(width: 1, height: 24)

            TextField("", text: $number, prompt: Text("000 000 0000").foregroundStyle(Color.yoloTextTertiary))
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
                .keyboardType(.phonePad)
                .padding(.trailing, YoloSpacing.md)
        }
        .frame(height: 58)
        .background(Color.yoloSurface)
        .clipShape(RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous)
                .strokeBorder(Color.yoloBorderGold, lineWidth: 1)
        )
    }
}
