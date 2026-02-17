import SwiftUI
import SwiftData

@Observable
final class AppState {
    var selectedTab: AppTab = .home
    var currentUser: User?
    var schoolLevel: SchoolLevel = .sek1
    var showStreakCelebration: Int? = nil  // streak count to celebrate
    var showTeacherMessage: Bool = false

    enum AppTab: Int, CaseIterable {
        case home = 0
        case capitals
        case geography
        case progress
        case settings

        var title: String {
            switch self {
            case .home: return "Home"
            case .capitals: return "Hauptstädte"
            case .geography: return "Geografie"
            case .progress: return "Fortschritt"
            case .settings: return "Einstellungen"
            }
        }

        var iconName: String {
            switch self {
            case .home: return "house.fill"
            case .capitals: return "building.columns.fill"
            case .geography: return "globe.europe.africa.fill"
            case .progress: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
}
