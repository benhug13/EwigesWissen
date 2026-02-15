import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    private var user: User? { users.first }
    private var prefs: UserPreferences? { user?.preferences }

    var body: some View {
        NavigationStack {
            Form {
                // School level
                Section("Schulstufe") {
                    @Bindable var state = appState
                    Picker("Stufe", selection: $state.schoolLevel) {
                        ForEach(SchoolLevel.allCases) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .onChange(of: appState.schoolLevel) { _, newValue in
                        user?.level = newValue
                        try? modelContext.save()
                    }
                }

                // Quiz settings
                Section("Quiz") {
                    if let prefs {
                        Stepper(
                            "Fragen pro Quiz: \(prefs.sessionLength)",
                            value: Bindable(prefs).sessionLength,
                            in: 5...30,
                            step: 5
                        )
                    }
                }

                // Sound & Haptics
                Section("Feedback") {
                    if let prefs {
                        Toggle("Sound", isOn: Bindable(prefs).soundEnabled)
                            .onChange(of: prefs.soundEnabled) { _, newValue in
                                SoundService.shared.isEnabled = newValue
                            }
                        Toggle("Haptik", isOn: Bindable(prefs).hapticEnabled)
                    }
                }

                // Appearance
                Section("Darstellung") {
                    if let prefs {
                        Picker("Erscheinungsbild", selection: Bindable(prefs).darkModeOverride) {
                            Text("System").tag(String?.none)
                            Text("Hell").tag(String?("light"))
                            Text("Dunkel").tag(String?("dark"))
                        }
                    }
                }

                // Data
                Section("Daten") {
                    let capitalCount = DataService.shared.capitals(for: appState.schoolLevel).count
                    let geoCount = DataService.shared.geographyItems(for: appState.schoolLevel).count

                    HStack {
                        Text("Hauptstädte")
                        Spacer()
                        Text("\(capitalCount)")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    HStack {
                        Text("Geografie-Items")
                        Spacer()
                        Text("\(geoCount)")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                // About
                Section("Info") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .navigationTitle("Einstellungen")
        }
    }
}
