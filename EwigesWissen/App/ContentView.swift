import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            Tab("Home", systemImage: "house.fill", value: .home) {
                HomeView()
            }
            Tab("Hauptstädte", systemImage: "building.columns.fill", value: .capitals) {
                CapitalsLearningView()
            }
            Tab("Geografie", systemImage: "globe.europe.africa.fill", value: .geography) {
                GeographyLearningView()
            }
            Tab("Fortschritt", systemImage: "chart.bar.fill", value: .progress) {
                ProgressOverviewView()
            }
            Tab("Einstellungen", systemImage: "gearshape.fill", value: .settings) {
                SettingsView()
            }
        }
        .tint(AppColors.primary)
    }
}
