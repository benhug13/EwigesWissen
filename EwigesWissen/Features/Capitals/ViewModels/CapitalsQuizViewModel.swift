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
    var isCountryToCapital: Bool = true // Direction for current question
    var direction: QuizDirection = .countryToCapital
    var isMultipleChoice: Bool = false
    var mcOptions: [String] = []
    var selectedMcOption: String? = nil
    var schoolLevel: SchoolLevel = .sek1
    private var perQuestionDirections: [Bool] = [] // for mixed mode

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

    var hintText: String? {
        guard attemptNumber >= 3 else { return nil }
        let answer = correctAnswer
        guard let first = answer.first else { return nil }
        return "Tipp: \(first)... (\(answer.count) Buchstaben)"
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

    func startQuiz(level: SchoolLevel, questionCount: Int = 10, direction: QuizDirection = .countryToCapital, multipleChoice: Bool = false) {
        schoolLevel = level
        self.direction = direction
        isMultipleChoice = multipleChoice
        questions = dataService.randomCapitals(count: questionCount, for: level)

        // Generate per-question directions for mixed mode
        switch direction {
        case .countryToCapital:
            perQuestionDirections = Array(repeating: true, count: questions.count)
        case .capitalToCountry:
            perQuestionDirections = Array(repeating: false, count: questions.count)
        case .mixed:
            perQuestionDirections = questions.map { _ in Bool.random() }
        }

        currentIndex = 0
        isCountryToCapital = perQuestionDirections.first ?? true
        userAnswer = ""
        showResult = false
        attemptNumber = 1
        selectedMcOption = nil
        results = []
        isCompleted = false
        if isMultipleChoice { generateMcOptions() }
    }

    private func generateMcOptions() {
        guard let question = currentQuestion else { return }
        let correct = correctAnswer
        let allAnswers = dataService.capitals(for: schoolLevel).map {
            isCountryToCapital ? $0.capital : $0.country
        }
        var wrong = allAnswers.filter { $0 != correct }.shuffled().prefix(3)
        mcOptions = (Array(wrong) + [correct]).shuffled()
        selectedMcOption = nil
    }

    func submitMcAnswer(_ option: String) {
        guard let question = currentQuestion else { return }
        selectedMcOption = option
        let correct = option == correctAnswer
        isCorrect = correct

        let stars = correct ? 3 : 0
        let result = QuizResult(
            questionId: question.id,
            questionText: questionText,
            correctAnswer: correctAnswer,
            userAnswer: option,
            isCorrect: correct,
            starsEarned: stars
        )
        results.append(result)
        showResult = true
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
        selectedMcOption = nil

        if currentIndex < questions.count - 1 {
            currentIndex += 1
            isCountryToCapital = perQuestionDirections[currentIndex]
            if isMultipleChoice { generateMcOptions() }
        } else {
            isCompleted = true
        }
    }

    func createSession() -> QuizSession {
        let type: QuizType
        switch direction {
        case .countryToCapital: type = .capitalCountryToCapital
        case .capitalToCountry: type = .capitalCapitalToCountry
        case .mixed: type = .capitalCountryToCapital // default for mixed
        }
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
