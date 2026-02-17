import Foundation
import SwiftData

enum MapStyle: String, Codable, CaseIterable, Identifiable {
    case apple = "Apple Karten"
    case stummeKarte = "Schulatlas"

    var id: String { rawValue }
}

@Model
final class UserPreferences {
    var sessionLength: Int // Number of questions per quiz session
    var soundEnabled: Bool
    var hapticEnabled: Bool
    var darkModeOverride: String? // nil = system, "light", "dark"
    var mapStyleRawValue: String = "Apple Karten" // MapStyle rawValue

    var user: User?

    init(
        sessionLength: Int = 10,
        soundEnabled: Bool = true,
        hapticEnabled: Bool = true,
        darkModeOverride: String? = nil,
        mapStyle: MapStyle = .apple
    ) {
        self.sessionLength = sessionLength
        self.soundEnabled = soundEnabled
        self.hapticEnabled = hapticEnabled
        self.darkModeOverride = darkModeOverride
        self.mapStyleRawValue = mapStyle.rawValue
    }

    var mapStyle: MapStyle {
        get { MapStyle(rawValue: mapStyleRawValue) ?? .apple }
        set { mapStyleRawValue = newValue.rawValue }
    }
}
