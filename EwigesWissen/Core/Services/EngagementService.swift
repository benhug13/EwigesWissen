import Foundation
import SwiftData

@Observable
final class EngagementService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Stars

    func starsForAttempt(_ attemptNumber: Int) -> Int {
        switch attemptNumber {
        case 1: return 3
        case 2: return 2
        default: return 1
        }
    }

    // MARK: - Streaks

    func updateStreak(for user: User) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastActive = user.lastActiveDate {
            let lastActiveDay = calendar.startOfDay(for: lastActive)
            let daysBetween = calendar.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0

            if daysBetween == 1 {
                user.currentStreak += 1
            } else if daysBetween > 1 {
                user.currentStreak = 1
            }
            // daysBetween == 0: same day, no change
        } else {
            user.currentStreak = 1
        }

        user.longestStreak = max(user.longestStreak, user.currentStreak)
        user.lastActiveDate = Date()
    }

    // MARK: - Daily Progress

    func todayProgress(for user: User) -> DailyProgress {
        let today = Calendar.current.startOfDay(for: Date())

        if let existing = user.dailyProgress.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            return existing
        }

        let progress = DailyProgress(date: today)
        progress.user = user
        user.dailyProgress.append(progress)
        return progress
    }

    // MARK: - Record Quiz

    func recordQuizCompletion(
        session: QuizSession,
        user: User
    ) {
        session.user = user
        user.quizSessions.append(session)
        user.totalStars += session.totalStarsEarned

        let progress = todayProgress(for: user)
        progress.quizzesCompleted += 1
        progress.correctAnswers += session.correctAnswers
        progress.totalQuestions += session.totalQuestions
        progress.starsEarned += session.totalStarsEarned

        updateStreak(for: user)
        checkAchievements(for: user)

        try? modelContext.save()
    }

    // MARK: - Achievements

    func checkAchievements(for user: User) {
        let unlockedTypes = Set(user.achievements.map(\.typeRawValue))

        let checks: [(AchievementType, Bool)] = [
            (.firstQuiz, user.quizSessions.count >= 1),
            (.tenQuizzes, user.quizSessions.count >= 10),
            (.fiftyQuizzes, user.quizSessions.count >= 50),
            (.hundredQuizzes, user.quizSessions.count >= 100),
            (.threeDayStreak, user.longestStreak >= 3),
            (.sevenDayStreak, user.longestStreak >= 7),
            (.thirtyDayStreak, user.longestStreak >= 30),
            (.perfectQuiz, user.quizSessions.contains { $0.correctAnswers == $0.totalQuestions && $0.totalQuestions > 0 }),
            (.fivePerfectQuizzes, user.quizSessions.filter { $0.correctAnswers == $0.totalQuestions && $0.totalQuestions > 0 }.count >= 5),
            (.tenPerfectQuizzes, user.quizSessions.filter { $0.correctAnswers == $0.totalQuestions && $0.totalQuestions > 0 }.count >= 10),
            (.hundredStars, user.totalStars >= 100),
        ]

        for (type, condition) in checks {
            if condition && !unlockedTypes.contains(type.rawValue) {
                let achievement = Achievement(type: type)
                achievement.user = user
                user.achievements.append(achievement)
            }
        }
    }
}
