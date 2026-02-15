import Foundation

enum SchoolLevel: String, Codable, CaseIterable, Identifiable {
    case sek1 = "1. Sek"
    case sek2 = "2. Sek"

    var id: String { rawValue }

    var displayName: String { rawValue }

    /// Returns whether items of the given level should be included for this school level
    func includes(_ itemLevel: SchoolLevel) -> Bool {
        switch self {
        case .sek1:
            return itemLevel == .sek1
        case .sek2:
            return true // 2. Sek includes both sek1 and sek2 items
        }
    }
}
