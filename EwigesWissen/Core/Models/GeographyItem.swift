import Foundation
import CoreLocation
import MapKit

enum GeographyRegion: String, Codable, CaseIterable, Identifiable {
    case world
    case northAmerica

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .world: return "Welt"
        case .northAmerica: return "Nordamerika"
        }
    }

    var iconName: String {
        switch self {
        case .world: return "globe"
        case .northAmerica: return "globe.americas.fill"
        }
    }

    var cameraRegion: MKCoordinateRegion {
        switch self {
        case .world:
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 20.0, longitude: 10.0),
                span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 160)
            )
        case .northAmerica:
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 45.0, longitude: -100.0),
                span: MKCoordinateSpan(latitudeDelta: 70, longitudeDelta: 90)
            )
        }
    }
}

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
    let atlasLatitude: Double?
    let atlasLongitude: Double?
    let toleranceRadiusKm: Double
    let level: SchoolLevel
    let regions: Set<GeographyRegion>
    let naMapX: Double?
    let naMapY: Double?

    /// Real-world coordinate, used on the Apple map.
    var originalCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Hand-tuned coordinate for the öbv "Stumme Karte" (Robinson projection).
    /// The Robinson params don't match real coordinates 1:1, so each item carries
    /// a separately tuned value. Falls back to the real coordinate when none is set.
    var atlasCoordinate: CLLocationCoordinate2D {
        guard let atlasLatitude, let atlasLongitude else { return originalCoordinate }
        return CLLocationCoordinate2D(latitude: atlasLatitude, longitude: atlasLongitude)
    }

    func coordinate(for map: CalibrationMap) -> CLLocationCoordinate2D {
        if let override = CalibrationStore.shared.override(for: id, on: map) {
            return override
        }
        switch map {
        case .apple: return originalCoordinate
        case .atlas: return atlasCoordinate
        }
    }

    func isCalibrated(on map: CalibrationMap) -> Bool {
        CalibrationStore.shared.override(for: id, on: map) != nil
    }

    init(
        name: String,
        type: GeographyType,
        latitude: Double,
        longitude: Double,
        atlasLatitude: Double? = nil,
        atlasLongitude: Double? = nil,
        toleranceRadiusKm: Double = 100,
        level: SchoolLevel = .sek1,
        regions: Set<GeographyRegion> = [.world],
        naMapX: Double? = nil,
        naMapY: Double? = nil
    ) {
        self.id = "\(type.rawValue)-\(name)"
        self.name = name
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.atlasLatitude = atlasLatitude
        self.atlasLongitude = atlasLongitude
        self.toleranceRadiusKm = toleranceRadiusKm
        self.level = level
        self.regions = regions
        self.naMapX = naMapX
        self.naMapY = naMapY
    }

    /// Fractional pixel position (0-1) on the d-maps Eckert VI North America
    /// map (amnord09). Hand-tuned starting values; can be calibrated later.
    var naMapPoint: CGPoint? {
        guard let x = naMapX, let y = naMapY else { return nil }
        return CGPoint(x: x, y: y)
    }

    /// Check if a placed pin is within the tolerance radius
    func isCorrectPlacement(at placedCoordinate: CLLocationCoordinate2D, on map: CalibrationMap) -> Bool {
        distanceInKm(to: placedCoordinate, on: map) <= toleranceRadiusKm
    }

    /// Distance in km from the correct location (per-map) to a given coordinate
    func distanceInKm(to placedCoordinate: CLLocationCoordinate2D, on map: CalibrationMap) -> Double {
        let correct = coordinate(for: map)
        let correctLocation = CLLocation(latitude: correct.latitude, longitude: correct.longitude)
        let placedLocation = CLLocation(latitude: placedCoordinate.latitude, longitude: placedCoordinate.longitude)
        return correctLocation.distance(from: placedLocation) / 1000.0
    }
}
