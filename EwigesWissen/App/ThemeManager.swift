import SwiftUI

@Observable
final class ThemeManager {
    var colorSchemeOverride: ColorScheme?

    func preferredColorScheme(from preference: String?) -> ColorScheme? {
        switch preference {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
