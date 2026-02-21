import Foundation
import SwiftData

@MainActor @Observable
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

    /// Returns true if the streak was continued (consecutive day)
    @discardableResult
    func updateStreak(for user: User) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streakContinued = false

        if let lastActive = user.lastActiveDate {
            let lastActiveDay = calendar.startOfDay(for: lastActive)
            let daysBetween = calendar.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0

            if daysBetween == 1 {
                user.currentStreak += 1
                streakContinued = true
            } else if daysBetween > 1 {
                user.currentStreak = 1
            }
            // daysBetween == 0: same day, no change
        } else {
            user.currentStreak = 1
            streakContinued = false
        }

        user.longestStreak = max(user.longestStreak, user.currentStreak)
        user.lastActiveDate = Date()
        return streakContinued
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

    /// Returns true if the streak was continued (new consecutive day)
    @discardableResult
    func recordQuizCompletion(
        session: QuizSession,
        user: User
    ) -> Bool {
        session.user = user
        user.quizSessions.append(session)
        user.totalStars += session.totalStarsEarned

        let progress = todayProgress(for: user)
        progress.quizzesCompleted += 1
        progress.correctAnswers += session.correctAnswers
        progress.totalQuestions += session.totalQuestions
        progress.starsEarned += session.totalStarsEarned

        let streakContinued = updateStreak(for: user)
        checkAchievements(for: user)

        try? modelContext.save()
        backupUserStats(user)
        return streakContinued
    }

    /// Backup key stats to UserDefaults so they survive SwiftData resets
    private func backupUserStats(_ user: User) {
        let defaults = UserDefaults.standard
        defaults.set(user.currentStreak, forKey: "backup_currentStreak")
        defaults.set(user.longestStreak, forKey: "backup_longestStreak")
        defaults.set(user.totalStars, forKey: "backup_totalStars")
        defaults.set(user.quizSessions.count, forKey: "backup_quizCount")
        if let lastActive = user.lastActiveDate {
            defaults.set(lastActive, forKey: "backup_lastActiveDate")
        }
    }

    /// Restore stats from UserDefaults backup if user has no data
    static func restoreBackupIfNeeded(for user: User) {
        let defaults = UserDefaults.standard
        // Only restore if user has no activity yet but backup exists
        guard user.currentStreak == 0,
              user.totalStars == 0,
              defaults.integer(forKey: "backup_currentStreak") > 0 || defaults.integer(forKey: "backup_totalStars") > 0
        else { return }

        user.currentStreak = defaults.integer(forKey: "backup_currentStreak")
        user.longestStreak = defaults.integer(forKey: "backup_longestStreak")
        user.totalStars = defaults.integer(forKey: "backup_totalStars")
        user.lastActiveDate = defaults.object(forKey: "backup_lastActiveDate") as? Date
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
