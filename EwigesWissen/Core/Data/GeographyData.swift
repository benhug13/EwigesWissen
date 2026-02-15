import Foundation

enum GeographyData {
    static let all: [GeographyItem] = sek1Items + sek2Items

    // MARK: - 1. Sek (Basis-Set)
    static let sek1Items: [GeographyItem] = [
        // Berge
        GeographyItem(name: "Mont Blanc", type: .mountain, latitude: 45.8326, longitude: 6.8652, toleranceRadiusKm: 50),
        GeographyItem(name: "Matterhorn", type: .mountain, latitude: 45.9763, longitude: 7.6586, toleranceRadiusKm: 50),
        GeographyItem(name: "Ätna", type: .mountain, latitude: 37.7510, longitude: 14.9934, toleranceRadiusKm: 50),
        GeographyItem(name: "Vesuv", type: .mountain, latitude: 40.8210, longitude: 14.4260, toleranceRadiusKm: 50),

        // Flüsse
        GeographyItem(name: "Rhein", type: .river, latitude: 50.3569, longitude: 7.5890, toleranceRadiusKm: 80),
        GeographyItem(name: "Donau", type: .river, latitude: 47.8120, longitude: 13.0460, toleranceRadiusKm: 80),
        GeographyItem(name: "Themse", type: .river, latitude: 51.5074, longitude: -0.0760, toleranceRadiusKm: 60),
        GeographyItem(name: "Seine", type: .river, latitude: 48.8600, longitude: 2.3470, toleranceRadiusKm: 60),

        // Meere
        GeographyItem(name: "Mittelmeer", type: .sea, latitude: 35.0, longitude: 18.0, toleranceRadiusKm: 300),
        GeographyItem(name: "Nordsee", type: .sea, latitude: 56.0, longitude: 3.0, toleranceRadiusKm: 200),
        GeographyItem(name: "Ostsee", type: .sea, latitude: 58.0, longitude: 20.0, toleranceRadiusKm: 200),
        GeographyItem(name: "Schwarzes Meer", type: .sea, latitude: 43.0, longitude: 35.0, toleranceRadiusKm: 200),
        GeographyItem(name: "Atlantischer Ozean", type: .sea, latitude: 45.0, longitude: -20.0, toleranceRadiusKm: 400),

        // Seen
        GeographyItem(name: "Bodensee", type: .lake, latitude: 47.6300, longitude: 9.3750, toleranceRadiusKm: 30),
        GeographyItem(name: "Genfersee", type: .lake, latitude: 46.4530, longitude: 6.5680, toleranceRadiusKm: 30),
        GeographyItem(name: "Gardasee", type: .lake, latitude: 45.6500, longitude: 10.6330, toleranceRadiusKm: 30),

        // Inseln
        GeographyItem(name: "Sizilien", type: .island, latitude: 37.5999, longitude: 14.0154, toleranceRadiusKm: 80),
        GeographyItem(name: "Sardinien", type: .island, latitude: 40.1209, longitude: 9.0129, toleranceRadiusKm: 80),
        GeographyItem(name: "Kreta", type: .island, latitude: 35.2401, longitude: 24.8093, toleranceRadiusKm: 60),
    ]

    // MARK: - 2. Sek (Erweiterungs-Set)
    static let sek2Items: [GeographyItem] = [
        // Berge
        GeographyItem(name: "Elbrus", type: .mountain, latitude: 43.3499, longitude: 42.4453, toleranceRadiusKm: 60, level: .sek2),
        GeographyItem(name: "Olymp", type: .mountain, latitude: 40.0859, longitude: 22.3583, toleranceRadiusKm: 50, level: .sek2),

        // Flüsse
        GeographyItem(name: "Wolga", type: .river, latitude: 56.3269, longitude: 44.0065, toleranceRadiusKm: 100, level: .sek2),
        GeographyItem(name: "Po", type: .river, latitude: 44.9500, longitude: 11.3300, toleranceRadiusKm: 60, level: .sek2),
        GeographyItem(name: "Ebro", type: .river, latitude: 41.3850, longitude: 0.5000, toleranceRadiusKm: 80, level: .sek2),

        // Meerengen
        GeographyItem(name: "Bosporus", type: .strait, latitude: 41.1194, longitude: 29.0750, toleranceRadiusKm: 30, level: .sek2),
        GeographyItem(name: "Strasse von Gibraltar", type: .strait, latitude: 35.9667, longitude: -5.5000, toleranceRadiusKm: 40, level: .sek2),

        // Halbinseln
        GeographyItem(name: "Iberische Halbinsel", type: .peninsula, latitude: 40.0, longitude: -4.0, toleranceRadiusKm: 200, level: .sek2),
        GeographyItem(name: "Balkanhalbinsel", type: .peninsula, latitude: 42.0, longitude: 22.0, toleranceRadiusKm: 200, level: .sek2),
        GeographyItem(name: "Skandinavische Halbinsel", type: .peninsula, latitude: 63.0, longitude: 16.0, toleranceRadiusKm: 250, level: .sek2),

        // Inseln
        GeographyItem(name: "Korsika", type: .island, latitude: 42.0396, longitude: 9.0129, toleranceRadiusKm: 50, level: .sek2),
        GeographyItem(name: "Mallorca", type: .island, latitude: 39.6953, longitude: 3.0176, toleranceRadiusKm: 40, level: .sek2),
    ]
}
