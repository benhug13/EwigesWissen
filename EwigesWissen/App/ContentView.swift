import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    @AppStorage("appearance") private var appearance = "system"

    private var preferredColorScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppState.AppTab.home)

            CapitalsLearningView()
                .tabItem {
                    Label("Hauptstädte", systemImage: "building.columns.fill")
                }
                .tag(AppState.AppTab.capitals)

            GeographyLearningView()
                .tabItem {
                    Label("Geografie", systemImage: "globe.europe.africa.fill")
                }
                .tag(AppState.AppTab.geography)

            ProgressOverviewView()
                .tabItem {
                    Label("Fortschritt", systemImage: "chart.bar.fill")
                }
                .tag(AppState.AppTab.progress)

            SettingsView()
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape.fill")
                }
                .tag(AppState.AppTab.settings)
        }
        .tint(AppColors.primary)
        .overlay {
            if let streakCount = appState.showStreakCelebration {
                StreakCelebrationView(streakCount: streakCount) {
                    appState.showStreakCelebration = nil
                }
                .transition(.opacity)
                .zIndex(100)
            }
            if appState.showTeacherMessage {
                TeacherOverlayView {
                    appState.showTeacherMessage = false
                }
                .transition(.opacity)
                .zIndex(101)
            }
            if appState.showComboExplosion {
                ComboExplosionView {
                    appState.showComboExplosion = false
                }
                .transition(.opacity)
                .zIndex(102)
            }
        }
        .preferredColorScheme(preferredColorScheme)
        .onAppear {
            ensureUserAndPreferences()
        }
    }

    private func ensureUserAndPreferences() {
        let user: User
        if let existingUser = users.first {
            user = existingUser
        } else {
            user = User()
            modelContext.insert(user)
        }
        if user.preferences == nil {
            let prefs = UserPreferences()
            modelContext.insert(prefs)
            user.preferences = prefs
        }
        EngagementService.restoreBackupIfNeeded(for: user)
        try? modelContext.save()
        appState.currentUser = user
        appState.schoolLevel = user.level
    }
}
