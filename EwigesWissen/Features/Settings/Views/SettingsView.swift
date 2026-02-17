import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    @AppStorage("sessionLength") private var sessionLength = 10
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("mapStyle") private var mapStyle = "Apple Karten"

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            Form {
                Section("Schulstufe") {
                    Picker("Stufe", selection: $state.schoolLevel) {
                        ForEach(SchoolLevel.allCases) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                }

                Section("Quiz") {
                    Stepper(
                        "Fragen pro Quiz: \(sessionLength)",
                        value: $sessionLength,
                        in: 5...30,
                        step: 5
                    )
                }

                Section("Feedback") {
                    Toggle("Sound", isOn: $soundEnabled)
                        .onChange(of: soundEnabled) { _, newValue in
                            SoundService.shared.isEnabled = newValue
                        }
                    Toggle("Haptik", isOn: $hapticEnabled)
                        .onChange(of: hapticEnabled) { _, newValue in
                            HapticService.shared.isEnabled = newValue
                        }
                }

                Section("Geografie-Karte") {
                    Picker("Kartentyp", selection: $mapStyle) {
                        ForEach(MapStyle.allCases) { style in
                            Text(style.rawValue).tag(style.rawValue)
                        }
                    }
                }

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

                Section("Info") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .navigationTitle("Einstellungen")
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "\(version) (\(build))"
    }
}
