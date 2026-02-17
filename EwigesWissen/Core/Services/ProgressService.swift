import Foundation
import SwiftData

struct ProgressService {
    let modelContext: ModelContext
    private let dataService = DataService.shared

    // MARK: - Record

    func recordAnswer(itemId: String, itemType: String, correct: Bool) {
        let progress = fetchOrCreate(itemId: itemId, itemType: itemType)
        if correct {
            progress.correctCount += 1
        } else {
            progress.incorrectCount += 1
        }
        progress.lastSeen = Date()
        try? modelContext.save()
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
