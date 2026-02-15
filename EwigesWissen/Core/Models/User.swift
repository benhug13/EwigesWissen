import Foundation
import SwiftData

@Model
final class User {
    var name: String
    var schoolLevel: String // SchoolLevel rawValue
    var totalStars: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date?
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var quizSessions: [QuizSession]
    @Relationship(deleteRule: .cascade) var dailyProgress: [DailyProgress]
    @Relationship(deleteRule: .cascade) var achievements: [Achievement]
    @Relationship(deleteRule: .cascade) var preferences: UserPreferences?

    init(
        name: String = "",
        schoolLevel: SchoolLevel = .sek1
    ) {
        self.name = name
        self.schoolLevel = schoolLevel.rawValue
        self.totalStars = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastActiveDate = nil
        self.createdAt = Date()
        self.quizSessions = []
        self.dailyProgress = []
        self.achievements = []
        self.preferences = nil
    }

    var level: SchoolLevel {
        get { SchoolLevel(rawValue: schoolLevel) ?? .sek1 }
        set { schoolLevel = newValue.rawValue }
    }
}
