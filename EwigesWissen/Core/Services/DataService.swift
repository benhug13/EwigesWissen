import Foundation

@Observable
final class DataService {
    static let shared = DataService()

    private init() {}

    // MARK: - Capitals

    func capitals(for level: SchoolLevel) -> [Capital] {
        CapitalsData.all.filter { level.includes($0.level) }
    }

    func randomCapitals(count: Int, for level: SchoolLevel) -> [Capital] {
        Array(capitals(for: level).shuffled().prefix(count))
    }

    // MARK: - Geography

    func geographyItems(for level: SchoolLevel) -> [GeographyItem] {
        GeographyData.all.filter { level.includes($0.level) }
    }

    func geographyItems(for level: SchoolLevel, type: GeographyType) -> [GeographyItem] {
        geographyItems(for: level).filter { $0.type == type }
    }

    func randomGeographyItems(count: Int, for level: SchoolLevel) -> [GeographyItem] {
        Array(geographyItems(for: level).shuffled().prefix(count))
    }

    // MARK: - Fuzzy Matching

    /// Fuzzy match for text input: case-insensitive, diacritics-insensitive
    func fuzzyMatch(_ input: String, expected: String) -> Bool {
        let normalizedInput = normalize(input)
        let normalizedExpected = normalize(expected)
        return normalizedInput == normalizedExpected
    }

    private func normalize(_ text: String) -> String {
        text.lowercased()
            .folding(options: .diacriticInsensitive, locale: Locale(identifier: "de_CH"))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
