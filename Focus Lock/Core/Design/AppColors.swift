import SwiftUI

extension Color {
    static let flBackground = Color(red: 0.047, green: 0.082, blue: 0.063)
    static let flSurface    = Color(red: 0.078, green: 0.125, blue: 0.098)
    static let flPrimary    = Color(red: 0.114, green: 0.722, blue: 0.478)
    static let flPrimaryEnd = Color(red: 0.055, green: 0.620, blue: 0.388)
    static let flSubtext    = Color.white.opacity(0.5)
}

extension LinearGradient {
    static var flPrimary: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.114, green: 0.722, blue: 0.478),
                     Color(red: 0.055, green: 0.620, blue: 0.388)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Font {
    static func instrumentSerif(size: CGFloat, italic: Bool = false) -> Font {
        .custom(italic ? "InstrumentSerif-Italic" : "InstrumentSerif-Regular", size: size)
    }

    static func manrope(_ weight: ManropeWeight = .regular, size: CGFloat) -> Font {
        .custom(weight.fontName, size: size)
    }

    enum ManropeWeight {
        case extraLight, light, regular, medium, semiBold, bold, extraBold
        var fontName: String {
            switch self {
            case .extraLight: return "Manrope-ExtraLight"
            case .light:      return "Manrope-Light"
            case .regular:    return "Manrope-Regular"
            case .medium:     return "Manrope-Medium"
            case .semiBold:   return "Manrope-SemiBold"
            case .bold:       return "Manrope-Bold"
            case .extraBold:  return "Manrope-ExtraBold"
            }
        }
    }
}
