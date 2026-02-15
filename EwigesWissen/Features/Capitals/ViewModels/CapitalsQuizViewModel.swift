import SwiftUI
import SwiftData

@Observable
final class CapitalsQuizViewModel {
    private let dataService = DataService.shared

    var questions: [Capital] = []
    var currentIndex: Int = 0
    var userAnswer: String = ""
    var showResult: Bool = false
    var isCorrect: Bool = false
    var attemptNumber: Int = 1
    var results: [QuizResult] = []
    var isCompleted: Bool = false
    var isCountryToCapital: Bool = true // Direction: true = Land→Hauptstadt
    var schoolLevel: SchoolLevel = .sek1

    var currentQuestion: Capital? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var questionText: String {
        guard let q = currentQuestion else { return "" }
        return isCountryToCapital
            ? "Was ist die Hauptstadt von \(q.country)?"
            : "Zu welchem Land gehört \(q.capital)?"
    }

    var correctAnswer: String {
        guard let q = currentQuestion else { return "" }
        return isCountryToCapital ? q.capital : q.country
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var progressText: String {
        "\(currentIndex + 1) / \(questions.count)"
    }

    var totalStars: Int {
        results.reduce(0) { $0 + $1.starsEarned }
    }

    var correctCount: Int {
        results.filter(\.isCorrect).count
    }

    func startQuiz(level: SchoolLevel, questionCount: Int = 10, countryToCapital: Bool = true) {
        schoolLevel = level
        isCountryToCapital = countryToCapital
        questions = dataService.randomCapitals(count: questionCount, for: level)
        currentIndex = 0
        userAnswer = ""
        showResult = false
        attemptNumber = 1
        results = []
        isCompleted = false
    }

    func submitAnswer() {
        guard let question = currentQuestion else { return }

        let expected = correctAnswer
        let correct = dataService.fuzzyMatch(userAnswer, expected: expected)
        isCorrect = correct

        if correct || attemptNumber >= 3 {
            let stars = correct ? starsForAttempt(attemptNumber) : 0
            let result = QuizResult(
                questionId: question.id,
                questionText: questionText,
                correctAnswer: expected,
                userAnswer: userAnswer,
                isCorrect: correct,
                starsEarned: stars,
                attemptNumber: attemptNumber
            )
            results.append(result)
            showResult = true
        } else {
            attemptNumber += 1
            userAnswer = ""
        }
    }

    func nextQuestion() {
        showResult = false
        userAnswer = ""
        attemptNumber = 1

        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            isCompleted = true
        }
    }

    func createSession() -> QuizSession {
        let type: QuizType = isCountryToCapital ? .capitalCountryToCapital : .capitalCapitalToCountry
        let session = QuizSession(quizType: type, schoolLevel: schoolLevel, totalQuestions: questions.count)
        session.correctAnswers = correctCount
        session.totalStarsEarned = totalStars
        session.completedAt = Date()
        session.results = results
        return session
    }

    private func starsForAttempt(_ attempt: Int) -> Int {
        switch attempt {
        case 1: return 3
        case 2: return 2
        default: return 1
        }
    }
}
