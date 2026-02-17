import XCTest
@testable import EwigesWissen

final class DataServiceTests: XCTestCase {

    let dataService = DataService.shared

    // MARK: - Fuzzy Matching

    func testFuzzyMatchExact() {
        XCTAssertTrue(dataService.fuzzyMatch("Bern", expected: "Bern"))
    }

    func testFuzzyMatchCaseInsensitive() {
        XCTAssertTrue(dataService.fuzzyMatch("bern", expected: "Bern"))
        XCTAssertTrue(dataService.fuzzyMatch("BERN", expected: "Bern"))
    }

    func testFuzzyMatchDiacritics() {
        XCTAssertTrue(dataService.fuzzyMatch("Brussel", expected: "Brüssel"))
        XCTAssertTrue(dataService.fuzzyMatch("brüssel", expected: "Brüssel"))
    }

    func testFuzzyMatchWhitespace() {
        XCTAssertTrue(dataService.fuzzyMatch(" Bern ", expected: "Bern"))
    }

    func testFuzzyMatchWrongAnswer() {
        XCTAssertFalse(dataService.fuzzyMatch("Zürich", expected: "Bern"))
    }

    // MARK: - Capitals Data

    func testCapitalsForSek1() {
        let capitals = dataService.capitals(for: .sek1)
        XCTAssertFalse(capitals.isEmpty)
        XCTAssertTrue(capitals.allSatisfy { $0.level == .sek1 })
    }

    func testAllCapitalsAvailableForBothLevels() {
        let sek1Count = dataService.capitals(for: .sek1).count
        let sek2Count = dataService.capitals(for: .sek2).count
        XCTAssertEqual(sek1Count, 48)
        XCTAssertEqual(sek2Count, 48)
    }

    func testCapitalsContainBern() {
        let capitals = dataService.capitals(for: .sek1)
        XCTAssertTrue(capitals.contains { $0.capital == "Bern" })
    }

    // MARK: - Geography Data

    func testGeographyForSek1() {
        let items = dataService.geographyItems(for: .sek1)
        XCTAssertFalse(items.isEmpty)
        XCTAssertTrue(items.allSatisfy { $0.level == .sek1 })
    }

    func testGeographyForSek2IncludesSek1() {
        let sek1Count = dataService.geographyItems(for: .sek1).count
        let sek2Count = dataService.geographyItems(for: .sek2).count
        XCTAssertGreaterThan(sek2Count, sek1Count)
    }

    func testGeographyFilterByType() {
        let mountains = dataService.geographyItems(for: .sek1, type: .mountain)
        XCTAssertFalse(mountains.isEmpty)
        XCTAssertTrue(mountains.allSatisfy { $0.type == .mountain })
    }
}

final class GeographyItemTests: XCTestCase {

    func testCorrectPlacementWithinTolerance() {
        let item = GeographyItem(
            name: "Test",
            type: .mountain,
            latitude: 47.0,
            longitude: 8.0,
            toleranceRadiusKm: 100
        )
        // Very close placement
        let coord = CLLocationCoordinate2D(latitude: 47.01, longitude: 8.01)
        XCTAssertTrue(item.isCorrectPlacement(at: coord))
    }

    func testIncorrectPlacementOutsideTolerance() {
        let item = GeographyItem(
            name: "Test",
            type: .mountain,
            latitude: 47.0,
            longitude: 8.0,
            toleranceRadiusKm: 10
        )
        // Far away placement
        let coord = CLLocationCoordinate2D(latitude: 50.0, longitude: 12.0)
        XCTAssertFalse(item.isCorrectPlacement(at: coord))
    }

    func testDistanceCalculation() {
        let item = GeographyItem(
            name: "Test",
            type: .river,
            latitude: 47.0,
            longitude: 8.0,
            toleranceRadiusKm: 100
        )
        let distance = item.distanceInKm(to: CLLocationCoordinate2D(latitude: 47.0, longitude: 8.0))
        XCTAssertEqual(distance, 0, accuracy: 0.1)
    }
}

final class SchoolLevelTests: XCTestCase {

    func testSek1IncludesOnlySek1() {
        XCTAssertTrue(SchoolLevel.sek1.includes(.sek1))
        XCTAssertFalse(SchoolLevel.sek1.includes(.sek2))
    }

    func testSek2IncludesBoth() {
        XCTAssertTrue(SchoolLevel.sek2.includes(.sek1))
        XCTAssertTrue(SchoolLevel.sek2.includes(.sek2))
    }
}

final class CapitalsQuizViewModelTests: XCTestCase {

    func testStartQuiz() {
        let vm = CapitalsQuizViewModel()
        vm.startQuiz(level: .sek1, questionCount: 5)

        XCTAssertEqual(vm.questions.count, 5)
        XCTAssertEqual(vm.currentIndex, 0)
        XCTAssertFalse(vm.isCompleted)
    }

    func testCorrectAnswer() {
        let vm = CapitalsQuizViewModel()
        vm.startQuiz(level: .sek1, questionCount: 1, countryToCapital: true)

        guard let question = vm.currentQuestion else {
            XCTFail("No question")
            return
        }

        vm.userAnswer = question.capital
        vm.submitAnswer()

        XCTAssertTrue(vm.showResult)
        XCTAssertTrue(vm.isCorrect)
        XCTAssertEqual(vm.results.count, 1)
        XCTAssertEqual(vm.results.first?.starsEarned, 3)
    }

    func testIncorrectAnswerAllowsRetry() {
        let vm = CapitalsQuizViewModel()
        vm.startQuiz(level: .sek1, questionCount: 1, countryToCapital: true)

        vm.userAnswer = "FalscheAntwort"
        vm.submitAnswer()

        // Should not show result yet, allows retry
        XCTAssertFalse(vm.showResult)
        XCTAssertEqual(vm.attemptNumber, 2)
    }
}
