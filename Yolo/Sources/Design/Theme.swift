import SwiftUI

extension Color {
    static let yoloGold       = Color(hex: "C9A84C")
    static let yoloGoldLight  = Color(hex: "E3C16A")
    static let yoloGoldDim    = Color(hex: "6B5520")
    static let yoloSurface    = Color(hex: "111111")
    static let yoloSurface2   = Color(hex: "1C1C1C")
    static let yoloBorder     = Color(hex: "2A2A2A")
    static let yoloBorderGold = Color(hex: "C9A84C").opacity(0.22)
    static let yoloTextSecondary = Color(hex: "8A8A8A")
    static let yoloTextTertiary  = Color(hex: "4A4A4A")
    static let yoloGreen  = Color(hex: "30D158")
    static let yoloAmber  = Color(hex: "FFD60A")
    static let yoloRed    = Color(hex: "FF453A")
    static let yoloTextPrimary = Color.white
    static let yoloBg          = Color.black

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

struct YoloSpring {
    static let snappy = Animation.spring(response: 0.28, dampingFraction: 0.82)
    static let smooth = Animation.spring(response: 0.42, dampingFraction: 0.9)
    static let bouncy = Animation.spring(response: 0.38, dampingFraction: 0.72)
    static let slow   = Animation.spring(response: 0.6,  dampingFraction: 0.88)
}

struct YoloRadius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 22
    static let pill: CGFloat = 100
}

struct YoloSpacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}

struct YoloShadow {
    static let gold = (color: Color.yoloGold.opacity(0.30), radius: CGFloat(14), y: CGFloat(5))
    static let card = (color: Color.black.opacity(0.4), radius: CGFloat(8), y: CGFloat(3))
}

struct YoloEasing {
    static let fade    = Animation.easeOut(duration: 0.22)
    static let shimmer = Animation.linear(duration: 1.2).repeatForever(autoreverses: false)
}

extension View {
    func yoloCard(padding: CGFloat = YoloSpacing.md, radius: CGFloat = YoloRadius.lg) -> some View {
        self
            .padding(padding)
            .background(Color.yoloSurface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.yoloBorder, lineWidth: 0.5)
            )
    }

    func yoloGoldCard(padding: CGFloat = YoloSpacing.md, radius: CGFloat = YoloRadius.lg) -> some View {
        self
            .padding(padding)
            .background(Color.yoloSurface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.yoloBorderGold, lineWidth: 1)
            )
    }

    func hideNavigationBar() -> some View {
        self
            .navigationBarBackButtonHidden(true)
            #if !os(macOS)
            .toolbarBackground(.hidden, for: .navigationBar)
            #endif
    }
}
