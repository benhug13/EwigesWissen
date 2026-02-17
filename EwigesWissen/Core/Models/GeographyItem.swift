import Foundation
import CoreLocation

enum GeographyType: String, Codable, CaseIterable, Identifiable {
    case continent = "Kontinent"
    case mountain = "Gebirge"
    case river = "Fluss"
    case sea = "Meer/Ozean"
    case lake = "See"
    case island = "Insel"
    case peninsula = "Halbinsel"
    case landscape = "Landschaft"
    case landmark = "Weltwunder/Rekord"

    var id: String { rawValue }
    var displayName: String { rawValue }

    /// Grouping category for display
    var category: String {
        switch self {
        case .river, .sea, .lake: return "Gewässer"
        case .island, .peninsula: return "Inseln & Halbinseln"
        case .continent: return "Kontinente"
        case .mountain: return "Gebirge"
        case .landscape: return "Landschaften"
        case .landmark: return "Weltwunder/Rekorde"
        }
    }

    /// Order for category sorting
    var categoryOrder: Int {
        switch self {
        case .continent: return 0
        case .river, .sea, .lake: return 1
        case .mountain: return 2
        case .island, .peninsula: return 3
        case .landscape: return 4
        case .landmark: return 5
        }
    }

    var iconName: String {
        switch self {
        case .continent: return "globe"
        case .mountain: return "mountain.2.fill"
        case .river: return "water.waves"
        case .sea: return "water.waves.and.arrow.down"
        case .lake: return "drop.fill"
        case .island: return "leaf.fill"
        case .peninsula: return "map.fill"
        case .landscape: return "photo.fill"
        case .landmark: return "star.circle.fill"
        }
    }
}

struct GeographyItem: Identifiable, Hashable {
    let id: String
    let name: String
    let type: GeographyType
    let latitude: Double
    let longitude: Double
    let toleranceRadiusKm: Double
    let level: SchoolLevel

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(
        name: String,
        type: GeographyType,
        latitude: Double,
        longitude: Double,
        toleranceRadiusKm: Double = 100,
        level: SchoolLevel = .sek1
    ) {
        self.id = "\(type.rawValue)-\(name)"
        self.name = name
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.toleranceRadiusKm = toleranceRadiusKm
        self.level = level
    }

    /// Check if a placed pin is within the tolerance radius
    func isCorrectPlacement(at placedCoordinate: CLLocationCoordinate2D) -> Bool {
        let distance = distanceInKm(to: placedCoordinate)
        return distance <= toleranceRadiusKm
    }

    /// Distance in km from the correct location to a given coordinate
    func distanceInKm(to coordinate: CLLocationCoordinate2D) -> Double {
        let correctLocation = CLLocation(latitude: latitude, longitude: longitude)
        let placedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return correctLocation.distance(from: placedLocation) / 1000.0
    }
}
