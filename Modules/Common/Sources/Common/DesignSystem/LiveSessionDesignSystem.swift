import SwiftUI

public struct DSSpacing {
    public static let none: CGFloat = 0
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xl2: CGFloat = 48
}

public struct DSRadius {
    public static let sm: CGFloat = 4
    public static let md: CGFloat = 8
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let circular: CGFloat = 9999
}

public struct DSElevation {
    public static let sm: CGFloat = 2
    public static let md: CGFloat = 4
    public static let lg: CGFloat = 8
    public static let level2: CGFloat = 4
}

public enum DSTypography {
    case headlineSmall
    case headlineMedium
    case labelMedium
    case labelSmall
    case bodySmall
    case bodyMedium
    
    public var font: Font {
        switch self {
        case .headlineSmall: return .headline
        case .headlineMedium: return .title3
        case .labelMedium: return .subheadline
        case .labelSmall: return .caption2
        case .bodySmall: return .caption
        case .bodyMedium: return .body
        }
    }
}

public struct DSColors {
    public let background = Color.black
    public let textPrimary = Color.white
    public let textSecondary = Color.gray
    public let success = Color.green
    public let warning = Color.orange
    public let error = Color.red
    public let onPrimary = Color.white
    public let surface = Color(white: 0.15)
    public let onSurface = Color.white
    public let surfaceVariant = Color(white: 0.25)
    public let surfaceContainerLow = Color(white: 0.2)
    public let primary = Color.App.primary
    public let primaryContainer = Color.App.primary.opacity(0.15)
    public init() {}
}

public struct DSColorsKey: EnvironmentKey {
    public static let defaultValue = DSColors()
}

public extension EnvironmentValues {
    var dsColors: DSColors {
        get { self[DSColorsKey.self] }
        set { self[DSColorsKey.self] = newValue }
    }
}

public extension View {
    func dsTheme() -> some View {
        self.environment(\.dsColors, DSColors())
    }
    
    func dsFont(_ typography: DSTypography) -> some View {
        self.font(typography.font)
    }
    
    func dsElevation(_ elevation: CGFloat) -> some View {
        self.shadow(color: Color.black.opacity(0.15), radius: elevation, x: 0, y: elevation / 2)
    }
}
