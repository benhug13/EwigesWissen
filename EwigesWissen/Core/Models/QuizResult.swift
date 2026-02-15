import Foundation

struct QuizResult: Identifiable, Codable, Hashable {
    let id: UUID
    let questionId: String
    let questionText: String
    let correctAnswer: String
    let userAnswer: String
    let isCorrect: Bool
    let starsEarned: Int
    let attemptNumber: Int
    let timeSpent: TimeInterval
    let timestamp: Date

    init(
        questionId: String,
        questionText: String,
        correctAnswer: String,
        userAnswer: String,
        isCorrect: Bool,
        starsEarned: Int,
        attemptNumber: Int = 1,
        timeSpent: TimeInterval = 0
    ) {
        self.id = UUID()
        self.questionId = questionId
        self.questionText = questionText
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
        self.starsEarned = starsEarned
        self.attemptNumber = attemptNumber
        self.timeSpent = timeSpent
        self.timestamp = Date()
    }
}
