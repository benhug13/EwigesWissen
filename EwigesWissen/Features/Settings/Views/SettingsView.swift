import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    @AppStorage("sessionLength") private var sessionLength = 10
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("mapStyle") private var mapStyle = "Apple Karten"
    @AppStorage("appearance") private var appearance = "system"

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

                Section {
                    Toggle("Alle Fragen", isOn: Binding(
                        get: { sessionLength == 0 },
                        set: { sessionLength = $0 ? 0 : 10 }
                    ))
                    if sessionLength != 0 {
                        Stepper(
                            "Fragen pro Quiz: \(sessionLength)",
                            value: $sessionLength,
                            in: 5...30,
                            step: 5
                        )
                    }
                } header: {
                    Text("Quiz")
                } footer: {
                    if sessionLength == 0 {
                        Text("Es kommen alle Fragen der gewählten Schulstufe dran.")
                    }
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
                    NavigationLink {
                        CalibrationView()
                    } label: {
                        HStack {
                            Text("Punkte kalibrieren")
                            Spacer()
                            let apple = CalibrationStore.shared.calibratedCount(on: .apple)
                            let atlas = CalibrationStore.shared.calibratedCount(on: .atlas)
                            if apple + atlas > 0 {
                                Text("Apple \(apple) · Atlas \(atlas)")
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                    }
                }

                Section("Darstellung") {
                    Picker("Erscheinungsbild", selection: $appearance) {
                        Text("System").tag("system")
                        Text("Hell").tag("light")
                        Text("Dunkel").tag("dark")
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
                    HStack {
                        Text("Entwickelt von")
                        Spacer()
                        Text("Ben Hug")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Section("Lizenzen") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kartenmaterial")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Stumme Karte aus dem Schulatlas — Nutzung mit freundlicher Genehmigung des Karten­herstellers für die kostenlose Lern-App EwigesWissen.")
                            .font(.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                        Text("Kompass Freytag & Berndt GmbH\nKarl-Kapfererstr. 5\n6020 Innsbruck, Österreich")
                            .font(.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                        Text("Lizenznummer: 05-0526-GLAB")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    .padding(.vertical, 4)
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
