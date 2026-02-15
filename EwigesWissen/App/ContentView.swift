import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

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
    }
}
