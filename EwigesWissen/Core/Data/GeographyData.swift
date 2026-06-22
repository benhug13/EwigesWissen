import Foundation

enum GeographyData {
    static let all: [GeographyItem] = sek1Items + sek2Items + naOnlyItems

    // MARK: - 1. Sek (Basis-Set, schwarz im PDF)
    static let sek1Items: [GeographyItem] = continents + sek1Islands + sek1Mountains + sek1Seas + sek1Rivers + sek1Landscapes + sek1Landmarks

    // MARK: - 2. Sek (Erweiterungs-Set, grün im PDF)
    static let sek2Items: [GeographyItem] = sek2Islands + sek2Mountains + sek2Seas + sek2Rivers + sek2Landmarks

    // MARK: - Nur Nordamerika-Modus (kommen nicht auf der Weltkarte vor)
    static let naOnlyItems: [GeographyItem] = naCities + naCountries + naLandscapes + naRivers + naHistory

    // NOTE: latitude/longitude = echte Welt-Koordinaten (Apple-Karte).
    // atlasLatitude/atlasLongitude = von Hand auf die öbv "Stumme Karte"
    // (Robinson-Projektion) getunte Werte. Beide Karten brauchen eigene Werte.

    // MARK: - Kontinente (alle Sek1)
    static let continents: [GeographyItem] = [
        GeographyItem(name: "Europa", type: .continent, latitude: 54.0, longitude: 15.0, atlasLatitude: 42.2, atlasLongitude: 6.0, toleranceRadiusKm: 2250),
        GeographyItem(name: "Nordamerika", type: .continent, latitude: 48.0, longitude: -100.0, atlasLatitude: 39.9, atlasLongitude: -102.5, toleranceRadiusKm: 2750, regions: [.world, .northAmerica], naMapX: 0.489, naMapY: 0.425, naToleranceRadiusKm: 3100),
        GeographyItem(name: "Südamerika", type: .continent, latitude: -15.0, longitude: -60.0, atlasLatitude: -10.0, atlasLongitude: -70.5, toleranceRadiusKm: 2750),
        GeographyItem(name: "Afrika", type: .continent, latitude: 7.0, longitude: 21.0, atlasLatitude: 11.1, atlasLongitude: 7.0, toleranceRadiusKm: 3000),
        GeographyItem(name: "Asien", type: .continent, latitude: 50.0, longitude: 90.0, atlasLatitude: 41.3, atlasLongitude: 67.1, toleranceRadiusKm: 3000),
        GeographyItem(name: "Australien", type: .continent, latitude: -25.0, longitude: 134.0, atlasLatitude: -24.1, atlasLongitude: 122.7, toleranceRadiusKm: 2000),
        GeographyItem(name: "Antarktis", type: .continent, latitude: -82.0, longitude: 0.0, atlasLatitude: -71.5, atlasLongitude: -3.8, toleranceRadiusKm: 3000),
    ]

    // MARK: - Inseln / Halbinseln Sek1 (1-15)
    static let sek1Islands: [GeographyItem] = [
        GeographyItem(name: "Grönland", type: .island, latitude: 72.0, longitude: -40.0, atlasLatitude: 64.1, atlasLongitude: -44.3, toleranceRadiusKm: 2300, regions: [.world, .northAmerica], naMapX: 0.790, naMapY: 0.027, naToleranceRadiusKm: 1050),
        GeographyItem(name: "Island", type: .island, latitude: 64.9, longitude: -19.0, atlasLatitude: 55.0, atlasLongitude: -26.3, toleranceRadiusKm: 550),
        GeographyItem(name: "Madagaskar", type: .island, latitude: -18.8, longitude: 47.0, atlasLatitude: -16.3, atlasLongitude: 35.9, toleranceRadiusKm: 800),
        GeographyItem(name: "Grossbritannien", type: .island, latitude: 54.0, longitude: -2.0, atlasLatitude: 42.0, atlasLongitude: -8.0, toleranceRadiusKm: 1300),
        GeographyItem(name: "Neuseeland", type: .island, latitude: -41.0, longitude: 174.0, atlasLatitude: -41.7, atlasLongitude: 154.6, toleranceRadiusKm: 1250),
        GeographyItem(name: "Japan", type: .island, latitude: 36.0, longitude: 138.0, atlasLatitude: 35.0, atlasLongitude: 121.5, toleranceRadiusKm: 1100),
        GeographyItem(name: "Neuguinea", type: .island, latitude: -6.0, longitude: 141.0, atlasLatitude: -5.1, atlasLongitude: 130.6, toleranceRadiusKm: 1100),
        GeographyItem(name: "Borneo", type: .island, latitude: 0.5, longitude: 114.0, atlasLatitude: 1.0, atlasLongitude: 103.8, toleranceRadiusKm: 750),
        GeographyItem(name: "Sumatra", type: .island, latitude: 0.0, longitude: 102.0, atlasLatitude: 0.1, atlasLongitude: 89.9, toleranceRadiusKm: 900),
        GeographyItem(name: "Indien", type: .peninsula, latitude: 21.0, longitude: 78.0, atlasLatitude: 16.8, atlasLongitude: 67.2, toleranceRadiusKm: 1350),
        GeographyItem(name: "Arabische Halbinsel", type: .peninsula, latitude: 25.0, longitude: 45.0, atlasLatitude: 19.4, atlasLongitude: 35.3, toleranceRadiusKm: 1250),
        GeographyItem(name: "Iberische Halbinsel", type: .peninsula, latitude: 40.0, longitude: -4.0, atlasLatitude: 33.8, atlasLongitude: -13.9, toleranceRadiusKm: 650),
        GeographyItem(name: "Skandinavien", type: .peninsula, latitude: 63.0, longitude: 16.0, atlasLatitude: 54.4, atlasLongitude: 5.1, toleranceRadiusKm: 1150),
        GeographyItem(name: "Korea", type: .peninsula, latitude: 38.0, longitude: 127.0, atlasLatitude: 34.1, atlasLongitude: 113.0, toleranceRadiusKm: 600),
        GeographyItem(name: "Italien", type: .peninsula, latitude: 42.5, longitude: 12.5, atlasLatitude: 35.0, atlasLongitude: 3.3, toleranceRadiusKm: 600),
    ]

    // MARK: - Inseln / Halbinseln Sek2 (16-22, grün)
    static let sek2Islands: [GeographyItem] = [
        GeographyItem(name: "Antillen", type: .island, latitude: 16.0, longitude: -65.0, atlasLatitude: 17.1, atlasLongitude: -79.0, toleranceRadiusKm: 1500, level: .sek2, regions: [.world, .northAmerica], naMapX: 0.853, naMapY: 0.785, naToleranceRadiusKm: 850),
        GeographyItem(name: "Sri Lanka", type: .island, latitude: 7.5, longitude: 81.0, atlasLatitude: 5.9, atlasLongitude: 70.7, toleranceRadiusKm: 200, level: .sek2),
        GeographyItem(name: "Malediven", type: .island, latitude: 3.2, longitude: 73.0, atlasLatitude: 2.7, atlasLongitude: 62.9, toleranceRadiusKm: 450, level: .sek2),
        GeographyItem(name: "Balearen", type: .island, latitude: 39.5, longitude: 3.0, atlasLatitude: 32.7, atlasLongitude: -6.5, toleranceRadiusKm: 200, level: .sek2),
        GeographyItem(name: "Kanarische Inseln", type: .island, latitude: 28.3, longitude: -15.5, atlasLatitude: 23.7, atlasLongitude: -25.3, toleranceRadiusKm: 350, level: .sek2),
        GeographyItem(name: "Kreta", type: .island, latitude: 35.2, longitude: 24.8, atlasLatitude: 29.2, atlasLongitude: 14.4, toleranceRadiusKm: 200, level: .sek2),
        GeographyItem(name: "Sizilien", type: .island, latitude: 37.5, longitude: 14.0, atlasLatitude: 32.0, atlasLongitude: 5.0, toleranceRadiusKm: 200, level: .sek2),
    ]

    // MARK: - Gebirge Sek1
    static let sek1Mountains: [GeographyItem] = [
        GeographyItem(name: "Alpen", type: .mountain, latitude: 46.5, longitude: 10.0, atlasLatitude: 38.5, atlasLongitude: -0.5, toleranceRadiusKm: 600),
        GeographyItem(name: "Rocky Mountains", type: .mountain, latitude: 44.0, longitude: -110.0, atlasLatitude: 40.7, atlasLongitude: -115.2, toleranceRadiusKm: 2300, regions: [.world, .northAmerica], naMapX: 0.317, naMapY: 0.388, naToleranceRadiusKm: 1850),
        GeographyItem(name: "Anden", type: .mountain, latitude: -15.0, longitude: -72.0, atlasLatitude: -15.1, atlasLongitude: -80.6, toleranceRadiusKm: 3000),
        GeographyItem(name: "Himalaya", type: .mountain, latitude: 28.0, longitude: 84.0, atlasLatitude: 26.0, atlasLongitude: 72.3, toleranceRadiusKm: 1350),
        GeographyItem(name: "Atlasgebirge", type: .mountain, latitude: 32.0, longitude: -5.0, atlasLatitude: 27.7, atlasLongitude: -9.8, toleranceRadiusKm: 850),
        GeographyItem(name: "Australische Alpen", type: .mountain, latitude: -36.0, longitude: 148.0, atlasLatitude: -29.8, atlasLongitude: 134.1, toleranceRadiusKm: 1400),
    ]

    // MARK: - Gebirge Sek2 (grün)
    static let sek2Mountains: [GeographyItem] = [
        GeographyItem(name: "Ural", type: .mountain, latitude: 60.0, longitude: 60.0, atlasLatitude: 49.0, atlasLongitude: 43.0, toleranceRadiusKm: 1400, level: .sek2),
        GeographyItem(name: "Appalachen", type: .mountain, latitude: 38.0, longitude: -80.0, atlasLatitude: 33.5, atlasLongitude: -84.2, toleranceRadiusKm: 1500, level: .sek2, regions: [.world, .northAmerica], naMapX: 0.791, naMapY: 0.545, naToleranceRadiusKm: 1100),
    ]

    // MARK: - Meere / Ozeane Sek1 (A-K)
    static let sek1Seas: [GeographyItem] = [
        GeographyItem(name: "Atlantik", type: .sea, latitude: 0.0, longitude: -30.0, atlasLatitude: 19.3, atlasLongitude: -50.8, toleranceRadiusKm: 3000),
        GeographyItem(name: "Pazifik", type: .sea, latitude: 0.0, longitude: -160.0, atlasLatitude: 2.0, atlasLongitude: -140.4, toleranceRadiusKm: 3000),
        GeographyItem(name: "Indischer Ozean", type: .sea, latitude: -20.0, longitude: 80.0, atlasLatitude: -17.3, atlasLongitude: 66.5, toleranceRadiusKm: 3000),
        GeographyItem(name: "Schwarzes Meer", type: .sea, latitude: 43.0, longitude: 35.0, atlasLatitude: 36.2, atlasLongitude: 24.5, toleranceRadiusKm: 550),
        GeographyItem(name: "Mittelmeer", type: .sea, latitude: 38.0, longitude: 17.0, atlasLatitude: 30.3, atlasLongitude: 6.9, toleranceRadiusKm: 1150),
        GeographyItem(name: "Rotes Meer", type: .sea, latitude: 22.0, longitude: 38.0, atlasLatitude: 17.5, atlasLongitude: 29.4, toleranceRadiusKm: 1050),
        GeographyItem(name: "Nördliches Eismeer", type: .sea, latitude: 84.0, longitude: 0.0, atlasLatitude: 71.1, atlasLongitude: 3.8, toleranceRadiusKm: 3000),
        GeographyItem(name: "Karibik", type: .sea, latitude: 15.0, longitude: -75.0, atlasLatitude: 16.3, atlasLongitude: -88.8, toleranceRadiusKm: 1500, regions: [.world, .northAmerica], naMapX: 0.781, naMapY: 0.850, naToleranceRadiusKm: 1500),
        GeographyItem(name: "Nordsee", type: .sea, latitude: 56.0, longitude: 3.0, atlasLatitude: 47.0, atlasLongitude: -5.1, toleranceRadiusKm: 900),
        GeographyItem(name: "Ostsee", type: .sea, latitude: 58.0, longitude: 20.0, atlasLatitude: 48.9, atlasLongitude: 9.9, toleranceRadiusKm: 750),
    ]

    // MARK: - Seen Sek2 (grün: L, M, N)
    static let sek2Seas: [GeographyItem] = [
        GeographyItem(name: "Kaspisches Meer", type: .lake, latitude: 42.0, longitude: 50.0, atlasLatitude: 35.3, atlasLongitude: 39.2, toleranceRadiusKm: 700, level: .sek2),
        GeographyItem(name: "Titicacasee", type: .lake, latitude: -15.8, longitude: -69.4, atlasLatitude: -14.5, atlasLongitude: -78.7, toleranceRadiusKm: 450, level: .sek2),
        GeographyItem(name: "Baikalsee", type: .lake, latitude: 53.5, longitude: 108.0, atlasLatitude: 46.7, atlasLongitude: 89.8, toleranceRadiusKm: 450, level: .sek2),
    ]

    // MARK: - Flüsse Sek1 (a-g)
    static let sek1Rivers: [GeographyItem] = [
        GeographyItem(name: "Mississippi", type: .river, latitude: 38.0, longitude: -90.0, atlasLatitude: 35.3, atlasLongitude: -96.6, toleranceRadiusKm: 1500, regions: [.world, .northAmerica], naMapX: 0.588, naMapY: 0.578, naToleranceRadiusKm: 1050),
        GeographyItem(name: "Nil", type: .river, latitude: 27.0, longitude: 31.0, atlasLatitude: 13.0, atlasLongitude: 24.8, toleranceRadiusKm: 2000),
        GeographyItem(name: "Amazonas", type: .river, latitude: -3.0, longitude: -60.0, atlasLatitude: -3.9, atlasLongitude: -74.7, toleranceRadiusKm: 1600),
        GeographyItem(name: "Wolga", type: .river, latitude: 49.0, longitude: 45.0, atlasLatitude: 44.6, atlasLongitude: 29.1, toleranceRadiusKm: 1450),
        GeographyItem(name: "Murray River", type: .river, latitude: -34.5, longitude: 143.0, atlasLatitude: -34.3, atlasLongitude: 128.0, toleranceRadiusKm: 600),
        GeographyItem(name: "Huang Ho", type: .river, latitude: 37.0, longitude: 110.0, atlasLatitude: 32.1, atlasLongitude: 95.2, toleranceRadiusKm: 1350),
        GeographyItem(name: "Ganges", type: .river, latitude: 25.0, longitude: 84.0, atlasLatitude: 24.0, atlasLongitude: 73.0, toleranceRadiusKm: 1050),
    ]

    // MARK: - Flüsse Sek2 (grün: h-p)
    static let sek2Rivers: [GeographyItem] = [
        GeographyItem(name: "Donau", type: .river, latitude: 45.0, longitude: 22.0, atlasLatitude: 38.6, atlasLongitude: 12.8, toleranceRadiusKm: 1000, level: .sek2),
        GeographyItem(name: "Mackenzie", type: .river, latitude: 65.0, longitude: -125.0, atlasLatitude: 59.2, atlasLongitude: -117.5, toleranceRadiusKm: 1000, level: .sek2, regions: [.world, .northAmerica], naMapX: 0.349, naMapY: 0.155, naToleranceRadiusKm: 400),
        GeographyItem(name: "Kongo", type: .river, latitude: -2.0, longitude: 22.0, atlasLatitude: -5.4, atlasLongitude: 11.9, toleranceRadiusKm: 1050, level: .sek2),
        GeographyItem(name: "Rhein", type: .river, latitude: 50.0, longitude: 7.0, atlasLatitude: 41.6, atlasLongitude: -2.7, toleranceRadiusKm: 500, level: .sek2),
        GeographyItem(name: "Indus", type: .river, latitude: 28.0, longitude: 70.0, atlasLatitude: 25.5, atlasLongitude: 59.3, toleranceRadiusKm: 1000, level: .sek2),
        GeographyItem(name: "Paraná", type: .river, latitude: -27.0, longitude: -56.0, atlasLatitude: -23.9, atlasLongitude: -59.8, toleranceRadiusKm: 1200, level: .sek2),
        GeographyItem(name: "Niger", type: .river, latitude: 13.0, longitude: 0.0, atlasLatitude: 8.0, atlasLongitude: -11.7, toleranceRadiusKm: 1250, level: .sek2),
        GeographyItem(name: "Colorado", type: .river, latitude: 36.0, longitude: -111.0, atlasLatitude: 34.4, atlasLongitude: -115.7, toleranceRadiusKm: 900, level: .sek2, regions: [.world, .northAmerica], naMapX: 0.385, naMapY: 0.614, naToleranceRadiusKm: 600),
    ]

    // MARK: - Landschaften Sek1
    static let sek1Landscapes: [GeographyItem] = [
        GeographyItem(name: "Alaska", type: .landscape, latitude: 64.0, longitude: -150.0, atlasLatitude: 60.5, atlasLongitude: -140.5, toleranceRadiusKm: 1800, regions: [.world, .northAmerica], naMapX: 0.214, naMapY: 0.094, naToleranceRadiusKm: 850),
        GeographyItem(name: "Sibirien", type: .landscape, latitude: 65.0, longitude: 100.0, atlasLatitude: 52.9, atlasLongitude: 81.1, toleranceRadiusKm: 2500),
        GeographyItem(name: "Sahara", type: .landscape, latitude: 23.0, longitude: 13.0, atlasLatitude: 20.8, atlasLongitude: 0.7, toleranceRadiusKm: 2400),
        GeographyItem(name: "Amazonien", type: .landscape, latitude: -3.0, longitude: -60.0, atlasLatitude: -6.3, atlasLongitude: -71.6, toleranceRadiusKm: 1950),
        GeographyItem(name: "Feuerland", type: .landscape, latitude: -54.0, longitude: -68.0, atlasLatitude: -45.3, atlasLongitude: -79.0, toleranceRadiusKm: 1550),
    ]

    // MARK: - Weltwunder / Rekorde Sek1
    static let sek1Landmarks: [GeographyItem] = [
        GeographyItem(name: "Grand Canyon", type: .landmark, latitude: 36.1, longitude: -112.1, atlasLatitude: 31.8, atlasLongitude: -120.0, toleranceRadiusKm: 850, regions: [.world, .northAmerica], naMapX: 0.354, naMapY: 0.644, naToleranceRadiusKm: 100),
        GeographyItem(name: "Pyramiden", type: .landmark, latitude: 29.98, longitude: 31.13, atlasLatitude: 25.8, atlasLongitude: 19.2, toleranceRadiusKm: 400),
        GeographyItem(name: "Chinesische Mauer", type: .landmark, latitude: 40.4, longitude: 116.6, atlasLatitude: 37.7, atlasLongitude: 97.4, toleranceRadiusKm: 1750),
        GeographyItem(name: "Angel Falls", type: .landmark, latitude: 5.97, longitude: -62.54, atlasLatitude: 5.0, atlasLongitude: -69.1, toleranceRadiusKm: 700),
        GeographyItem(name: "Ayers Rock", type: .landmark, latitude: -25.34, longitude: 131.04, atlasLatitude: -20.6, atlasLongitude: 113.2, toleranceRadiusKm: 600),
        GeographyItem(name: "Mt. Everest", type: .landmark, latitude: 27.99, longitude: 86.93, atlasLatitude: 24.3, atlasLongitude: 78.0, toleranceRadiusKm: 400),
        GeographyItem(name: "Marianengraben", type: .landmark, latitude: 11.35, longitude: 142.20, atlasLatitude: 19.6, atlasLongitude: 123.9, toleranceRadiusKm: 1200),
        GeographyItem(name: "Panamakanal", type: .landmark, latitude: 9.08, longitude: -79.68, atlasLatitude: 7.4, atlasLongitude: -89.6, toleranceRadiusKm: 500, regions: [.world, .northAmerica], naMapX: 0.840, naMapY: 0.974, naToleranceRadiusKm: 300),
    ]

    // MARK: - Weltwunder / Rekorde Sek2 (grün)
    static let sek2Landmarks: [GeographyItem] = [
        GeographyItem(name: "Galapagos", type: .landmark, latitude: -0.7, longitude: -91.0, atlasLatitude: -1.0, atlasLongitude: -100.5, toleranceRadiusKm: 550, level: .sek2),
    ]

    // MARK: - Nordamerika-spezifische Items (nur in NA-Modus)
    // latitude/longitude sind grobe Schätzwerte (für Apple-Karten-Fallback);
    // naMapX/naMapY sind die echten kalibrierten Werte auf der d-maps-Karte.

    static let naCities: [GeographyItem] = [
        GeographyItem(name: "Toronto",          type: .city, latitude: 43.65, longitude:  -79.38, toleranceRadiusKm: 100, regions: [.northAmerica], naMapX: 0.757, naMapY: 0.471, naToleranceRadiusKm: 100),
        GeographyItem(name: "Ottawa",           type: .city, latitude: 45.42, longitude:  -75.70, toleranceRadiusKm: 150, regions: [.northAmerica], naMapX: 0.777, naMapY: 0.428, naToleranceRadiusKm: 150),
        GeographyItem(name: "Quebec",           type: .city, latitude: 46.81, longitude:  -71.21, toleranceRadiusKm: 100, regions: [.northAmerica], naMapX: 0.811, naMapY: 0.411, naToleranceRadiusKm: 100),
        GeographyItem(name: "Washington D.C.",  type: .city, latitude: 38.91, longitude:  -77.04, toleranceRadiusKm: 100, regions: [.northAmerica], naMapX: 0.782, naMapY: 0.538, naToleranceRadiusKm: 100),
        GeographyItem(name: "Chicago",          type: .city, latitude: 41.88, longitude:  -87.63, toleranceRadiusKm: 100, regions: [.northAmerica], naMapX: 0.655, naMapY: 0.521, naToleranceRadiusKm: 100),
        GeographyItem(name: "Vancouver",        type: .city, latitude: 49.28, longitude: -123.12, toleranceRadiusKm: 100, regions: [.northAmerica], naMapX: 0.345, naMapY: 0.395, naToleranceRadiusKm: 100),
        GeographyItem(name: "Mexiko-Stadt",     type: .city, latitude: 19.43, longitude:  -99.13, toleranceRadiusKm: 100, regions: [.northAmerica], naMapX: 0.533, naMapY: 0.847, naToleranceRadiusKm: 100),
        GeographyItem(name: "Los Angeles",      type: .city, latitude: 34.05, longitude: -118.24, toleranceRadiusKm: 100, regions: [.northAmerica], naMapX: 0.277, naMapY: 0.610, naToleranceRadiusKm: 100),
        GeographyItem(name: "Tijuana (Grenzstadt)",  type: .city, latitude: 32.51, longitude: -117.04, toleranceRadiusKm: 100, regions: [.northAmerica], naMapX: 0.291, naMapY: 0.629, naToleranceRadiusKm: 100),
        GeographyItem(name: "San Diego (Grenzstadt)", type: .city, latitude: 32.71, longitude: -117.16, toleranceRadiusKm: 100, regions: [.northAmerica], naMapX: 0.300, naMapY: 0.656, naToleranceRadiusKm: 100),
    ]

    static let naCountries: [GeographyItem] = [
        GeographyItem(name: "Kanada",  type: .country, latitude: 56.13, longitude: -106.35, toleranceRadiusKm: 1500, regions: [.northAmerica], naMapX: 0.481, naMapY: 0.235, naToleranceRadiusKm: 1500),
        GeographyItem(name: "USA",     type: .country, latitude: 39.83, longitude:  -98.58, toleranceRadiusKm: 1300, regions: [.northAmerica], naMapX: 0.494, naMapY: 0.571, naToleranceRadiusKm: 1300),
        GeographyItem(name: "Mexico",  type: .country, latitude: 23.63, longitude: -102.55, toleranceRadiusKm: 1300, regions: [.northAmerica], naMapX: 0.543, naMapY: 0.850, naToleranceRadiusKm: 1300),
    ]

    static let naLandscapes: [GeographyItem] = [
        GeographyItem(name: "Heartlands Rinderzucht",     type: .landscape, latitude: 40.0,  longitude: -100.0, toleranceRadiusKm: 550, regions: [.northAmerica], naMapX: 0.652, naMapY: 0.517, naToleranceRadiusKm: 550),
        GeographyItem(name: "Great Plains Weizenanbau",   type: .landscape, latitude: 42.0,  longitude:  -98.0, toleranceRadiusKm: 650, regions: [.northAmerica], naMapX: 0.531, naMapY: 0.483, naToleranceRadiusKm: 650),
        GeographyItem(name: "Sonorawüste (Grenzgebiet)",  type: .landscape, latitude: 31.0,  longitude: -113.0, toleranceRadiusKm: 600, regions: [.northAmerica], naMapX: 0.371, naMapY: 0.715, naToleranceRadiusKm: 600),
        GeographyItem(name: "Kalifornien",                type: .landscape, latitude: 36.78, longitude: -119.42, toleranceRadiusKm: 750, regions: [.northAmerica], naMapX: 0.243, naMapY: 0.569, naToleranceRadiusKm: 750),
    ]

    static let naRivers: [GeographyItem] = [
        GeographyItem(name: "Rio Grande (Grenzfluss)", type: .river, latitude: 30.0, longitude: -103.0, toleranceRadiusKm: 400, regions: [.northAmerica], naMapX: 0.481, naMapY: 0.666, naToleranceRadiusKm: 400),
    ]

    static let naHistory: [GeographyItem] = [
        GeographyItem(name: "Spanien 1550 (Einwanderer)",   type: .history, latitude: 35.7, longitude: -106.0, toleranceRadiusKm: 300, regions: [.northAmerica], naMapX: 0.297, naMapY: 0.690, naToleranceRadiusKm: 300),
        GeographyItem(name: "Engländer 1607 (Einwanderer)", type: .history, latitude: 37.2, longitude:  -76.8, toleranceRadiusKm: 400, regions: [.northAmerica], naMapX: 0.787, naMapY: 0.633, naToleranceRadiusKm: 400),
        GeographyItem(name: "Franzosen 1600 (Einwanderer)", type: .history, latitude: 46.8, longitude:  -71.2, toleranceRadiusKm: 350, regions: [.northAmerica], naMapX: 0.850, naMapY: 0.375, naToleranceRadiusKm: 350),
    ]
}
