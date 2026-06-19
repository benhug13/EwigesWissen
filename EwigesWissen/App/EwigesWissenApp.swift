import SwiftUI
import SwiftData
import UIKit

@main
struct EwigesWissenApp: App {
    @State private var appState = AppState()
    @State private var themeManager = ThemeManager()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(themeManager)
        }
        .modelContainer(for: [
            User.self,
            QuizSession.self,
            DailyProgress.self,
            Achievement.self,
            UserPreferences.self,
            ItemProgress.self,
        ])
    }
}
