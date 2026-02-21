import SwiftUI
import MapKit
import CoreLocation

@MainActor @Observable
final class MistakeQuizViewModel {
    private let dataService = DataService.shared

    var questions: [TestQuestion] = []
    var currentIndex: Int = 0
    var isCompleted: Bool = false
    var results: [QuizResult] = []
    var schoolLevel: SchoolLevel = .sek1

    // Capital question state
    var userAnswer: String = ""
    var showResult: Bool = false
    var isCorrect: Bool = false
    var attemptNumber: Int = 1

    // Geography question state
    var placedPin: CLLocationCoordinate2D? = nil
    var distanceKm: Double = 0

    var currentQuestion: TestQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
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

    var capitalQuestionText: String {
        guard let q = currentQuestion else { return "" }
        switch q {
        case .countryToCapital(let c):
            return "Was ist die Hauptstadt von \(c.country)?"
        case .capitalToCountry(let c):
            return "Zu welchem Land gehört \(c.capital)?"
        case .geography:
            return ""
        }
    }

    var capitalCorrectAnswer: String {
        guard let q = currentQuestion else { return "" }
        switch q {
        case .countryToCapital(let c): return c.capital
        case .capitalToCountry(let c): return c.country
        case .geography: return ""
        }
    }

    var hintText: String? {
        guard attemptNumber >= 3 else { return nil }
        let answer = capitalCorrectAnswer
        guard let first = answer.first else { return nil }
        return "Tipp: \(first)... (\(answer.count) Buchstaben)"
    }

    // MARK: - Start

    func startQuiz(capitals: [Capital], geoItems: [GeographyItem]) {
        // Mix of country→capital and capital→country for capitals
        var capitalQuestions: [TestQuestion] = capitals.shuffled().enumerated().map { index, cap in
            index % 2 == 0 ? .countryToCapital(cap) : .capitalToCountry(cap)
        }
        let geoQuestions = geoItems.shuffled().map { TestQuestion.geography($0) }

        // Capitals first, then geo
        questions = capitalQuestions + geoQuestions
        currentIndex = 0
        resetQuestionState()
        results = []
        isCompleted = false
    }

    // MARK: - Capital Answer

    func submitCapitalAnswer() {
        let expected = capitalCorrectAnswer
        let correct = dataService.fuzzyMatch(userAnswer, expected: expected)
        isCorrect = correct

        if correct || attemptNumber >= 3 {
            let stars = correct ? starsForAttempt(attemptNumber) : 0
            let result = QuizResult(
                questionId: currentQuestion?.id ?? "",
                questionText: capitalQuestionText,
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

    // MARK: - Geography Answer

    func placePin(at coordinate: CLLocationCoordinate2D) {
        guard !showResult else { return }
        placedPin = coordinate
    }

    func confirmGeoAnswer() {
        guard case .geography(let item) = currentQuestion, let pin = placedPin else { return }

        isCorrect = item.isCorrectPlacement(at: pin)
        distanceKm = item.distanceInKm(to: pin)

        let stars: Int
        if isCorrect {
            let ratio = distanceKm / item.toleranceRadiusKm
            if ratio < 0.3 { stars = 3 }
            else if ratio < 0.6 { stars = 2 }
            else { stars = 1 }
        } else {
            stars = 0
        }

        let result = QuizResult(
            questionId: item.id,
            questionText: "Wo liegt \(item.name)?",
            correctAnswer: "\(item.latitude), \(item.longitude)",
            userAnswer: "\(pin.latitude), \(pin.longitude)",
            isCorrect: isCorrect,
            starsEarned: stars
        )
        results.append(result)
        showResult = true
    }

    // MARK: - Navigation

    func nextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            resetQuestionState()
        } else {
            isCompleted = true
        }
    }

    // MARK: - Session

    func createSession() -> QuizSession {
        let session = QuizSession(quizType: .combinedTest, schoolLevel: schoolLevel, totalQuestions: questions.count)
        session.correctAnswers = correctCount
        session.totalStarsEarned = totalStars
        session.completedAt = Date()
        session.results = results
        return session
    }

    // MARK: - Private

    private func resetQuestionState() {
        userAnswer = ""
        showResult = false
        isCorrect = false
        attemptNumber = 1
        placedPin = nil
        distanceKm = 0
    }

    private func starsForAttempt(_ attempt: Int) -> Int {
        switch attempt {
        case 1: return 3
        case 2: return 2
        default: return 1
        }
    }
}
