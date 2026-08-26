import SwiftUI

struct PhoneAuthView: View {
    @State private var phoneNumber = ""
    @State private var showOTP = false
    @State private var otpCode = ""
    @State private var navigateToProfile = false
    @FocusState private var fieldFocused: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: YoloSpacing.sm) {
                    Text(showOTP ? "check your texts." : "what's your number?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.white)

                    Text(showOTP
                         ? "we sent a code to +1 \(phoneNumber)"
                         : "we'll text you a code. no passwords, ever."
                    )
                    .font(.system(size: 15))
                    .foregroundStyle(Color.yoloTextSecondary)
                }
                .padding(.top, 72)
                .padding(.horizontal, YoloSpacing.lg)

                Spacer()

                VStack(spacing: YoloSpacing.md) {
                    if showOTP {
                        OTPField(code: $otpCode)
                            .focused($fieldFocused)
                    } else {
                        PhoneField(number: $phoneNumber)
                            .focused($fieldFocused)
                    }

                    YoloButton(
                        title: showOTP ? "verify →" : "send code →",
                        style: (showOTP ? otpCode.count == 6 : phoneNumber.count >= 10) ? .primary : .ghost
                    ) {
                        if showOTP {
                            navigateToProfile = true
                        } else {
                            withAnimation(YoloSpring.smooth) {
                                showOTP = true
                                fieldFocused = true
                            }
                        }
                    }
                    .disabled(showOTP ? otpCode.count < 6 : phoneNumber.count < 10)

                    if showOTP {
                        Button("resend code") {}
                            .font(.system(size: 14))
                            .foregroundStyle(Color.yoloTextTertiary)
                    }
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

private struct OTPField: View {
    @Binding var code: String

    var body: some View {
        HStack(spacing: YoloSpacing.sm) {
            ForEach(0..<6, id: \.self) { i in
                let char: String = i < code.count ? String(code[code.index(code.startIndex, offsetBy: i)]) : ""
                ZStack {
                    RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous)
                        .fill(Color.yoloSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: YoloRadius.md, style: .continuous)
                                .strokeBorder(i < code.count ? Color.yoloGold.opacity(0.5) : Color.yoloBorder, lineWidth: 1)
                        )
                    Text(char)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.white)
                }
                .frame(height: 58)
            }
        }
        .overlay(
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .opacity(0.001)
                .onChange(of: code) { _, new in
                    if new.count > 6 { code = String(new.prefix(6)) }
                }
        )
    }
}
