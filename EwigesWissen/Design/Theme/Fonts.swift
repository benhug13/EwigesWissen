import SwiftUI

enum AppFonts {
    // MARK: - Titles
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title = Font.system(.title, design: .rounded, weight: .bold)
    static let title2 = Font.system(.title2, design: .rounded, weight: .semibold)
    static let title3 = Font.system(.title3, design: .rounded, weight: .semibold)

    // MARK: - Body
    static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let body = Font.system(.body, design: .rounded)
    static let callout = Font.system(.callout, design: .rounded)
    static let subheadline = Font.system(.subheadline, design: .rounded)
    static let footnote = Font.system(.footnote, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)

    // MARK: - Quiz
    static let quizQuestion = Font.system(.title2, design: .rounded, weight: .bold)
    static let quizAnswer = Font.system(.title3, design: .rounded, weight: .medium)
    static let quizInput = Font.system(.title3, design: .rounded)

    // MARK: - Stats
    static let statNumber = Font.system(size: 36, weight: .bold, design: .rounded)
    static let statLabel = Font.system(.caption, design: .rounded, weight: .medium)
}
