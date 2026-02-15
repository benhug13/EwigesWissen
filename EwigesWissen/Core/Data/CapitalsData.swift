import Foundation

enum CapitalsData {
    /// All European capitals
    static let all: [Capital] = sek1Capitals + sek2Capitals

    // MARK: - 1. Sek (Basis-Set ~30)
    static let sek1Capitals: [Capital] = [
        Capital(country: "Deutschland", capital: "Berlin", latitude: 52.5200, longitude: 13.4050),
        Capital(country: "Frankreich", capital: "Paris", latitude: 48.8566, longitude: 2.3522),
        Capital(country: "Italien", capital: "Rom", latitude: 41.9028, longitude: 12.4964),
        Capital(country: "Spanien", capital: "Madrid", latitude: 40.4168, longitude: -3.7038),
        Capital(country: "Portugal", capital: "Lissabon", latitude: 38.7223, longitude: -9.1393),
        Capital(country: "Grossbritannien", capital: "London", latitude: 51.5074, longitude: -0.1278),
        Capital(country: "Niederlande", capital: "Amsterdam", latitude: 52.3676, longitude: 4.9041),
        Capital(country: "Belgien", capital: "Brüssel", latitude: 50.8503, longitude: 4.3517),
        Capital(country: "Österreich", capital: "Wien", latitude: 48.2082, longitude: 16.3738),
        Capital(country: "Schweiz", capital: "Bern", latitude: 46.9480, longitude: 7.4474),
        Capital(country: "Polen", capital: "Warschau", latitude: 52.2297, longitude: 21.0122),
        Capital(country: "Tschechien", capital: "Prag", latitude: 50.0755, longitude: 14.4378),
        Capital(country: "Ungarn", capital: "Budapest", latitude: 47.4979, longitude: 19.0402),
        Capital(country: "Griechenland", capital: "Athen", latitude: 37.9838, longitude: 23.7275),
        Capital(country: "Schweden", capital: "Stockholm", latitude: 59.3293, longitude: 18.0686),
        Capital(country: "Norwegen", capital: "Oslo", latitude: 59.9139, longitude: 10.7522),
        Capital(country: "Dänemark", capital: "Kopenhagen", latitude: 55.6761, longitude: 12.5683),
        Capital(country: "Finnland", capital: "Helsinki", latitude: 60.1699, longitude: 24.9384),
        Capital(country: "Irland", capital: "Dublin", latitude: 53.3498, longitude: -6.2603),
        Capital(country: "Russland", capital: "Moskau", latitude: 55.7558, longitude: 37.6173),
        Capital(country: "Türkei", capital: "Ankara", latitude: 39.9334, longitude: 32.8597),
        Capital(country: "Rumänien", capital: "Bukarest", latitude: 44.4268, longitude: 26.1025),
        Capital(country: "Ukraine", capital: "Kiew", latitude: 50.4501, longitude: 30.5234),
        Capital(country: "Kroatien", capital: "Zagreb", latitude: 45.8150, longitude: 15.9819),
        Capital(country: "Serbien", capital: "Belgrad", latitude: 44.7866, longitude: 20.4489),
        Capital(country: "Bulgarien", capital: "Sofia", latitude: 42.6977, longitude: 23.3219),
        Capital(country: "Slowakei", capital: "Bratislava", latitude: 48.1486, longitude: 17.1077),
        Capital(country: "Luxemburg", capital: "Luxemburg", latitude: 49.6117, longitude: 6.1300),
        Capital(country: "Island", capital: "Reykjavik", latitude: 64.1466, longitude: -21.9426),
        Capital(country: "Albanien", capital: "Tirana", latitude: 41.3275, longitude: 19.8187),
    ]

    // MARK: - 2. Sek (Erweiterungs-Set ~15)
    static let sek2Capitals: [Capital] = [
        Capital(country: "Slowenien", capital: "Ljubljana", latitude: 46.0569, longitude: 14.5058, level: .sek2),
        Capital(country: "Litauen", capital: "Vilnius", latitude: 54.6872, longitude: 25.2797, level: .sek2),
        Capital(country: "Lettland", capital: "Riga", latitude: 56.9496, longitude: 24.1052, level: .sek2),
        Capital(country: "Estland", capital: "Tallinn", latitude: 59.4370, longitude: 24.7536, level: .sek2),
        Capital(country: "Nordmazedonien", capital: "Skopje", latitude: 41.9973, longitude: 21.4280, level: .sek2),
        Capital(country: "Montenegro", capital: "Podgorica", latitude: 42.4304, longitude: 19.2594, level: .sek2),
        Capital(country: "Bosnien und Herzegowina", capital: "Sarajevo", latitude: 43.8563, longitude: 18.4131, level: .sek2),
        Capital(country: "Kosovo", capital: "Pristina", latitude: 42.6629, longitude: 21.1655, level: .sek2),
        Capital(country: "Moldawien", capital: "Chișinău", latitude: 47.0105, longitude: 28.8638, level: .sek2),
        Capital(country: "Belarus", capital: "Minsk", latitude: 53.9006, longitude: 27.5590, level: .sek2),
        Capital(country: "Malta", capital: "Valletta", latitude: 35.8989, longitude: 14.5146, level: .sek2),
        Capital(country: "Zypern", capital: "Nikosia", latitude: 35.1856, longitude: 33.3823, level: .sek2),
        Capital(country: "Andorra", capital: "Andorra la Vella", latitude: 42.5063, longitude: 1.5218, level: .sek2),
        Capital(country: "Monaco", capital: "Monaco", latitude: 43.7384, longitude: 7.4246, level: .sek2),
        Capital(country: "Liechtenstein", capital: "Vaduz", latitude: 47.1410, longitude: 9.5215, level: .sek2),
    ]
}
