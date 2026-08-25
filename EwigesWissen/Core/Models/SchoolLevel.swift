import Foundation

enum SchoolLevel: String, Codable, CaseIterable, Identifiable {
    case sek1 = "1. Sek"
    case sek2 = "2. Sek"
    case sek3 = "3. Sek"

    var id: String { rawValue }

    var displayName: String { rawValue }

    /// Returns whether items of the given level should be included for this school level
    func includes(_ itemLevel: SchoolLevel) -> Bool {
        switch self {
        case .sek1:
            return itemLevel == .sek1
        case .sek2:
            return itemLevel == .sek1 || itemLevel == .sek2
        case .sek3:
            return true // 3. Sek includes sek1, sek2 and sek3 items
        }
    }
}
