import SwiftUI
import MapKit

@Observable
final class GeographyLearningViewModel {
    private let dataService = DataService.shared

    var items: [GeographyItem] = []
    var selectedType: GeographyType? = nil
    var schoolLevel: SchoolLevel = .sek1

    var filteredItems: [GeographyItem] {
        if let type = selectedType {
            return items.filter { $0.type == type }
        }
        return items
    }

    var availableTypes: [GeographyType] {
        let types = Set(items.map(\.type))
        return GeographyType.allCases.filter { types.contains($0) }
    }

    var cameraPosition: MapCameraPosition {
        .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.0, longitude: 14.0),
            span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 40)
        ))
    }

    func loadItems(for level: SchoolLevel) {
        schoolLevel = level
        items = dataService.geographyItems(for: level)
    }

    func selectType(_ type: GeographyType?) {
        selectedType = type
    }
}
