import SwiftUI
import MapKit
import UIKit
import CoreLocation

struct CalibrationView: View {
    @State private var store = CalibrationStore.shared
    @State private var customStore = CustomItemsStore.shared
    @State private var selectedMap: CalibrationMap = .apple
    @State private var showExportSheet = false
    @State private var exportText = ""
    @State private var showResetConfirm = false
    @State private var searchText = ""
    @State private var showAddItem = false
    @State private var editingCustom: CustomGeographyItem?

    private var items: [GeographyItem] {
        let builtin = GeographyData.all
        let custom = customStore.items.map { $0.toGeographyItem() }
        return (builtin + custom).sorted {
            if $0.type.categoryOrder != $1.type.categoryOrder {
                return $0.type.categoryOrder < $1.type.categoryOrder
            }
            return $0.name < $1.name
        }
    }

    private var filteredItems: [GeographyItem] {
        guard !searchText.isEmpty else { return items }
        let needle = searchText.lowercased()
        return items.filter { $0.name.lowercased().contains(needle) }
    }

    private var grouped: [(String, [GeographyItem])] {
        Dictionary(grouping: filteredItems) { $0.type.category }
            .sorted { ($0.value.first?.type.categoryOrder ?? 0) < ($1.value.first?.type.categoryOrder ?? 0) }
            .map { ($0.key, $0.value) }
    }

    var body: some View {
        List {
            Section {
                Picker("Karte", selection: $selectedMap) {
                    ForEach(CalibrationMap.allCases) { m in
                        Text(m.displayName).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                HStack(alignment: .top) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(AppColors.accent)
                    Text("Tippe auf ein Item und setze den Punkt selbst. Apple und Atlas haben getrennte Overrides — Änderungen auf einer Karte beeinflussen die andere nicht.")
                        .font(.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
                HStack {
                    Text("Kalibriert auf \(selectedMap.displayName)")
                    Spacer()
                    Text("\(store.calibratedCount(on: selectedMap)) / \(items.count)")
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            ForEach(grouped, id: \.0) { category, list in
                Section(category) {
                    ForEach(list) { item in
                        if item.isCustom, let customId = customId(for: item) {
                            Button {
                                editingCustom = customStore.item(id: customId)
                            } label: {
                                row(for: item)
                            }
                            .foregroundStyle(AppColors.textPrimary)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    customStore.delete(id: customId)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                        } else {
                            NavigationLink {
                                CalibrationItemView(item: item, map: selectedMap)
                            } label: {
                                row(for: item)
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Suchen")
        .navigationTitle("Kalibrierung")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    Button {
                        showAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }

                    Menu {
                        Button {
                            exportText = generateExport()
                            showExportSheet = true
                        } label: {
                            Label("Code exportieren (\(selectedMap.displayName))", systemImage: "square.and.arrow.up")
                        }
                        Button(role: .destructive) {
                            showResetConfirm = true
                        } label: {
                            Label("Alle zurücksetzen (\(selectedMap.displayName))", systemImage: "arrow.counterclockwise")
                        }
                        .disabled(store.calibratedCount(on: selectedMap) == 0)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            CustomItemEditorView()
        }
        .sheet(item: $editingCustom) { item in
            CustomItemEditorView(item: item)
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheet(text: exportText)
        }
        .confirmationDialog(
            "Alle \(store.calibratedCount(on: selectedMap)) Kalibrierungen für \(selectedMap.displayName) löschen?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                store.clearAll(on: selectedMap)
            }
            Button("Abbrechen", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func row(for item: GeographyItem) -> some View {
        HStack {
            Image(systemName: item.type.iconName)
                .foregroundStyle(item.isCustom ? AppColors.primary : AppColors.accent)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.subheadline)
                    if item.isCustom {
                        Text("eigen")
                            .font(.caption2)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(AppColors.primary.opacity(0.15))
                            .foregroundStyle(AppColors.primary)
                            .clipShape(Capsule())
                    }
                }
                Text(positionText(for: item))
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            if item.isCalibrated(on: selectedMap) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }
    }

    /// Extract the UUID from a custom item's id (`custom-<uuid>`).
    private func customId(for item: GeographyItem) -> UUID? {
        guard item.isCustom else { return nil }
        let raw = item.id.replacingOccurrences(of: "custom-", with: "")
        return UUID(uuidString: raw)
    }

    private func coordText(_ c: CLLocationCoordinate2D) -> String {
        String(format: "%.3f, %.3f", c.latitude, c.longitude)
    }

    private func positionText(for item: GeographyItem) -> String {
        if selectedMap == .naAtlas {
            if let p = item.naMapPoint {
                return String(format: "x %.2f, y %.2f", p.x, p.y)
            }
            return "— nicht gesetzt"
        }
        return coordText(item.coordinate(for: selectedMap))
    }

    private func generateExport() -> String {
        let overridden = items.filter { $0.isCalibrated(on: selectedMap) }
        guard !overridden.isEmpty else {
            return "// Noch keine Kalibrierungen für \(selectedMap.displayName) gespeichert."
        }
        if selectedMap == .naAtlas {
            var lines = [
                "// \(overridden.count) NA-Kalibrierungen — Werte in GeographyData.swift als naMapX/naMapY übernehmen:",
                ""
            ]
            for item in overridden {
                if let p = item.naMapPoint {
                    lines.append(String(format: "%@ → naMapX: %.3f, naMapY: %.3f", item.name, p.x, p.y))
                }
            }
            return lines.joined(separator: "\n")
        }

        let latParam = selectedMap == .atlas ? "atlasLatitude" : "latitude"
        let lonParam = selectedMap == .atlas ? "atlasLongitude" : "longitude"
        var lines = [
            "// \(overridden.count) kalibrierte Items für \(selectedMap.displayName) — Werte in GeographyData.swift übernehmen:",
            "// ⚠️ Nur die \(latParam)/\(lonParam)-Werte ersetzen, die jeweils andere Karte bleibt unverändert.",
            ""
        ]
        for item in overridden {
            let c = item.coordinate(for: selectedMap)
            lines.append(
                String(
                    format: "%@ → %@: %.4f, %@: %.4f",
                    item.name,
                    latParam,
                    c.latitude,
                    lonParam,
                    c.longitude
                )
            )
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Item editor

private struct CalibrationItemView: View {
    let item: GeographyItem
    let map: CalibrationMap

    @Environment(\.dismiss) private var dismiss
    @State private var store = CalibrationStore.shared
    @State private var pinCoord: CLLocationCoordinate2D
    @State private var naPin: CGPoint
    @State private var cameraPosition: MapCameraPosition

    /// Base coordinate this map falls back to when no override is set.
    private var baseCoordinate: CLLocationCoordinate2D {
        map == .atlas ? item.atlasCoordinate : item.originalCoordinate
    }

    private var baseNAPoint: CGPoint {
        if let x = item.naMapX, let y = item.naMapY {
            return CGPoint(x: x, y: y)
        }
        return CGPoint(x: 0.5, y: 0.5)
    }

    init(item: GeographyItem, map: CalibrationMap) {
        self.item = item
        self.map = map
        let start = item.coordinate(for: map)
        _pinCoord = State(initialValue: start)
        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: start,
                    span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20)
                )
            )
        )
        _naPin = State(initialValue: item.naMapPoint ?? CGPoint(x: 0.5, y: 0.5))
    }

    var body: some View {
        VStack(spacing: 0) {
            mapArea

            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Text(item.name)
                            .font(.headline)
                        Text("· \(map.displayName)")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    if map == .naAtlas {
                        Text(String(format: "x %.3f, y %.3f", naPin.x, naPin.y))
                            .font(.system(.body, design: .monospaced))
                    } else {
                        Text(String(format: "%.4f°, %.4f°", pinCoord.latitude, pinCoord.longitude))
                            .font(.system(.body, design: .monospaced))
                        let dist = baseCoordinate.distance(to: pinCoord) / 1000
                        Text(String(format: "Abstand zum Original: %.0f km", dist))
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(.top, 12)

                HStack(spacing: 12) {
                    Button {
                        store.clearOverride(for: item.id, on: map)
                        if map == .naAtlas {
                            naPin = baseNAPoint
                        } else {
                            pinCoord = baseCoordinate
                        }
                    } label: {
                        Label("Original", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!item.isCalibrated(on: map))

                    Button {
                        if map == .naAtlas {
                            store.setFractionOverride(for: item.id, on: map, x: Double(naPin.x), y: Double(naPin.y))
                        } else {
                            store.setOverride(
                                for: item.id,
                                on: map,
                                latitude: pinCoord.latitude,
                                longitude: pinCoord.longitude
                            )
                        }
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    } label: {
                        Label("Speichern", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .background(AppColors.background)
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var mapArea: some View {
        switch map {
        case .apple:
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    Annotation("Original", coordinate: item.originalCoordinate) {
                        Image(systemName: "circle.dashed")
                            .font(.title2)
                            .foregroundStyle(.gray)
                            .background(Circle().fill(.white).frame(width: 18, height: 18))
                    }
                    Annotation(item.name, coordinate: pinCoord) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                    }
                }
                .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
                .onTapGesture { screenPoint in
                    if let coord = proxy.convert(screenPoint, from: .local) {
                        pinCoord = coord
                    }
                }
            }
        case .atlas:
            StummeKarteQuizView(
                onTap: { coord in pinCoord = coord },
                showTapPin: pinCoord,
                resultAnnotation: nil
            )
        case .naAtlas:
            StummeKarteNordamerikaQuizView(
                onTap: { naPin = $0 },
                placedFraction: naPin,
                correctFraction: nil,
                isCorrect: false,
                toleranceKm: 0
            )
        }
    }
}

private extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let a = CLLocation(latitude: latitude, longitude: longitude)
        let b = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return a.distance(from: b)
    }
}

// MARK: - Export sheet

private struct ExportSheet: View {
    let text: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .font(.system(.footnote, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .textSelection(.enabled)
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Schliessen") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        UIPasteboard.general.string = text
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Label("Kopieren", systemImage: "doc.on.doc")
                    }
                }
            }
        }
    }
}
