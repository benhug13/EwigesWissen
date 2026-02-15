import SwiftUI

enum AppColors {
    // MARK: - Primary
    static let primary = Color.indigo
    static let primaryLight = Color.indigo.opacity(0.15)

    // MARK: - Secondary
    static let secondary = Color.purple
    static let secondaryLight = Color.purple.opacity(0.15)

    // MARK: - Accent
    static let accent = Color.cyan
    static let accentLight = Color.cyan.opacity(0.15)

    // MARK: - Semantic
    static let success = Color.green
    static let error = Color.red
    static let warning = Color.orange

    // MARK: - Background
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)

    // MARK: - Text
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    // MARK: - Cards
    static let cardBackground = Color(.secondarySystemBackground)
    static let cardBorder = Color(.separator)

    // MARK: - Stars
    static let starFilled = Color.yellow
    static let starEmpty = Color(.tertiaryLabel)

    // MARK: - Geography Types
    static func geographyColor(for type: GeographyType) -> Color {
        switch type {
        case .mountain: return .brown
        case .river: return .blue
        case .sea: return .cyan
        case .lake: return .teal
        case .island: return .green
        case .strait: return .indigo
        case .peninsula: return .orange
        case .cape: return .purple
        }
    }
}
