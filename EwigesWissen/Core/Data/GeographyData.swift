import Foundation

enum GeographyData {
    static let all: [GeographyItem] = sek1Items + sek2Items

    // MARK: - 1. Sek (Basis-Set, schwarz im PDF)
    static let sek1Items: [GeographyItem] = continents + sek1Islands + sek1Mountains + sek1Seas + sek1Rivers + sek1Landscapes + sek1Landmarks

    // MARK: - 2. Sek (Erweiterungs-Set, grün im PDF)
    static let sek2Items: [GeographyItem] = sek2Islands + sek2Mountains + sek2Seas + sek2Rivers + sek2Landmarks

    // MARK: - Kontinente (alle Sek1)
    static let continents: [GeographyItem] = [
        GeographyItem(name: "Europa", type: .continent, latitude: 54.0, longitude: 15.0, toleranceRadiusKm: 2250),
        GeographyItem(name: "Nordamerika", type: .continent, latitude: 48.0, longitude: -100.0, toleranceRadiusKm: 2750),
        GeographyItem(name: "Südamerika", type: .continent, latitude: -15.0, longitude: -60.0, toleranceRadiusKm: 2750),
        GeographyItem(name: "Afrika", type: .continent, latitude: 7.0, longitude: 21.0, toleranceRadiusKm: 3000),
        GeographyItem(name: "Asien", type: .continent, latitude: 50.0, longitude: 90.0, toleranceRadiusKm: 3000),
        GeographyItem(name: "Australien", type: .continent, latitude: -25.0, longitude: 134.0, toleranceRadiusKm: 2000),
        GeographyItem(name: "Antarktis", type: .continent, latitude: -82.0, longitude: 0.0, toleranceRadiusKm: 3000),
    ]

    // MARK: - Inseln / Halbinseln Sek1 (1-15)
    static let sek1Islands: [GeographyItem] = [
        GeographyItem(name: "Grönland", type: .island, latitude: 72.0, longitude: -40.0, toleranceRadiusKm: 2300),
        GeographyItem(name: "Island", type: .island, latitude: 64.9, longitude: -19.0, toleranceRadiusKm: 550),
        GeographyItem(name: "Madagaskar", type: .island, latitude: -18.8, longitude: 47.0, toleranceRadiusKm: 800),
        GeographyItem(name: "Grossbritannien", type: .island, latitude: 54.0, longitude: -2.0, toleranceRadiusKm: 1300),
        GeographyItem(name: "Neuseeland", type: .island, latitude: -41.0, longitude: 174.0, toleranceRadiusKm: 1250),
        GeographyItem(name: "Japan", type: .island, latitude: 36.0, longitude: 138.0, toleranceRadiusKm: 1100),
        GeographyItem(name: "Neuguinea", type: .island, latitude: -6.0, longitude: 141.0, toleranceRadiusKm: 1100),
        GeographyItem(name: "Borneo", type: .island, latitude: 0.5, longitude: 114.0, toleranceRadiusKm: 750),
        GeographyItem(name: "Sumatra", type: .island, latitude: 0.0, longitude: 102.0, toleranceRadiusKm: 900),
        GeographyItem(name: "Indien", type: .peninsula, latitude: 21.0, longitude: 78.0, toleranceRadiusKm: 1350),
        GeographyItem(name: "Arabische Halbinsel", type: .peninsula, latitude: 25.0, longitude: 45.0, toleranceRadiusKm: 1250),
        GeographyItem(name: "Iberische Halbinsel", type: .peninsula, latitude: 40.0, longitude: -4.0, toleranceRadiusKm: 650),
        GeographyItem(name: "Skandinavien", type: .peninsula, latitude: 63.0, longitude: 16.0, toleranceRadiusKm: 1150),
        GeographyItem(name: "Korea", type: .peninsula, latitude: 38.0, longitude: 127.0, toleranceRadiusKm: 600),
        GeographyItem(name: "Italien", type: .peninsula, latitude: 42.5, longitude: 12.5, toleranceRadiusKm: 600),
    ]

    // MARK: - Inseln / Halbinseln Sek2 (16-22, grün)
    static let sek2Islands: [GeographyItem] = [
        GeographyItem(name: "Antillen", type: .island, latitude: 16.0, longitude: -65.0, toleranceRadiusKm: 1500, level: .sek2),
        GeographyItem(name: "Sri Lanka", type: .island, latitude: 7.5, longitude: 81.0, toleranceRadiusKm: 200, level: .sek2),
        GeographyItem(name: "Malediven", type: .island, latitude: 3.2, longitude: 73.0, toleranceRadiusKm: 450, level: .sek2),
        GeographyItem(name: "Balearen", type: .island, latitude: 39.5, longitude: 3.0, toleranceRadiusKm: 200, level: .sek2),
        GeographyItem(name: "Kanarische Inseln", type: .island, latitude: 28.3, longitude: -15.5, toleranceRadiusKm: 350, level: .sek2),
        GeographyItem(name: "Kreta", type: .island, latitude: 35.2, longitude: 24.8, toleranceRadiusKm: 200, level: .sek2),
        GeographyItem(name: "Sizilien", type: .island, latitude: 37.5, longitude: 14.0, toleranceRadiusKm: 200, level: .sek2),
    ]

    // MARK: - Gebirge Sek1
    static let sek1Mountains: [GeographyItem] = [
        GeographyItem(name: "Alpen", type: .mountain, latitude: 46.5, longitude: 10.0, toleranceRadiusKm: 600),
        GeographyItem(name: "Rocky Mountains", type: .mountain, latitude: 44.0, longitude: -110.0, toleranceRadiusKm: 2300),
        GeographyItem(name: "Anden", type: .mountain, latitude: -15.0, longitude: -72.0, toleranceRadiusKm: 3000),
        GeographyItem(name: "Himalaya", type: .mountain, latitude: 28.0, longitude: 84.0, toleranceRadiusKm: 1350),
        GeographyItem(name: "Atlasgebirge", type: .mountain, latitude: 32.0, longitude: -5.0, toleranceRadiusKm: 850),
        GeographyItem(name: "Australische Alpen", type: .mountain, latitude: -36.0, longitude: 148.0, toleranceRadiusKm: 1400),
    ]

    // MARK: - Gebirge Sek2 (grün)
    static let sek2Mountains: [GeographyItem] = [
        GeographyItem(name: "Ural", type: .mountain, latitude: 60.0, longitude: 60.0, toleranceRadiusKm: 1400, level: .sek2),
        GeographyItem(name: "Appalachen", type: .mountain, latitude: 38.0, longitude: -80.0, toleranceRadiusKm: 1500, level: .sek2),
    ]

    // MARK: - Meere / Ozeane Sek1 (A-K)
    static let sek1Seas: [GeographyItem] = [
        GeographyItem(name: "Atlantik", type: .sea, latitude: 0.0, longitude: -30.0, toleranceRadiusKm: 3000),
        GeographyItem(name: "Pazifik", type: .sea, latitude: 0.0, longitude: -160.0, toleranceRadiusKm: 3000),
        GeographyItem(name: "Indischer Ozean", type: .sea, latitude: -20.0, longitude: 80.0, toleranceRadiusKm: 3000),
        GeographyItem(name: "Schwarzes Meer", type: .sea, latitude: 43.0, longitude: 35.0, toleranceRadiusKm: 550),
        GeographyItem(name: "Mittelmeer", type: .sea, latitude: 38.0, longitude: 17.0, toleranceRadiusKm: 1150),
        GeographyItem(name: "Rotes Meer", type: .sea, latitude: 22.0, longitude: 38.0, toleranceRadiusKm: 1050),
        GeographyItem(name: "Nördliches Eismeer", type: .sea, latitude: 84.0, longitude: 0.0, toleranceRadiusKm: 3000),
        GeographyItem(name: "Karibik", type: .sea, latitude: 15.0, longitude: -75.0, toleranceRadiusKm: 1500),
        GeographyItem(name: "Nordsee", type: .sea, latitude: 56.0, longitude: 3.0, toleranceRadiusKm: 900),
        GeographyItem(name: "Ostsee", type: .sea, latitude: 58.0, longitude: 20.0, toleranceRadiusKm: 750),
    ]

    // MARK: - Seen Sek2 (grün: L, M, N)
    static let sek2Seas: [GeographyItem] = [
        GeographyItem(name: "Kaspisches Meer", type: .lake, latitude: 42.0, longitude: 50.0, toleranceRadiusKm: 700, level: .sek2),
        GeographyItem(name: "Titicacasee", type: .lake, latitude: -15.8, longitude: -69.4, toleranceRadiusKm: 450, level: .sek2),
        GeographyItem(name: "Baikalsee", type: .lake, latitude: 53.5, longitude: 108.0, toleranceRadiusKm: 450, level: .sek2),
    ]

    // MARK: - Flüsse Sek1 (a-g)
    static let sek1Rivers: [GeographyItem] = [
        GeographyItem(name: "Mississippi", type: .river, latitude: 38.0, longitude: -90.0, toleranceRadiusKm: 1500),
        GeographyItem(name: "Nil", type: .river, latitude: 27.0, longitude: 31.0, toleranceRadiusKm: 2000),
        GeographyItem(name: "Amazonas", type: .river, latitude: -3.0, longitude: -60.0, toleranceRadiusKm: 1600),
        GeographyItem(name: "Wolga", type: .river, latitude: 49.0, longitude: 45.0, toleranceRadiusKm: 1450),
        GeographyItem(name: "Murray River", type: .river, latitude: -34.5, longitude: 143.0, toleranceRadiusKm: 600),
        GeographyItem(name: "Huang Ho", type: .river, latitude: 37.0, longitude: 110.0, toleranceRadiusKm: 1350),
        GeographyItem(name: "Ganges", type: .river, latitude: 25.0, longitude: 84.0, toleranceRadiusKm: 1050),
    ]

    // MARK: - Flüsse Sek2 (grün: h-p)
    static let sek2Rivers: [GeographyItem] = [
        GeographyItem(name: "Donau", type: .river, latitude: 45.0, longitude: 22.0, toleranceRadiusKm: 1000, level: .sek2),
        GeographyItem(name: "Mackenzie", type: .river, latitude: 65.0, longitude: -125.0, toleranceRadiusKm: 1000, level: .sek2),
        GeographyItem(name: "Kongo", type: .river, latitude: -2.0, longitude: 22.0, toleranceRadiusKm: 1050, level: .sek2),
        GeographyItem(name: "Rhein", type: .river, latitude: 50.0, longitude: 7.0, toleranceRadiusKm: 500, level: .sek2),
        GeographyItem(name: "Indus", type: .river, latitude: 28.0, longitude: 70.0, toleranceRadiusKm: 1000, level: .sek2),
        GeographyItem(name: "Paraná", type: .river, latitude: -27.0, longitude: -56.0, toleranceRadiusKm: 1200, level: .sek2),
        GeographyItem(name: "Niger", type: .river, latitude: 13.0, longitude: 0.0, toleranceRadiusKm: 1250, level: .sek2),
        GeographyItem(name: "Colorado", type: .river, latitude: 36.0, longitude: -111.0, toleranceRadiusKm: 900, level: .sek2),
    ]

    // MARK: - Landschaften Sek1
    static let sek1Landscapes: [GeographyItem] = [
        GeographyItem(name: "Alaska", type: .landscape, latitude: 64.0, longitude: -150.0, toleranceRadiusKm: 1800),
        GeographyItem(name: "Sibirien", type: .landscape, latitude: 65.0, longitude: 100.0, toleranceRadiusKm: 2500),
        GeographyItem(name: "Sahara", type: .landscape, latitude: 23.0, longitude: 13.0, toleranceRadiusKm: 2400),
        GeographyItem(name: "Amazonien", type: .landscape, latitude: -3.0, longitude: -60.0, toleranceRadiusKm: 1950),
        GeographyItem(name: "Feuerland", type: .landscape, latitude: -54.0, longitude: -68.0, toleranceRadiusKm: 1550),
    ]

    // MARK: - Weltwunder / Rekorde Sek1
    static let sek1Landmarks: [GeographyItem] = [
        GeographyItem(name: "Grand Canyon", type: .landmark, latitude: 36.1, longitude: -112.1, toleranceRadiusKm: 850),
        GeographyItem(name: "Pyramiden", type: .landmark, latitude: 29.98, longitude: 31.13, toleranceRadiusKm: 400),
        GeographyItem(name: "Chinesische Mauer", type: .landmark, latitude: 40.4, longitude: 116.6, toleranceRadiusKm: 1750),
        GeographyItem(name: "Angel Falls", type: .landmark, latitude: 5.97, longitude: -62.54, toleranceRadiusKm: 700),
        GeographyItem(name: "Ayers Rock", type: .landmark, latitude: -25.34, longitude: 131.04, toleranceRadiusKm: 600),
        GeographyItem(name: "Mt. Everest", type: .landmark, latitude: 27.99, longitude: 86.93, toleranceRadiusKm: 400),
        GeographyItem(name: "Marianengraben", type: .landmark, latitude: 11.35, longitude: 142.20, toleranceRadiusKm: 1200),
        GeographyItem(name: "Panamakanal", type: .landmark, latitude: 9.08, longitude: -79.68, toleranceRadiusKm: 500),
    ]

    // MARK: - Weltwunder / Rekorde Sek2 (grün)
    static let sek2Landmarks: [GeographyItem] = [
        GeographyItem(name: "Galapagos", type: .landmark, latitude: -0.7, longitude: -91.0, toleranceRadiusKm: 550, level: .sek2),
    ]
}
