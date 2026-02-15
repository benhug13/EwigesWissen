import Foundation
import SwiftData

@Model
final class UserPreferences {
    var sessionLength: Int // Number of questions per quiz session
    var soundEnabled: Bool
    var hapticEnabled: Bool
    var darkModeOverride: String? // nil = system, "light", "dark"

    var user: User?

    init(
        sessionLength: Int = 10,
        soundEnabled: Bool = true,
        hapticEnabled: Bool = true,
        darkModeOverride: String? = nil
    ) {
        self.sessionLength = sessionLength
        self.soundEnabled = soundEnabled
        self.hapticEnabled = hapticEnabled
        self.darkModeOverride = darkModeOverride
    }
}
