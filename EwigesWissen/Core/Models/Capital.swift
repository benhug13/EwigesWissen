import Foundation
import CoreLocation

struct Capital: Identifiable, Hashable {
    let id: String
    let country: String
    let capital: String
    let latitude: Double
    let longitude: Double
    let level: SchoolLevel

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(country: String, capital: String, latitude: Double, longitude: Double, level: SchoolLevel = .sek1) {
        self.id = "\(country)-\(capital)"
        self.country = country
        self.capital = capital
        self.latitude = latitude
        self.longitude = longitude
        self.level = level
    }
}
