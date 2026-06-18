import SwiftUI
import MapKit
import CoreLocation

struct CustomItemEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = CustomItemsStore.shared

    @State private var draft: CustomGeographyItem
    @State private var showAtlasPicker = false
    @State private var showNAPicker = false

    private let isNew: Bool

    init(item: CustomGeographyItem? = nil) {
        if let item {
            _draft = State(initialValue: item)
            self.isNew = false
        } else {
            _draft = State(initialValue: CustomGeographyItem.new())
            self.isNew = true
        }
    }

    private var canSave: Bool {
        !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Grunddaten") {
                    TextField("Name (z.B. Etna)", text: $draft.name)
                        .textInputAutocapitalization(.words)

                    Picker("Kategorie", selection: Binding(
                        get: { draft.type },
                        set: { draft.type = $0 }
                    )) {
                        ForEach(GeographyType.allCases) { type in
                            Label(type.displayName, systemImage: type.iconName).tag(type)
                        }
                    }

                    Picker("Schulstufe", selection: Binding(
                        get: { draft.level },
                        set: { draft.level = $0 }
                    )) {
                        ForEach(SchoolLevel.allCases) { lvl in
                            Text(lvl.displayName).tag(lvl)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Region") {
                    ForEach(GeographyRegion.allCases) { region in
                        Toggle(isOn: regionBinding(region)) {
                            Label(region.displayName, systemImage: region.iconName)
                        }
                    }
                }

                Section("Toleranz") {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Radius")
                            Spacer()
                            Text("\(Int(draft.toleranceRadiusKm)) km")
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        Slider(value: $draft.toleranceRadiusKm, in: 50...3000, step: 50)
                    }
                    Text("Wie nah der User mit dem Pin sein muss, damit die Antwort als richtig gilt.")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Section("Position auf Apple Karten") {
                    NavigationLink {
                        AppleMapPickerView(coordinate: Binding(
                            get: { CLLocationCoordinate2D(latitude: draft.latitude, longitude: draft.longitude) },
                            set: { draft.latitude = $0.latitude; draft.longitude = $0.longitude }
                        ))
                    } label: {
                        Label(coordLabel(lat: draft.latitude, lon: draft.longitude), systemImage: "mappin.and.ellipse")
                    }
                }

                Section("Position auf Schulatlas (Welt)") {
                    NavigationLink {
                        AtlasMapPickerView(coordinate: Binding(
                            get: {
                                CLLocationCoordinate2D(
                                    latitude: draft.atlasLatitude ?? draft.latitude,
                                    longitude: draft.atlasLongitude ?? draft.longitude
                                )
                            },
                            set: { draft.atlasLatitude = $0.latitude; draft.atlasLongitude = $0.longitude }
                        ))
                    } label: {
                        Label(
                            draft.atlasLatitude != nil
                                ? coordLabel(lat: draft.atlasLatitude!, lon: draft.atlasLongitude!)
                                : "Nicht gesetzt — fällt auf Apple-Pos zurück",
                            systemImage: "map"
                        )
                    }
                    if draft.atlasLatitude != nil {
                        Button(role: .destructive) {
                            draft.atlasLatitude = nil
                            draft.atlasLongitude = nil
                        } label: {
                            Label("Atlas-Position löschen", systemImage: "trash")
                        }
                    }
                }

                if draft.regions.contains(.northAmerica) {
                    Section("Position auf Nordamerika-Karte") {
                        NavigationLink {
                            NAMapPickerView(point: Binding(
                                get: {
                                    CGPoint(
                                        x: draft.naMapX ?? 0.5,
                                        y: draft.naMapY ?? 0.5
                                    )
                                },
                                set: { draft.naMapX = $0.x; draft.naMapY = $0.y }
                            ))
                        } label: {
                            Label(
                                draft.naMapX != nil
                                    ? String(format: "x %.2f, y %.2f", draft.naMapX!, draft.naMapY!)
                                    : "Nicht gesetzt — Item ist im NA-Quiz nicht spielbar",
                                systemImage: "map"
                            )
                        }
                        if draft.naMapX != nil {
                            Button(role: .destructive) {
                                draft.naMapX = nil
                                draft.naMapY = nil
                            } label: {
                                Label("NA-Position löschen", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "Neues Item" : "Item bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        draft.name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        store.upsert(draft)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private func regionBinding(_ region: GeographyRegion) -> Binding<Bool> {
        Binding(
            get: { draft.regions.contains(region) },
            set: { isOn in
                var set = draft.regions
                if isOn { set.insert(region) } else { set.remove(region) }
                if set.isEmpty { set.insert(.world) }
                draft.regions = set
            }
        )
    }

    private func coordLabel(lat: Double, lon: Double) -> String {
        String(format: "%.3f°, %.3f°", lat, lon)
    }
}

// MARK: - Apple Map Picker

private struct AppleMapPickerView: View {
    @Binding var coordinate: CLLocationCoordinate2D
    @Environment(\.dismiss) private var dismiss
    @State private var cameraPosition: MapCameraPosition

    init(coordinate: Binding<CLLocationCoordinate2D>) {
        _coordinate = coordinate
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(
                center: coordinate.wrappedValue,
                span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30)
            )
        ))
    }

    var body: some View {
        MapReader { proxy in
            Map(position: $cameraPosition) {
                Annotation("Position", coordinate: coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                }
            }
            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
            .onTapGesture { screenPoint in
                if let coord = proxy.convert(screenPoint, from: .local) {
                    coordinate = coord
                }
            }
        }
        .navigationTitle("Tippen zum Setzen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Fertig") { dismiss() }
            }
        }
    }
}

// MARK: - Atlas (Stumme Karte Welt) Picker

private struct AtlasMapPickerView: View {
    @Binding var coordinate: CLLocationCoordinate2D
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        StummeKarteQuizView(
            onTap: { coordinate = $0 },
            showTapPin: coordinate,
            resultAnnotation: nil
        )
        .navigationTitle("Tippen zum Setzen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Fertig") { dismiss() }
            }
        }
    }
}

// MARK: - Nordamerika-Map Picker

private struct NAMapPickerView: View {
    @Binding var point: CGPoint
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        StummeKarteNordamerikaQuizView(
            onTap: { point = $0 },
            placedFraction: point,
            correctFraction: nil,
            isCorrect: false,
            toleranceKm: 0
        )
        .navigationTitle("Tippen zum Setzen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Fertig") { dismiss() }
            }
        }
    }
}
