import Foundation
import SwiftData

enum AchievementType: String, Codable, CaseIterable {
    // Milestone achievements
    case firstQuiz = "first_quiz"
    case tenQuizzes = "ten_quizzes"
    case fiftyQuizzes = "fifty_quizzes"
    case hundredQuizzes = "hundred_quizzes"

    // Streak achievements
    case threeDayStreak = "three_day_streak"
    case sevenDayStreak = "seven_day_streak"
    case thirtyDayStreak = "thirty_day_streak"

    // Perfection achievements
    case perfectQuiz = "perfect_quiz"
    case fivePerfectQuizzes = "five_perfect_quizzes"
    case tenPerfectQuizzes = "ten_perfect_quizzes"

    // Category-specific
    case allCapitalsSek1 = "all_capitals_sek1"
    case allCapitalsSek2 = "all_capitals_sek2"
    case allGeographySek1 = "all_geography_sek1"
    case allGeographySek2 = "all_geography_sek2"

    // Stars
    case hundredStars = "hundred_stars"

    var displayName: String {
        switch self {
        case .firstQuiz: return "Erster Schritt"
        case .tenQuizzes: return "Fleissig"
        case .fiftyQuizzes: return "Experte"
        case .hundredQuizzes: return "Meister"
        case .threeDayStreak: return "Am Ball"
        case .sevenDayStreak: return "Wochenkämpfer"
        case .thirtyDayStreak: return "Monatsmarathon"
        case .perfectQuiz: return "Perfektionist"
        case .fivePerfectQuizzes: return "Präzisionsarbeit"
        case .tenPerfectQuizzes: return "Unfehlbar"
        case .allCapitalsSek1: return "Hauptstadt-Kenner"
        case .allCapitalsSek2: return "Hauptstadt-Meister"
        case .allGeographySek1: return "Geografie-Kenner"
        case .allGeographySek2: return "Geografie-Meister"
        case .hundredStars: return "Sternsammler"
        }
    }

    var description: String {
        switch self {
        case .firstQuiz: return "Schliesse dein erstes Quiz ab"
        case .tenQuizzes: return "Schliesse 10 Quizzes ab"
        case .fiftyQuizzes: return "Schliesse 50 Quizzes ab"
        case .hundredQuizzes: return "Schliesse 100 Quizzes ab"
        case .threeDayStreak: return "Lerne 3 Tage in Folge"
        case .sevenDayStreak: return "Lerne 7 Tage in Folge"
        case .thirtyDayStreak: return "Lerne 30 Tage in Folge"
        case .perfectQuiz: return "Beantworte alle Fragen in einem Quiz richtig"
        case .fivePerfectQuizzes: return "Schliesse 5 perfekte Quizzes ab"
        case .tenPerfectQuizzes: return "Schliesse 10 perfekte Quizzes ab"
        case .allCapitalsSek1: return "Lerne alle Hauptstädte der 1. Sek"
        case .allCapitalsSek2: return "Lerne alle Hauptstädte der 2. Sek"
        case .allGeographySek1: return "Lerne alle Geografie-Items der 1. Sek"
        case .allGeographySek2: return "Lerne alle Geografie-Items der 2. Sek"
        case .hundredStars: return "Sammle 100 Sterne"
        }
    }

    var iconName: String {
        switch self {
        case .firstQuiz: return "star.fill"
        case .tenQuizzes: return "flame.fill"
        case .fiftyQuizzes: return "graduationcap.fill"
        case .hundredQuizzes: return "crown.fill"
        case .threeDayStreak: return "bolt.fill"
        case .sevenDayStreak: return "bolt.shield.fill"
        case .thirtyDayStreak: return "trophy.fill"
        case .perfectQuiz: return "checkmark.seal.fill"
        case .fivePerfectQuizzes: return "rosette"
        case .tenPerfectQuizzes: return "medal.fill"
        case .allCapitalsSek1: return "building.columns.fill"
        case .allCapitalsSek2: return "building.columns.circle.fill"
        case .allGeographySek1: return "globe.europe.africa.fill"
        case .allGeographySek2: return "globe.americas.fill"
        case .hundredStars: return "star.circle.fill"
        }
    }
}

@Model
final class Achievement {
    var typeRawValue: String
    var unlockedAt: Date
    var isNew: Bool

    var user: User?

    init(type: AchievementType) {
        self.typeRawValue = type.rawValue
        self.unlockedAt = Date()
        self.isNew = true
    }

    var type: AchievementType {
        AchievementType(rawValue: typeRawValue) ?? .firstQuiz
    }
}
