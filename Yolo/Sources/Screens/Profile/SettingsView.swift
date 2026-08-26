import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // Notification toggles
    @State private var notifyPlanLocked = true
    @State private var notifyNewVote = true
    @State private var notifyNudges = true
    @State private var notifyHypeCountdown = false

    // Calendar
    @State private var calendarConnected = false

    // Location
    @State private var locationEnabled = false

    // Sign-out alert
    @State private var showSignOutAlert = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: YoloSpacing.lg) {
                        notificationsSection
                        calendarSection
                        locationSection
                        accountSection
                        aboutSection
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .padding(.top, YoloSpacing.md)
                }
            }
        }
        .alert("sign out?", isPresented: $showSignOutAlert) {
            Button("sign out", role: .destructive) {}
            Button("cancel", role: .cancel) {}
        } message: {
            Text("you'll need to sign back in to access your groups.")
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.yoloTextSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.yoloSurface2)
                    .clipShape(Circle())
            }
            Spacer()
            Text("settings")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Color.clear.frame(width: 36)
        }
        .padding(.horizontal, YoloSpacing.md)
        .padding(.top, 60)
        .padding(.bottom, YoloSpacing.md)
    }

    // MARK: - Sections

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "notifications")
            VStack(spacing: 0) {
                toggleRow(
                    icon: "lock.fill",
                    iconColor: .yoloGold,
                    label: "plan locked",
                    subtitle: "someone confirmed a plan",
                    isOn: $notifyPlanLocked
                )
                rowDivider
                toggleRow(
                    icon: "checklist",
                    iconColor: .yoloAmber,
                    label: "new vote",
                    subtitle: "poll is open",
                    isOn: $notifyNewVote
                )
                rowDivider
                toggleRow(
                    icon: "hand.tap.fill",
                    iconColor: .yoloGold,
                    label: "nudges",
                    subtitle: "when someone pokes you",
                    isOn: $notifyNudges
                )
                rowDivider
                toggleRow(
                    icon: "timer",
                    iconColor: .yoloAmber,
                    label: "hype countdown",
                    subtitle: "1 hour before the plan",
                    isOn: $notifyHypeCountdown
                )
            }
            .yoloCard(padding: 0)
        }
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "calendar")
            HStack(spacing: YoloSpacing.md) {
                ZStack {
                    Circle().fill(Color.yoloGold.opacity(0.12)).frame(width: 40, height: 40)
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.yoloGold)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("sync your calendar")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white)
                    Text("we'll auto-fill the availability heatmap")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.yoloTextSecondary)
                }
                Spacer()
                if calendarConnected {
                    connectedPill
                } else {
                    Button {
                        withAnimation(YoloSpring.snappy) { calendarConnected = true }
                    } label: {
                        Text("connect")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.yoloGold)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(GoldPressButtonStyle())
                }
            }
            .padding(.horizontal, YoloSpacing.md)
            .frame(minHeight: 64)
            .yoloCard(padding: 0)
            .padding(.vertical, YoloSpacing.xs)
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "location")
            VStack(spacing: 0) {
                HStack(spacing: YoloSpacing.sm) {
                    Image(systemName: "location.fill")
                        .foregroundStyle(Color.yoloGreen)
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("share location during plans")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white)
                        Text("only shared when a plan is active")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.yoloTextSecondary)
                    }
                    Spacer()
                    Toggle("", isOn: $locationEnabled)
                        .tint(Color.yoloGold)
                        .labelsHidden()
                }
                .padding(.horizontal, YoloSpacing.md)
                .frame(minHeight: 64)
            }
            .yoloCard(padding: 0)
        }
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "account")
            VStack(spacing: 0) {
                // Phone number
                HStack(spacing: YoloSpacing.sm) {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(Color.yoloGreen)
                        .frame(width: 22)
                    Text("phone number")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Text("+1 **** **** **44")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.yoloTextSecondary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.yoloTextTertiary)
                }
                .padding(.horizontal, YoloSpacing.md)
                .frame(height: 52)

                rowDivider

                // Connected accounts
                HStack(spacing: YoloSpacing.sm) {
                    Image(systemName: "apple.logo")
                        .foregroundStyle(Color.white)
                        .frame(width: 22)
                    Text("connected accounts")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.white)
                    Spacer()
                    connectedPill
                }
                .padding(.horizontal, YoloSpacing.md)
                .frame(height: 52)

                rowDivider

                // Sign out
                Button {
                    showSignOutAlert = true
                } label: {
                    HStack(spacing: YoloSpacing.sm) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(Color.yoloRed)
                            .frame(width: 22)
                        Text("sign out")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.yoloRed)
                        Spacer()
                    }
                    .padding(.horizontal, YoloSpacing.md)
                    .frame(height: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressEffectButtonStyle())
            }
            .yoloCard(padding: 0)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: YoloSpacing.sm) {
            SectionHeader(title: "about")
            VStack(spacing: 0) {
                // Version
                HStack(spacing: YoloSpacing.sm) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color.yoloTextTertiary)
                        .frame(width: 22)
                    Text("version")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Text("1.0.0 (1)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.yoloTextSecondary)
                }
                .padding(.horizontal, YoloSpacing.md)
                .frame(height: 52)

                rowDivider

                // Privacy policy
                HStack(spacing: YoloSpacing.sm) {
                    Image(systemName: "hand.raised.fill")
                        .foregroundStyle(Color.yoloTextTertiary)
                        .frame(width: 22)
                    Text("privacy policy")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.yoloTextTertiary)
                }
                .padding(.horizontal, YoloSpacing.md)
                .frame(height: 52)

                rowDivider

                // Terms
                HStack(spacing: YoloSpacing.sm) {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(Color.yoloTextTertiary)
                        .frame(width: 22)
                    Text("terms")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.yoloTextTertiary)
                }
                .padding(.horizontal, YoloSpacing.md)
                .frame(height: 52)
            }
            .yoloCard(padding: 0)
        }
    }

    // MARK: - Helpers

    private var rowDivider: some View {
        Divider()
            .background(Color.yoloBorder)
            .padding(.leading, 52)
    }

    private var connectedPill: some View {
        Text("connected")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.yoloGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.yoloGreen.opacity(0.12))
            .clipShape(Capsule())
    }

    private func toggleRow(icon: String, iconColor: Color, label: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: YoloSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.yoloTextSecondary)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .tint(Color.yoloGold)
                .labelsHidden()
        }
        .padding(.horizontal, YoloSpacing.md)
        .frame(minHeight: 52)
    }
}

#Preview {
    SettingsView()
}
