import SwiftUI
import MapKit

struct GeographyLearningView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = GeographyLearningViewModel()
    @State private var showQuiz = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.0, longitude: 14.0),
            span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 40)
        )
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter chips
                filterChips
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                // Map
                Map(position: $cameraPosition) {
                    ForEach(viewModel.filteredItems) { item in
                        Annotation(item.name, coordinate: item.coordinate) {
                            VStack(spacing: 2) {
                                Image(systemName: item.type.iconName)
                                    .font(.caption)
                                    .padding(6)
                                    .background(AppColors.geographyColor(for: item.type))
                                    .foregroundStyle(.white)
                                    .clipShape(Circle())

                                Text(item.name)
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
            }
            .navigationTitle("Geografie")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showQuiz = true
                    } label: {
                        Label("Quiz", systemImage: "play.fill")
                    }
                }
            }
            .onAppear {
                viewModel.loadItems(for: appState.schoolLevel)
            }
            .onChange(of: appState.schoolLevel) { _, newValue in
                viewModel.loadItems(for: newValue)
            }
            .fullScreenCover(isPresented: $showQuiz) {
                GeographyQuizView(schoolLevel: appState.schoolLevel)
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "Alle", type: nil)
                ForEach(viewModel.availableTypes) { type in
                    filterChip(title: type.displayName, type: type)
                }
            }
        }
    }

    private func filterChip(title: String, type: GeographyType?) -> some View {
        let isSelected = viewModel.selectedType == type

        return Button {
            viewModel.selectType(type)
        } label: {
            HStack(spacing: 4) {
                if let type {
                    Image(systemName: type.iconName)
                        .font(.caption2)
                }
                Text(title)
                    .font(AppFonts.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? AppColors.primary : AppColors.secondaryBackground)
            .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
            .clipShape(Capsule())
        }
    }
}
