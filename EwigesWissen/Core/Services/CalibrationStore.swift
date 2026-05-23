import Foundation
import CoreLocation

enum CalibrationMap: String, CaseIterable, Identifiable {
    case apple
    case atlas

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .apple: return "Apple Karten"
        case .atlas: return "Schulatlas"
        }
    }
}

@Observable
final class CalibrationStore {
    static let shared = CalibrationStore()

    private let key = "geographyCalibrationOverrides_v2"
    private var overrides: [String: [Double]]

    private init() {
        if let raw = UserDefaults.standard.dictionary(forKey: key) as? [String: [Double]] {
            overrides = raw
        } else {
            overrides = [:]
        }
    }

    func override(for itemId: String, on map: CalibrationMap) -> CLLocationCoordinate2D? {
        guard let pair = overrides[storageKey(itemId, map)], pair.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: pair[0], longitude: pair[1])
    }

    func setOverride(for itemId: String, on map: CalibrationMap, latitude: Double, longitude: Double) {
        overrides[storageKey(itemId, map)] = [latitude, longitude]
        persist()
    }

    func clearOverride(for itemId: String, on map: CalibrationMap) {
        overrides.removeValue(forKey: storageKey(itemId, map))
        persist()
    }

    func clearAll(on map: CalibrationMap) {
        let prefix = "\(map.rawValue):"
        overrides = overrides.filter { !$0.key.hasPrefix(prefix) }
        persist()
    }

    func clearAll() {
        overrides.removeAll()
        persist()
    }

    func calibratedCount(on map: CalibrationMap) -> Int {
        let prefix = "\(map.rawValue):"
        return overrides.keys.filter { $0.hasPrefix(prefix) }.count
    }

    private func storageKey(_ itemId: String, _ map: CalibrationMap) -> String {
        "\(map.rawValue):\(itemId)"
    }

    private func persist() {
        UserDefaults.standard.set(overrides, forKey: key)
    }
}

extension MapStyle {
    var calibrationMap: CalibrationMap {
        self == .stummeKarte ? .atlas : .apple
    }
}
