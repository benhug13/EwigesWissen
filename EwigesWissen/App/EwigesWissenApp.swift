import SwiftUI
import SwiftData

@main
struct EwigesWissenApp: App {
    @State private var appState = AppState()
    @State private var themeManager = ThemeManager()

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
        ])
    }
}
