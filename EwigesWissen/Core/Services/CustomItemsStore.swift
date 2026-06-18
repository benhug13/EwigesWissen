import Foundation

struct CustomGeographyItem: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var typeRaw: String
    var levelRaw: String
    var regionsRaw: [String]

    var latitude: Double
    var longitude: Double
    var atlasLatitude: Double?
    var atlasLongitude: Double?
    var naMapX: Double?
    var naMapY: Double?

    var toleranceRadiusKm: Double

    var type: GeographyType {
        get { GeographyType(rawValue: typeRaw) ?? .landmark }
        set { typeRaw = newValue.rawValue }
    }

    var level: SchoolLevel {
        get { SchoolLevel(rawValue: levelRaw) ?? .sek1 }
        set { levelRaw = newValue.rawValue }
    }

    var regions: Set<GeographyRegion> {
        get { Set(regionsRaw.compactMap { GeographyRegion(rawValue: $0) }) }
        set { regionsRaw = newValue.map { $0.rawValue }.sorted() }
    }

    /// Item id used in the wider app (ProgressService, CalibrationStore).
    /// Stable across launches because UUID is persisted.
    var geographyItemId: String { "custom-\(id.uuidString)" }

    func toGeographyItem() -> GeographyItem {
        GeographyItem(
            id: geographyItemId,
            name: name,
            type: type,
            latitude: latitude,
            longitude: longitude,
            atlasLatitude: atlasLatitude,
            atlasLongitude: atlasLongitude,
            toleranceRadiusKm: toleranceRadiusKm,
            level: level,
            regions: regions.isEmpty ? [.world] : regions,
            naMapX: naMapX,
            naMapY: naMapY
        )
    }

    static func new(name: String = "", type: GeographyType = .landmark) -> CustomGeographyItem {
        CustomGeographyItem(
            id: UUID(),
            name: name,
            typeRaw: type.rawValue,
            levelRaw: SchoolLevel.sek1.rawValue,
            regionsRaw: [GeographyRegion.world.rawValue],
            latitude: 47.0,
            longitude: 8.0,
            atlasLatitude: nil,
            atlasLongitude: nil,
            naMapX: nil,
            naMapY: nil,
            toleranceRadiusKm: 300
        )
    }
}

@Observable
final class CustomItemsStore {
    static let shared = CustomItemsStore()

    private let key = "customGeographyItems_v1"
    private(set) var items: [CustomGeographyItem]

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([CustomGeographyItem].self, from: data) {
            items = decoded
        } else {
            items = []
        }
    }

    func upsert(_ item: CustomGeographyItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
        persist()
    }

    func delete(id: UUID) {
        items.removeAll { $0.id == id }
        persist()
    }

    func item(id: UUID) -> CustomGeographyItem? {
        items.first { $0.id == id }
    }

    func geographyItems(for level: SchoolLevel) -> [GeographyItem] {
        items.filter { level.includes($0.level) }.map { $0.toGeographyItem() }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
