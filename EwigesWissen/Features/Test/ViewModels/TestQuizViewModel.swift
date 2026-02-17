import SwiftUI
import MapKit
import CoreLocation

enum TestQuestion: Identifiable {
    case countryToCapital(Capital)
    case capitalToCountry(Capital)
    case geography(GeographyItem)

    var id: String {
        switch self {
        case .countryToCapital(let c): return "c2c-\(c.id)"
        case .capitalToCountry(let c): return "c2l-\(c.id)"
        case .geography(let g): return "geo-\(g.id)"
        }
    }

    var isCapitalQuestion: Bool {
        switch self {
        case .countryToCapital, .capitalToCountry: return true
        case .geography: return false
        }
    }

    var typeIcon: String {
        switch self {
        case .countryToCapital, .capitalToCountry: return "building.columns"
        case .geography: return "globe.europe.africa.fill"
        }
    }
}

@Observable
final class TestQuizViewModel {
    private let dataService = DataService.shared
    static let testDuration: TimeInterval = 15 * 60 // 15 minutes

    var questions: [TestQuestion] = []
    var currentIndex: Int = 0
    var isCompleted: Bool = false
    var results: [QuizResult] = []
    var schoolLevel: SchoolLevel = .sek1

    // Capital question state
    var userAnswer: String = ""

    // Geography question state
    var placedPin: CLLocationCoordinate2D? = nil

    // Timer
    var timeRemaining: TimeInterval = testDuration
    var timerExpired: Bool = false

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

    var timerText: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var timerColor: Color {
        if timeRemaining <= 60 { return AppColors.error }
        if timeRemaining <= 3 * 60 { return AppColors.warning }
        return AppColors.textSecondary
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

    // MARK: - Start Test

    func startTest(level: SchoolLevel) {
        schoolLevel = level
        timeRemaining = Self.testDuration
        timerExpired = false

        // 4 country→capital + 4 capital→country
        let capitals = dataService.randomCapitals(count: 8, for: level)
        let c2c = capitals.prefix(4).map { TestQuestion.countryToCapital($0) }
        let c2l = capitals.suffix(4).map { TestQuestion.capitalToCountry($0) }
        let capitalQuestions = (c2c + c2l).shuffled()

        // 10 geography pin-placement
        let geoItems = dataService.randomGeographyItems(count: 10, for: level)
        let geoQuestions = geoItems.map { TestQuestion.geography($0) }

        // Capitals first, then geography
        questions = capitalQuestions + geoQuestions
        currentIndex = 0
        resetQuestionState()
        results = []
        isCompleted = false
    }

    // MARK: - Timer

    func tick() {
        guard timeRemaining > 0, !isCompleted else { return }
        timeRemaining -= 1
        if timeRemaining <= 0 {
            timeRemaining = 0
            finishTest()
        }
    }

    // MARK: - Capital Answer

    func submitCapitalAnswer() {
        let expected = capitalCorrectAnswer
        let correct = dataService.fuzzyMatch(userAnswer, expected: expected)

        let stars = correct ? 3 : 0
        let result = QuizResult(
            questionId: currentQuestion?.id ?? "",
            questionText: capitalQuestionText,
            correctAnswer: expected,
            userAnswer: userAnswer,
            isCorrect: correct,
            starsEarned: stars
        )
        results.append(result)
        advance()
    }

    // MARK: - Geography Answer

    func placePin(at coordinate: CLLocationCoordinate2D) {
        placedPin = coordinate
    }

    func confirmGeoAnswer() {
        guard case .geography(let item) = currentQuestion, let pin = placedPin else { return }

        let correct = item.isCorrectPlacement(at: pin)
        let distanceKm = item.distanceInKm(to: pin)

        let stars: Int
        if correct {
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
            userAnswer: String(format: "%.0f km Abstand", distanceKm),
            isCorrect: correct,
            starsEarned: stars
        )
        results.append(result)
        advance()
    }

    // MARK: - Navigation

    private func advance() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            resetQuestionState()
        } else {
            isCompleted = true
        }
    }

    /// Called when timer expires - mark remaining questions as unanswered
    func finishTest() {
        timerExpired = true
        // Record unanswered questions
        for i in results.count..<questions.count {
            let q = questions[i]
            let result: QuizResult
            switch q {
            case .countryToCapital(let c):
                result = QuizResult(
                    questionId: q.id,
                    questionText: "Was ist die Hauptstadt von \(c.country)?",
                    correctAnswer: c.capital,
                    userAnswer: "—",
                    isCorrect: false,
                    starsEarned: 0
                )
            case .capitalToCountry(let c):
                result = QuizResult(
                    questionId: q.id,
                    questionText: "Zu welchem Land gehört \(c.capital)?",
                    correctAnswer: c.country,
                    userAnswer: "—",
                    isCorrect: false,
                    starsEarned: 0
                )
            case .geography(let item):
                result = QuizResult(
                    questionId: item.id,
                    questionText: "Wo liegt \(item.name)?",
                    correctAnswer: "\(item.latitude), \(item.longitude)",
                    userAnswer: "—",
                    isCorrect: false,
                    starsEarned: 0
                )
            }
            results.append(result)
        }
        isCompleted = true
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
        placedPin = nil
    }
}
