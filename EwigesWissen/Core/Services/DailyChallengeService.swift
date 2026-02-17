import Foundation
import SwiftData

struct DailyChallenge {
    let title: String
    let description: String
    let icon: String
    let target: Int
    let current: Int

    var isCompleted: Bool { current >= target }
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(1.0, Double(current) / Double(target))
    }
}

struct DailyChallengeService {
    let modelContext: ModelContext

    func todayChallenge(for user: User?) -> DailyChallenge {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let challengeIndex = dayOfYear % 5

        let todaySessions = user?.quizSessions.filter {
            Calendar.current.isDateInToday($0.startedAt)
        } ?? []

        let todayCorrect = todaySessions.reduce(0) { $0 + $1.correctAnswers }
        let todayStars = todaySessions.reduce(0) { $0 + $1.totalStarsEarned }
        let todayQuizCount = todaySessions.count
        let todayPerfect = todaySessions.filter { $0.correctAnswers == $0.totalQuestions && $0.totalQuestions > 0 }.count

        switch challengeIndex {
        case 0:
            return DailyChallenge(
                title: "Quiz-Marathon",
                description: "Schliesse 3 Quizzes ab",
                icon: "flame.fill",
                target: 3,
                current: todayQuizCount
            )
        case 1:
            return DailyChallenge(
                title: "Wissenssammler",
                description: "Beantworte 15 Fragen richtig",
                icon: "checkmark.circle.fill",
                target: 15,
                current: todayCorrect
            )
        case 2:
            return DailyChallenge(
                title: "Sternenjäger",
                description: "Sammle 10 Sterne",
                icon: "star.fill",
                target: 10,
                current: todayStars
            )
        case 3:
            return DailyChallenge(
                title: "Perfektionist",
                description: "Schliesse 1 Quiz ohne Fehler ab",
                icon: "checkmark.seal.fill",
                target: 1,
                current: todayPerfect
            )
        default:
            return DailyChallenge(
                title: "Fleissig",
                description: "Schliesse 2 Quizzes ab",
                icon: "bolt.fill",
                target: 2,
                current: todayQuizCount
            )
        }
    }
}
