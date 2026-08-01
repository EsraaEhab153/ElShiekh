import SwiftUI

public extension Color {
    enum App {
        /// Dark green color used for primary elements and text (#164F3E)
        public static let primary = Color(hex: "164F3E")
        
        /// Light green background for selected states (#D6E7DC)
        public static let primaryLight = Color(hex: "D6E7DC")
        
        /// Gray color used for unselected icons and text (#84938B)
        public static let grayText = Color(hex: "84938B")
        
        /// Background color for the tab bar and general backgrounds
        public static let background = Color.white
        
        /// Background color for cards
        public static let cardBackground = Color(hex: "E8EDE9")
    }
}

// Helper to initialize Color from hex
public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
