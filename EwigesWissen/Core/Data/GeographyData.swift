import Foundation

enum GeographyData {
    static let all: [GeographyItem] = sek1Items + sek2Items

    // MARK: - 1. Sek (Basis-Set, schwarz im PDF)
    static let sek1Items: [GeographyItem] = continents + sek1Islands + sek1Mountains + sek1Seas + sek1Rivers + sek1Landscapes + sek1Landmarks

    // MARK: - 2. Sek (Erweiterungs-Set, grün im PDF)
    static let sek2Items: [GeographyItem] = sek2Islands + sek2Mountains + sek2Seas + sek2Rivers + sek2Landmarks

    // MARK: - Kontinente (alle Sek1)
    static let continents: [GeographyItem] = [
        GeographyItem(name: "Europa", type: .continent, latitude: 42.2, longitude: 6.0, toleranceRadiusKm: 2250),
        GeographyItem(name: "Nordamerika", type: .continent, latitude: 39.9, longitude: -102.5, toleranceRadiusKm: 2750),
        GeographyItem(name: "Südamerika", type: .continent, latitude: -10.0, longitude: -70.5, toleranceRadiusKm: 2750),
        GeographyItem(name: "Afrika", type: .continent, latitude: 11.1, longitude: 7.0, toleranceRadiusKm: 3000),
        GeographyItem(name: "Asien", type: .continent, latitude: 41.3, longitude: 67.1, toleranceRadiusKm: 3000),
        GeographyItem(name: "Australien", type: .continent, latitude: -24.1, longitude: 122.7, toleranceRadiusKm: 2000),
        GeographyItem(name: "Antarktis", type: .continent, latitude: -71.5, longitude: -3.8, toleranceRadiusKm: 3000),
    ]

    // MARK: - Inseln / Halbinseln Sek1 (1-15)
    static let sek1Islands: [GeographyItem] = [
        GeographyItem(name: "Grönland", type: .island, latitude: 64.1, longitude: -44.3, toleranceRadiusKm: 2300),
        GeographyItem(name: "Island", type: .island, latitude: 55.0, longitude: -26.3, toleranceRadiusKm: 550),
        GeographyItem(name: "Madagaskar", type: .island, latitude: -16.3, longitude: 35.9, toleranceRadiusKm: 800),
        GeographyItem(name: "Grossbritannien", type: .island, latitude: 55.0, longitude: 5.5, toleranceRadiusKm: 1300),
        GeographyItem(name: "Neuseeland", type: .island, latitude: -41.7, longitude: 154.6, toleranceRadiusKm: 1250),
        GeographyItem(name: "Japan", type: .island, latitude: 35.0, longitude: 121.5, toleranceRadiusKm: 1100),
        GeographyItem(name: "Neuguinea", type: .island, latitude: -5.1, longitude: 130.6, toleranceRadiusKm: 1100),
        GeographyItem(name: "Borneo", type: .island, latitude: 1.0, longitude: 103.8, toleranceRadiusKm: 750),
        GeographyItem(name: "Sumatra", type: .island, latitude: 0.1, longitude: 89.9, toleranceRadiusKm: 900),
        GeographyItem(name: "Indien", type: .peninsula, latitude: 16.8, longitude: 67.2, toleranceRadiusKm: 1350),
        GeographyItem(name: "Arabische Halbinsel", type: .peninsula, latitude: 19.4, longitude: 35.3, toleranceRadiusKm: 1250),
        GeographyItem(name: "Iberische Halbinsel", type: .peninsula, latitude: 33.8, longitude: -13.9, toleranceRadiusKm: 650),
        GeographyItem(name: "Skandinavien", type: .peninsula, latitude: 54.4, longitude: 5.1, toleranceRadiusKm: 1150),
        GeographyItem(name: "Korea", type: .peninsula, latitude: 34.1, longitude: 113.0, toleranceRadiusKm: 600),
        GeographyItem(name: "Italien", type: .peninsula, latitude: 35.0, longitude: 3.3, toleranceRadiusKm: 600),
    ]

    // MARK: - Inseln / Halbinseln Sek2 (16-22, grün)
    static let sek2Islands: [GeographyItem] = [
        GeographyItem(name: "Antillen", type: .island, latitude: 17.1, longitude: -79.0, toleranceRadiusKm: 1500, level: .sek2),
        GeographyItem(name: "Sri Lanka", type: .island, latitude: 5.9, longitude: 70.7, toleranceRadiusKm: 200, level: .sek2),
        GeographyItem(name: "Malediven", type: .island, latitude: 2.7, longitude: 62.9, toleranceRadiusKm: 450, level: .sek2),
        GeographyItem(name: "Balearen", type: .island, latitude: 32.7, longitude: -6.5, toleranceRadiusKm: 200, level: .sek2),
        GeographyItem(name: "Kanarische Inseln", type: .island, latitude: 23.7, longitude: -25.3, toleranceRadiusKm: 350, level: .sek2),
        GeographyItem(name: "Kreta", type: .island, latitude: 29.2, longitude: 14.4, toleranceRadiusKm: 200, level: .sek2),
        GeographyItem(name: "Sizilien", type: .island, latitude: -47.5, longitude: -36.3, toleranceRadiusKm: 200, level: .sek2),
    ]

    // MARK: - Gebirge Sek1
    static let sek1Mountains: [GeographyItem] = [
        GeographyItem(name: "Alpen", type: .mountain, latitude: 38.5, longitude: -0.5, toleranceRadiusKm: 600),
        GeographyItem(name: "Rocky Mountains", type: .mountain, latitude: 40.7, longitude: -115.2, toleranceRadiusKm: 2300),
        GeographyItem(name: "Anden", type: .mountain, latitude: -15.1, longitude: -80.6, toleranceRadiusKm: 3000),
        GeographyItem(name: "Himalaya", type: .mountain, latitude: 26.0, longitude: 72.3, toleranceRadiusKm: 1350),
        GeographyItem(name: "Atlasgebirge", type: .mountain, latitude: 27.7, longitude: -9.8, toleranceRadiusKm: 850),
        GeographyItem(name: "Australische Alpen", type: .mountain, latitude: -29.8, longitude: 134.1, toleranceRadiusKm: 1400),
    ]

    // MARK: - Gebirge Sek2 (grün)
    static let sek2Mountains: [GeographyItem] = [
        GeographyItem(name: "Ural", type: .mountain, latitude: 49.0, longitude: 43.0, toleranceRadiusKm: 1400, level: .sek2),
        GeographyItem(name: "Appalachen", type: .mountain, latitude: 33.5, longitude: -84.2, toleranceRadiusKm: 1500, level: .sek2),
    ]

    // MARK: - Meere / Ozeane Sek1 (A-K)
    static let sek1Seas: [GeographyItem] = [
        GeographyItem(name: "Atlantik", type: .sea, latitude: 19.3, longitude: -50.8, toleranceRadiusKm: 3000),
        GeographyItem(name: "Pazifik", type: .sea, latitude: 2.0, longitude: -140.4, toleranceRadiusKm: 3000),
        GeographyItem(name: "Indischer Ozean", type: .sea, latitude: -17.3, longitude: 66.5, toleranceRadiusKm: 3000),
        GeographyItem(name: "Schwarzes Meer", type: .sea, latitude: 36.2, longitude: 24.5, toleranceRadiusKm: 550),
        GeographyItem(name: "Mittelmeer", type: .sea, latitude: 30.3, longitude: 6.9, toleranceRadiusKm: 1150),
        GeographyItem(name: "Rotes Meer", type: .sea, latitude: 17.5, longitude: 29.4, toleranceRadiusKm: 1050),
        GeographyItem(name: "Nördliches Eismeer", type: .sea, latitude: 71.1, longitude: 3.8, toleranceRadiusKm: 3000),
        GeographyItem(name: "Karibik", type: .sea, latitude: 16.3, longitude: -88.8, toleranceRadiusKm: 1500),
        GeographyItem(name: "Nordsee", type: .sea, latitude: 47.0, longitude: -5.1, toleranceRadiusKm: 900),
        GeographyItem(name: "Ostsee", type: .sea, latitude: 48.9, longitude: 9.9, toleranceRadiusKm: 750),
    ]

    // MARK: - Seen Sek2 (grün: L, M, N)
    static let sek2Seas: [GeographyItem] = [
        GeographyItem(name: "Kaspisches Meer", type: .lake, latitude: 35.3, longitude: 39.2, toleranceRadiusKm: 700, level: .sek2),
        GeographyItem(name: "Titicacasee", type: .lake, latitude: -14.5, longitude: -78.7, toleranceRadiusKm: 450, level: .sek2),
        GeographyItem(name: "Baikalsee", type: .lake, latitude: 46.7, longitude: 89.8, toleranceRadiusKm: 450, level: .sek2),
    ]

    // MARK: - Flüsse Sek1 (a-g)
    static let sek1Rivers: [GeographyItem] = [
        GeographyItem(name: "Mississippi", type: .river, latitude: 35.3, longitude: -96.6, toleranceRadiusKm: 1500),
        GeographyItem(name: "Nil", type: .river, latitude: 13.0, longitude: 24.8, toleranceRadiusKm: 2000),
        GeographyItem(name: "Amazonas", type: .river, latitude: -3.9, longitude: -74.7, toleranceRadiusKm: 1600),
        GeographyItem(name: "Wolga", type: .river, latitude: 44.6, longitude: 29.1, toleranceRadiusKm: 1450),
        GeographyItem(name: "Murray River", type: .river, latitude: -34.3, longitude: 128.0, toleranceRadiusKm: 600),
        GeographyItem(name: "Huang Ho", type: .river, latitude: 32.1, longitude: 95.2, toleranceRadiusKm: 1350),
        GeographyItem(name: "Ganges", type: .river, latitude: 24.0, longitude: 73.0, toleranceRadiusKm: 1050),
    ]

    // MARK: - Flüsse Sek2 (grün: h-p)
    static let sek2Rivers: [GeographyItem] = [
        GeographyItem(name: "Donau", type: .river, latitude: 38.6, longitude: 12.8, toleranceRadiusKm: 1000, level: .sek2),
        GeographyItem(name: "Mackenzie", type: .river, latitude: 59.2, longitude: -117.5, toleranceRadiusKm: 1000, level: .sek2),
        GeographyItem(name: "Kongo", type: .river, latitude: -5.4, longitude: 11.9, toleranceRadiusKm: 1050, level: .sek2),
        GeographyItem(name: "Rhein", type: .river, latitude: 41.6, longitude: -2.7, toleranceRadiusKm: 500, level: .sek2),
        GeographyItem(name: "Indus", type: .river, latitude: 25.5, longitude: 59.3, toleranceRadiusKm: 1000, level: .sek2),
        GeographyItem(name: "Paraná", type: .river, latitude: -23.9, longitude: -59.8, toleranceRadiusKm: 1200, level: .sek2),
        GeographyItem(name: "Niger", type: .river, latitude: 8.0, longitude: -11.7, toleranceRadiusKm: 1250, level: .sek2),
        GeographyItem(name: "Colorado", type: .river, latitude: 34.4, longitude: -115.7, toleranceRadiusKm: 900, level: .sek2),
    ]

    // MARK: - Landschaften Sek1
    static let sek1Landscapes: [GeographyItem] = [
        GeographyItem(name: "Alaska", type: .landscape, latitude: 60.5, longitude: -140.5, toleranceRadiusKm: 1800),
        GeographyItem(name: "Sibirien", type: .landscape, latitude: 52.9, longitude: 81.1, toleranceRadiusKm: 2500),
        GeographyItem(name: "Sahara", type: .landscape, latitude: 20.8, longitude: 0.7, toleranceRadiusKm: 2400),
        GeographyItem(name: "Amazonien", type: .landscape, latitude: -6.3, longitude: -71.6, toleranceRadiusKm: 1950),
        GeographyItem(name: "Feuerland", type: .landscape, latitude: -45.3, longitude: -79.0, toleranceRadiusKm: 1550),
    ]

    // MARK: - Weltwunder / Rekorde Sek1
    static let sek1Landmarks: [GeographyItem] = [
        GeographyItem(name: "Grand Canyon", type: .landmark, latitude: 31.8, longitude: -120.0, toleranceRadiusKm: 850),
        GeographyItem(name: "Pyramiden", type: .landmark, latitude: 25.8, longitude: 19.2, toleranceRadiusKm: 400),
        GeographyItem(name: "Chinesische Mauer", type: .landmark, latitude: 37.7, longitude: 97.4, toleranceRadiusKm: 1750),
        GeographyItem(name: "Angel Falls", type: .landmark, latitude: 5.0, longitude: -69.1, toleranceRadiusKm: 700),
        GeographyItem(name: "Ayers Rock", type: .landmark, latitude: -20.6, longitude: 113.2, toleranceRadiusKm: 600),
        GeographyItem(name: "Mt. Everest", type: .landmark, latitude: 24.3, longitude: 78.0, toleranceRadiusKm: 400),
        GeographyItem(name: "Marianengraben", type: .landmark, latitude: 19.6, longitude: 123.9, toleranceRadiusKm: 1200),
        GeographyItem(name: "Panamakanal", type: .landmark, latitude: 7.4, longitude: -89.6, toleranceRadiusKm: 500),
    ]

    // MARK: - Weltwunder / Rekorde Sek2 (grün)
    static let sek2Landmarks: [GeographyItem] = [
        GeographyItem(name: "Galapagos", type: .landmark, latitude: -1.0, longitude: -100.5, toleranceRadiusKm: 550, level: .sek2),
    ]
}
