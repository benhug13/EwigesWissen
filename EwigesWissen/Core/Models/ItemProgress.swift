import Foundation
import SwiftData

@Model
final class ItemProgress {
    var itemId: String
    var itemType: String // "capital" or "geography"
    var correctCount: Int
    var incorrectCount: Int
    var lastSeen: Date
    var isBookmarked: Bool

    // Spaced repetition scheduling (Leitner-style intervals).
    // intervalDays is the gap before this item should be reviewed again.
    // nextDueDate is when it becomes due. Items with nextDueDate <= now are "due".
    var intervalDays: Int = 0
    var nextDueDate: Date = Date()
    var consecutiveCorrect: Int = 0

    init(itemId: String, itemType: String) {
        self.itemId = itemId
        self.itemType = itemType
        self.correctCount = 0
        self.incorrectCount = 0
        self.lastSeen = Date()
        self.isBookmarked = false
        self.intervalDays = 0
        self.nextDueDate = Date()
        self.consecutiveCorrect = 0
    }

    var isWeak: Bool {
        incorrectCount > correctCount
    }

    var isDue: Bool {
        nextDueDate <= Date()
    }

    var isNew: Bool {
        correctCount == 0 && incorrectCount == 0
    }
}
