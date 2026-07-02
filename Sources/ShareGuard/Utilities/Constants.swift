import SwiftUI

enum AppColors {
    static let volt = Color(hex: 0xC8FF00)
    static let background = Color(hex: 0x0A0A0A)
    static let surface = Color(hex: 0x141414)
    static let surfaceBorder = Color(hex: 0x222222)
    static let textPrimary = Color(hex: 0xF5F5F5)
    static let textSecondary = Color(hex: 0x888888)
    static let danger = Color(hex: 0xFF3B30)
    static let warning = Color(hex: 0xFF9500)
    static let info = Color(hex: 0x0A84FF)
    static let success = Color(hex: 0x30D158)
}

enum SeverityColor {
    static func color(for severity: Severity) -> Color {
        switch severity {
        case .critical: return AppColors.danger
        case .high: return AppColors.warning
        case .medium: return AppColors.volt
        case .low: return AppColors.info
        case .info: return AppColors.textSecondary
        }
    }
}

extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}
