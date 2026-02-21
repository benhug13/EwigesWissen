import Foundation
import SwiftData

enum QuizType: String, Codable {
    case capitalCountryToCapital = "Land → Hauptstadt"
    case capitalCapitalToCountry = "Hauptstadt → Land"
    case geographyPinPlacement = "Geografie-Quiz"
    case combinedTest = "Probeprüfung"
}

@Model
final class QuizSession {
    var quizType: String // QuizType rawValue
    var schoolLevel: String // SchoolLevel rawValue
    var totalQuestions: Int
    var correctAnswers: Int
    var totalStarsEarned: Int
    var startedAt: Date
    var completedAt: Date?
    var resultsData: Data? // Encoded [QuizResult]

    var user: User?

    init(
        quizType: QuizType,
        schoolLevel: SchoolLevel,
        totalQuestions: Int = 0
    ) {
        self.quizType = quizType.rawValue
        self.schoolLevel = schoolLevel.rawValue
        self.totalQuestions = totalQuestions
        self.correctAnswers = 0
        self.totalStarsEarned = 0
        self.startedAt = Date()
        self.completedAt = nil
        self.resultsData = nil
    }

    var type: QuizType {
        QuizType(rawValue: quizType) ?? .capitalCountryToCapital
    }

    var results: [QuizResult] {
        get {
            guard let data = resultsData else { return [] }
            do {
                return try JSONDecoder().decode([QuizResult].self, from: data)
            } catch {
                print("⚠️ Failed to decode QuizResults: \(error)")
                return []
            }
        }
        set {
            do {
                resultsData = try JSONEncoder().encode(newValue)
            } catch {
                print("⚠️ Failed to encode QuizResults: \(error)")
            }
        }
    }

    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
}
