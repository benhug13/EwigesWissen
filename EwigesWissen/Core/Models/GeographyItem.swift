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
    case country = "Land"
    case city = "Stadt"
    case mountain = "Gebirge"
    case river = "Fluss"
    case sea = "Meer/Ozean"
    case lake = "See"
    case island = "Insel"
    case peninsula = "Halbinsel"
    case landscape = "Landschaft"
    case landmark = "Weltwunder/Rekord"
    case history = "Geschichte"

    var id: String { rawValue }
    var displayName: String { rawValue }

    /// Grouping category for display
    var category: String {
        switch self {
        case .river, .sea, .lake: return "Gewässer"
        case .island, .peninsula: return "Inseln & Halbinseln"
        case .continent: return "Kontinente"
        case .country: return "Länder"
        case .city: return "Städte"
        case .mountain: return "Gebirge"
        case .landscape: return "Landschaften"
        case .landmark: return "Weltwunder/Rekorde"
        case .history: return "Geschichte"
        }
    }

    /// Order for category sorting
    var categoryOrder: Int {
        switch self {
        case .continent: return 0
        case .country: return 1
        case .city: return 2
        case .river, .sea, .lake: return 3
        case .mountain: return 4
        case .island, .peninsula: return 5
        case .landscape: return 6
        case .landmark: return 7
        case .history: return 8
        }
    }

    var iconName: String {
        switch self {
        case .continent: return "globe"
        case .country: return "flag.fill"
        case .city: return "building.2.fill"
        case .mountain: return "mountain.2.fill"
        case .river: return "water.waves"
        case .sea: return "water.waves.and.arrow.down"
        case .lake: return "drop.fill"
        case .island: return "leaf.fill"
        case .peninsula: return "map.fill"
        case .landscape: return "photo.fill"
        case .landmark: return "star.circle.fill"
        case .history: return "scroll.fill"
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
    let naToleranceRadiusKm: Double?
    let questionPrompt: String?

    /// Manche Begriffe stehen auf der Schulatlas-Karte an ZWEI Stellen — die Taiga
    /// etwa in Nordamerika und in Sibirien. Dann zählt jede der beiden als richtig.
    let secondLatitude: Double?
    let secondLongitude: Double?
    let secondAtlasLatitude: Double?
    let secondAtlasLongitude: Double?

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
        case .naAtlas: return originalCoordinate
        }
    }

    /// Zweiter gültiger Ort, falls der Begriff auf der Karte zweimal vorkommt.
    func secondCoordinate(for map: CalibrationMap) -> CLLocationCoordinate2D? {
        guard let secondLatitude, let secondLongitude else { return nil }
        switch map {
        case .apple, .naAtlas:
            return CLLocationCoordinate2D(latitude: secondLatitude, longitude: secondLongitude)
        case .atlas:
            guard let secondAtlasLatitude, let secondAtlasLongitude else {
                return CLLocationCoordinate2D(latitude: secondLatitude, longitude: secondLongitude)
            }
            return CLLocationCoordinate2D(latitude: secondAtlasLatitude, longitude: secondAtlasLongitude)
        }
    }

    /// Alle Orte, die als richtige Antwort gelten.
    func targets(for map: CalibrationMap) -> [CLLocationCoordinate2D] {
        guard let second = secondCoordinate(for: map) else { return [coordinate(for: map)] }
        return [coordinate(for: map), second]
    }

    /// Der Ort, der der gesetzten Nadel am nächsten liegt — für die Auflösung nach
    /// der Antwort, damit bei zwei richtigen Stellen die passende markiert wird.
    func nearestCoordinate(for map: CalibrationMap, to placed: CLLocationCoordinate2D?) -> CLLocationCoordinate2D {
        let all = targets(for: map)
        guard let placed, all.count > 1 else { return all[0] }
        let pin = CLLocation(latitude: placed.latitude, longitude: placed.longitude)
        return all.min { a, b in
            CLLocation(latitude: a.latitude, longitude: a.longitude).distance(from: pin)
                < CLLocation(latitude: b.latitude, longitude: b.longitude).distance(from: pin)
        } ?? all[0]
    }

    func isCalibrated(on map: CalibrationMap) -> Bool {
        if map == .naAtlas {
            return CalibrationStore.shared.fractionOverride(for: id, on: map) != nil
        }
        return CalibrationStore.shared.override(for: id, on: map) != nil
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
        naMapY: Double? = nil,
        naToleranceRadiusKm: Double? = nil,
        questionPrompt: String? = nil,
        secondLatitude: Double? = nil,
        secondLongitude: Double? = nil,
        secondAtlasLatitude: Double? = nil,
        secondAtlasLongitude: Double? = nil
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
        self.naToleranceRadiusKm = naToleranceRadiusKm
        self.questionPrompt = questionPrompt
        self.secondLatitude = secondLatitude
        self.secondLongitude = secondLongitude
        self.secondAtlasLatitude = secondAtlasLatitude
        self.secondAtlasLongitude = secondAtlasLongitude
    }

    /// Init with explicit id — used to build instances from user-saved
    /// CustomGeographyItem records (which carry a stable UUID).
    init(
        id: String,
        name: String,
        type: GeographyType,
        latitude: Double,
        longitude: Double,
        atlasLatitude: Double?,
        atlasLongitude: Double?,
        toleranceRadiusKm: Double,
        level: SchoolLevel,
        regions: Set<GeographyRegion>,
        naMapX: Double?,
        naMapY: Double?,
        naToleranceRadiusKm: Double? = nil,
        questionPrompt: String? = nil,
        secondLatitude: Double? = nil,
        secondLongitude: Double? = nil,
        secondAtlasLatitude: Double? = nil,
        secondAtlasLongitude: Double? = nil
    ) {
        self.id = id
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
        self.naToleranceRadiusKm = naToleranceRadiusKm
        self.questionPrompt = questionPrompt
        self.secondLatitude = secondLatitude
        self.secondLongitude = secondLongitude
        self.secondAtlasLatitude = secondAtlasLatitude
        self.secondAtlasLongitude = secondAtlasLongitude
    }

    /// Toleranzradius für NA-Quiz: falls explizit gesetzt, sonst Standard.
    var resolvedNAToleranceKm: Double {
        naToleranceRadiusKm ?? toleranceRadiusKm
    }

    /// Quizfrage: benutzerdefinierte Formulierung wenn vorhanden, sonst "Wo liegt X?".
    var quizQuestion: String {
        questionPrompt ?? "Wo liegt \(name)?"
    }

    var isCustom: Bool { id.hasPrefix("custom-") }

    /// Fractional pixel position (0-1) on the d-maps Eckert VI North America
    /// map (amnord09). Hand-tuned baseline; user can override via the
    /// calibration screen.
    var naMapPoint: CGPoint? {
        if let override = CalibrationStore.shared.fractionOverride(for: id, on: .naAtlas) {
            return override
        }
        guard let x = naMapX, let y = naMapY else { return nil }
        return CGPoint(x: x, y: y)
    }

    /// Check if a placed pin is within the tolerance radius
    func isCorrectPlacement(at placedCoordinate: CLLocationCoordinate2D, on map: CalibrationMap) -> Bool {
        distanceInKm(to: placedCoordinate, on: map) <= toleranceRadiusKm
    }

    /// Distance in km from the correct location (per-map) to a given coordinate
    /// Bei zwei gültigen Orten zählt der nähere — sonst wäre eine richtige Antwort
    /// auf der zweiten Stelle als Fehler gewertet worden.
    func distanceInKm(to placedCoordinate: CLLocationCoordinate2D, on map: CalibrationMap) -> Double {
        let placedLocation = CLLocation(latitude: placedCoordinate.latitude, longitude: placedCoordinate.longitude)
        return targets(for: map)
            .map { CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: placedLocation) / 1000.0 }
            .min() ?? .greatestFiniteMagnitude
    }
}
