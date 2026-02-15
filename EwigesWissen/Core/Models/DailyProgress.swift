import Foundation
import SwiftData

@Model
final class DailyProgress {
    var date: Date
    var quizzesCompleted: Int
    var correctAnswers: Int
    var totalQuestions: Int
    var starsEarned: Int
    var timeSpent: TimeInterval

    var user: User?

    init(date: Date = .now) {
        self.date = Calendar.current.startOfDay(for: date)
        self.quizzesCompleted = 0
        self.correctAnswers = 0
        self.totalQuestions = 0
        self.starsEarned = 0
        self.timeSpent = 0
    }

    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }

    var dateString: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
