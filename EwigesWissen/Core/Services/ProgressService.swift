import Foundation
import SwiftData

struct ProgressService {
    let modelContext: ModelContext
    private let dataService = DataService.shared

    // MARK: - Record

    func recordAnswer(itemId: String, itemType: String, correct: Bool) {
        let progress = fetchOrCreate(itemId: itemId, itemType: itemType)
        let now = Date()

        if correct {
            progress.correctCount += 1
            progress.consecutiveCorrect += 1
            progress.intervalDays = Self.nextInterval(after: progress.intervalDays)
        } else {
            progress.incorrectCount += 1
            progress.consecutiveCorrect = 0
            progress.intervalDays = 0
        }
        progress.lastSeen = now
        progress.nextDueDate = now.addingTimeInterval(TimeInterval(progress.intervalDays) * 86_400)
        try? modelContext.save()
    }

    /// Leitner-style interval ladder: 0 → 1 → 3 → 7 → 14 → 30 → 60 days.
    /// Wrong answers drop back to 0 (review again tomorrow).
    private static func nextInterval(after current: Int) -> Int {
        switch current {
        case 0:  return 1
        case 1:  return 3
        case 3:  return 7
        case 7:  return 14
        case 14: return 30
        default: return 60
        }
    }

    // MARK: - Due / Spaced Repetition

    /// Items that are due for review now (lastSeen + intervalDays <= today).
    /// Includes "new" items (never seen) so the user starts learning new material.
    func dueItemIds(type: String) -> Set<String> {
        let now = Date()
        let descriptor = FetchDescriptor<ItemProgress>(
            predicate: #Predicate<ItemProgress> { $0.itemType == type && $0.nextDueDate <= now }
        )
        let items = (try? modelContext.fetch(descriptor)) ?? []
        return Set(items.map(\.itemId))
    }

    func dueCapitals(for level: SchoolLevel) -> [Capital] {
        let dueIds = dueItemIds(type: "capital")
        let seenAllItems = allProgress().filter { $0.itemType == "capital" }
        let seenIds = Set(seenAllItems.map(\.itemId))
        return dataService.capitals(for: level).filter { c in
            // New (never answered) items are also "due"
            !seenIds.contains(c.id) || dueIds.contains(c.id)
        }
    }

    func dueGeographyItems(for level: SchoolLevel) -> [GeographyItem] {
        let dueIds = dueItemIds(type: "geography")
        let seenAllItems = allProgress().filter { $0.itemType == "geography" }
        let seenIds = Set(seenAllItems.map(\.itemId))
        return dataService.geographyItems(for: level).filter { item in
            !seenIds.contains(item.id) || dueIds.contains(item.id)
        }
    }

    func dueItemCount(for level: SchoolLevel) -> Int {
        dueCapitals(for: level).count + dueGeographyItems(for: level).count
    }

    // MARK: - Wrong Items

    func wrongCapitals(for level: SchoolLevel) -> [Capital] {
        let wrongIds = wrongItemIds(type: "capital")
        return dataService.capitals(for: level).filter { wrongIds.contains($0.id) }
    }

    func wrongGeographyItems(for level: SchoolLevel) -> [GeographyItem] {
        let wrongIds = wrongItemIds(type: "geography")
        return dataService.geographyItems(for: level).filter { wrongIds.contains($0.id) }
    }

    func wrongItemCount(for level: SchoolLevel) -> Int {
        wrongCapitals(for: level).count + wrongGeographyItems(for: level).count
    }

    func hasWrongItems(for level: SchoolLevel) -> Bool {
        wrongItemCount(for: level) > 0
    }

    // MARK: - Bookmarks

    func toggleBookmark(itemId: String, itemType: String) {
        let progress = fetchOrCreate(itemId: itemId, itemType: itemType)
        progress.isBookmarked.toggle()
        try? modelContext.save()
    }

    func bookmarkedCapitals(for level: SchoolLevel) -> [Capital] {
        let bookmarkedIds = bookmarkedItemIds(type: "capital")
        return dataService.capitals(for: level).filter { bookmarkedIds.contains($0.id) }
    }

    func bookmarkedGeographyItems(for level: SchoolLevel) -> [GeographyItem] {
        let bookmarkedIds = bookmarkedItemIds(type: "geography")
        return dataService.geographyItems(for: level).filter { bookmarkedIds.contains($0.id) }
    }

    func bookmarkedCount(for level: SchoolLevel) -> Int {
        bookmarkedCapitals(for: level).count + bookmarkedGeographyItems(for: level).count
    }

    private func bookmarkedItemIds(type: String) -> Set<String> {
        let descriptor = FetchDescriptor<ItemProgress>(
            predicate: #Predicate { $0.itemType == type && $0.isBookmarked == true }
        )
        let items = (try? modelContext.fetch(descriptor)) ?? []
        return Set(items.map(\.itemId))
    }

    // MARK: - All Progress

    func allProgress() -> [ItemProgress] {
        let descriptor = FetchDescriptor<ItemProgress>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func progressFor(itemId: String) -> ItemProgress? {
        let descriptor = FetchDescriptor<ItemProgress>(
            predicate: #Predicate { $0.itemId == itemId }
        )
        return try? modelContext.fetch(descriptor).first
    }

    // MARK: - Private

    private func wrongItemIds(type: String) -> Set<String> {
        let descriptor = FetchDescriptor<ItemProgress>(
            predicate: #Predicate { $0.itemType == type }
        )
        let items = (try? modelContext.fetch(descriptor)) ?? []
        return Set(items.filter(\.isWeak).map(\.itemId))
    }

    private func fetchOrCreate(itemId: String, itemType: String) -> ItemProgress {
        let descriptor = FetchDescriptor<ItemProgress>(
            predicate: #Predicate { $0.itemId == itemId && $0.itemType == itemType }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let progress = ItemProgress(itemId: itemId, itemType: itemType)
        modelContext.insert(progress)
        return progress
    }
}
