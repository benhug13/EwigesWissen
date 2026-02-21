import SwiftUI
import MapKit

@MainActor @Observable
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

    /// Unique categories available, sorted by order
    var availableCategories: [(name: String, types: [GeographyType], icon: String)] {
        let types = Set(items.map(\.type))
        let allCategories: [(name: String, types: [GeographyType], icon: String)] = [
            ("Kontinente", [.continent], "globe"),
            ("Gewässer", [.river, .sea, .lake], "water.waves"),
            ("Gebirge", [.mountain], "mountain.2.fill"),
            ("Inseln & Halbinseln", [.island, .peninsula], "leaf.fill"),
            ("Landschaften", [.landscape], "photo.fill"),
            ("Weltwunder/Rekorde", [.landmark], "star.circle.fill"),
        ]
        return allCategories.filter { cat in
            cat.types.contains(where: { types.contains($0) })
        }
    }

    var selectedCategory: [GeographyType]? = nil

    var filteredByCategory: [GeographyItem] {
        if let category = selectedCategory {
            return items.filter { category.contains($0.type) }
        }
        return items
    }

    func selectCategory(_ types: [GeographyType]?) {
        selectedCategory = types
    }

    var cameraPosition: MapCameraPosition {
        .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.0, longitude: 10.0),
            span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 160)
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
