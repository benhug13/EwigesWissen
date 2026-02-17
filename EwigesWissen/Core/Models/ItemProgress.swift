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

    init(itemId: String, itemType: String) {
        self.itemId = itemId
        self.itemType = itemType
        self.correctCount = 0
        self.incorrectCount = 0
        self.lastSeen = Date()
        self.isBookmarked = false
    }

    var isWeak: Bool {
        incorrectCount > correctCount
    }
}
