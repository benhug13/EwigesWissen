import SwiftUI

@Observable
final class CapitalsLearningViewModel {
    private let dataService = DataService.shared

    var capitals: [Capital] = []
    var currentIndex: Int = 0
    var isFlipped: Bool = false
    var schoolLevel: SchoolLevel = .sek1

    var currentCapital: Capital? {
        guard currentIndex < capitals.count else { return nil }
        return capitals[currentIndex]
    }

    var progress: Double {
        guard !capitals.isEmpty else { return 0 }
        return Double(currentIndex) / Double(capitals.count)
    }

    var progressText: String {
        "\(currentIndex + 1) / \(capitals.count)"
    }

    var hasNext: Bool {
        currentIndex < capitals.count - 1
    }

    var hasPrevious: Bool {
        currentIndex > 0
    }

    func loadCapitals(for level: SchoolLevel) {
        schoolLevel = level
        capitals = dataService.capitals(for: level).shuffled()
        currentIndex = 0
        isFlipped = false
    }

    func next() {
        guard hasNext else { return }
        isFlipped = false
        currentIndex += 1
    }

    func previous() {
        guard hasPrevious else { return }
        isFlipped = false
        currentIndex -= 1
    }

    func flip() {
        isFlipped.toggle()
    }

    func shuffle() {
        capitals.shuffle()
        currentIndex = 0
        isFlipped = false
    }
}
