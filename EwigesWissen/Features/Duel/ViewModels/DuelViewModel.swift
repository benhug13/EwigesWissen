import SwiftUI
import CoreLocation

enum BotDifficulty: String, CaseIterable, Identifiable {
    case easy = "Leicht"
    case medium = "Mittel"
    case hard = "Schwer"

    var id: String { rawValue }

    var accuracy: Double {
        switch self {
        case .easy: return 0.35
        case .medium: return 0.6
        case .hard: return 0.85
        }
    }

    var icon: String {
        switch self {
        case .easy: return "hare"
        case .medium: return "cpu"
        case .hard: return "bolt.fill"
        }
    }
}

@MainActor @Observable
final class DuelViewModel {
    private let dataService = DataService.shared

    var questions: [Capital] = []
    var currentIndex: Int = 0
    var isCompleted: Bool = false
    var schoolLevel: SchoolLevel = .sek1
    var difficulty: BotDifficulty = .medium

    // Players
    let player1Name: String = "Du"
    let player2Name: String = "Bot"
    var player1Score: Int = 0
    var player2Score: Int = 0
    var player1Results: [Bool] = []
    var player2Results: [Bool] = []

    // Answer state
    var userAnswer: String = ""
    var showResult: Bool = false
    var isCorrect: Bool = false
    var botCorrect: Bool = false
    var showBotResult: Bool = false

    var currentQuestion: Capital? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var questionText: String {
        guard let q = currentQuestion else { return "" }
        return "Was ist die Hauptstadt von \(q.country)?"
    }

    var correctAnswer: String {
        currentQuestion?.capital ?? ""
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var progressText: String {
        "Frage \(currentIndex + 1) / \(questions.count)"
    }

    var winner: String {
        if player1Score > player2Score { return player1Name }
        if player2Score > player1Score { return player2Name }
        return "Unentschieden"
    }

    var isDraw: Bool { player1Score == player2Score }

    // MARK: - Start

    func startDuel(level: SchoolLevel, questionCount: Int = 8) {
        schoolLevel = level
        questions = dataService.randomCapitals(count: questionCount, for: level)
        currentIndex = 0
        player1Score = 0
        player2Score = 0
        player1Results = []
        player2Results = []
        userAnswer = ""
        showResult = false
        isCorrect = false
        botCorrect = false
        showBotResult = false
        isCompleted = false
    }

    // MARK: - Answer

    func submitAnswer() {
        let correct = dataService.fuzzyMatch(userAnswer, expected: correctAnswer)
        isCorrect = correct
        player1Results.append(correct)
        if correct { player1Score += 1 }

        // Bot answers based on difficulty
        botCorrect = Double.random(in: 0...1) < difficulty.accuracy
        player2Results.append(botCorrect)
        if botCorrect { player2Score += 1 }

        showResult = true
    }

    // MARK: - Navigation

    func nextQuestion() {
        showResult = false
        showBotResult = false
        userAnswer = ""

        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            isCompleted = true
        }
    }
}
