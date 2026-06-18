import SwiftUI
import MapKit
import CoreLocation

@Observable
final class GeographyQuizViewModel {
    private let dataService = DataService.shared

    var questions: [GeographyItem] = []
    var currentIndex: Int = 0
    var placedPin: CLLocationCoordinate2D? = nil
    var placedNAFraction: CGPoint? = nil
    var showResult: Bool = false
    var isCorrect: Bool = false
    var distanceKm: Double = 0
    var results: [QuizResult] = []
    var isCompleted: Bool = false
    var schoolLevel: SchoolLevel = .sek1

    var currentQuestion: GeographyItem? {
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

    func startQuiz(level: SchoolLevel, region: GeographyRegion = .world, questionCount: Int = 10, type: GeographyType? = nil, types: [GeographyType]? = nil) {
        schoolLevel = level
        let pool = dataService.geographyItems(for: level, region: region)
        if let types {
            let filtered = pool.filter { types.contains($0.type) }.shuffled()
            questions = Array(filtered.prefix(questionCount))
        } else if let type {
            let filtered = pool.filter { $0.type == type }.shuffled()
            questions = Array(filtered.prefix(questionCount))
        } else {
            questions = Array(pool.shuffled().prefix(questionCount))
        }
        currentIndex = 0
        placedPin = nil
        showResult = false
        results = []
        isCompleted = false
    }

    func placePin(at coordinate: CLLocationCoordinate2D) {
        guard !showResult else { return }
        placedPin = coordinate
    }

    func placeNAFraction(_ fraction: CGPoint) {
        guard !showResult else { return }
        placedNAFraction = fraction
    }

    func confirmAnswerOnNAMap() {
        guard let question = currentQuestion,
              let placed = placedNAFraction,
              let correct = question.naMapPoint else { return }

        distanceKm = StummeKarteNordamerikaQuizView.distanceKm(from: placed, to: correct)
        isCorrect = distanceKm <= question.toleranceRadiusKm

        let stars: Int
        if isCorrect {
            let ratio = distanceKm / question.toleranceRadiusKm
            if ratio < 0.3 { stars = 3 }
            else if ratio < 0.6 { stars = 2 }
            else { stars = 1 }
        } else {
            stars = 0
        }

        let result = QuizResult(
            questionId: question.id,
            questionText: "Wo liegt \(question.name)?",
            correctAnswer: "\(correct.x), \(correct.y)",
            userAnswer: "\(placed.x), \(placed.y)",
            isCorrect: isCorrect,
            starsEarned: stars
        )
        results.append(result)
        showResult = true
    }

    func confirmAnswer(on map: CalibrationMap) {
        guard let question = currentQuestion, let pin = placedPin else { return }

        isCorrect = question.isCorrectPlacement(at: pin, on: map)
        distanceKm = question.distanceInKm(to: pin, on: map)

        let stars: Int
        if isCorrect {
            let ratio = distanceKm / question.toleranceRadiusKm
            if ratio < 0.3 { stars = 3 }
            else if ratio < 0.6 { stars = 2 }
            else { stars = 1 }
        } else {
            stars = 0
        }

        let result = QuizResult(
            questionId: question.id,
            questionText: "Wo liegt \(question.name)?",
            correctAnswer: "\(question.latitude), \(question.longitude)",
            userAnswer: "\(pin.latitude), \(pin.longitude)",
            isCorrect: isCorrect,
            starsEarned: stars
        )
        results.append(result)
        showResult = true
    }

    func nextQuestion() {
        showResult = false
        placedPin = nil
        placedNAFraction = nil

        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            isCompleted = true
        }
    }

    func createSession() -> QuizSession {
        let session = QuizSession(quizType: .geographyPinPlacement, schoolLevel: schoolLevel, totalQuestions: questions.count)
        session.correctAnswers = correctCount
        session.totalStarsEarned = totalStars
        session.completedAt = Date()
        session.results = results
        return session
    }
}
