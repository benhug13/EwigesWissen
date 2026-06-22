import SwiftUI
import SwiftData
import MapKit

struct GeographyLearningView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = GeographyLearningViewModel()
    @State private var showQuiz = false
    @State private var quizFilterType: GeographyType? = nil
    @State private var quizFilterTypes: [GeographyType]? = nil
    @State private var cameraPosition: MapCameraPosition
    @AppStorage("mapStyle") private var mapStyleSetting = "Apple Karten"

    let region: GeographyRegion

    init(region: GeographyRegion = .world) {
        self.region = region
        // For NA mode the stumme Karte isn't calibrated yet, so always start on Apple.
        _cameraPosition = State(initialValue: .region(region.cameraRegion))
    }

    private var mapStyle: MapStyle {
        MapStyle(rawValue: mapStyleSetting) ?? .apple
    }

    var body: some View {
        VStack(spacing: 0) {
            if mapStyle == .stummeKarte {
                if region == .northAmerica {
                    filterChips
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    StummeKarteNordamerikaLernView(items: viewModel.filteredByCategory)
                } else {
                    stummeKarteContent
                }
            } else {
                // Filter chips
                filterChips
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                appleMapContent
            }
        }
            .navigationTitle(region == .world ? "Welt" : "Nordamerika")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            quizFilterType = nil
                            quizFilterTypes = nil
                            showQuiz = true
                        } label: {
                            Label("Alle Kategorien", systemImage: "globe")
                        }
                        Button {
                            quizFilterType = nil
                            quizFilterTypes = [.river, .sea, .lake]
                            showQuiz = true
                        } label: {
                            Label("Gewässer", systemImage: "water.waves")
                        }
                        Button {
                            quizFilterType = .mountain
                            quizFilterTypes = nil
                            showQuiz = true
                        } label: {
                            Label("Gebirge", systemImage: "mountain.2.fill")
                        }
                        Button {
                            quizFilterType = nil
                            quizFilterTypes = [.island, .peninsula]
                            showQuiz = true
                        } label: {
                            Label("Inseln & Halbinseln", systemImage: "leaf.fill")
                        }
                        Button {
                            quizFilterType = .continent
                            quizFilterTypes = nil
                            showQuiz = true
                        } label: {
                            Label("Kontinente", systemImage: "globe")
                        }
                        Button {
                            quizFilterType = .country
                            quizFilterTypes = nil
                            showQuiz = true
                        } label: {
                            Label("Länder", systemImage: "flag.fill")
                        }
                        Button {
                            quizFilterType = .city
                            quizFilterTypes = nil
                            showQuiz = true
                        } label: {
                            Label("Städte", systemImage: "building.2.fill")
                        }
                        Button {
                            quizFilterType = .landscape
                            quizFilterTypes = nil
                            showQuiz = true
                        } label: {
                            Label("Landschaften", systemImage: "photo.fill")
                        }
                        Button {
                            quizFilterType = .landmark
                            quizFilterTypes = nil
                            showQuiz = true
                        } label: {
                            Label("Weltwunder/Rekorde", systemImage: "star.circle.fill")
                        }
                        Button {
                            quizFilterType = .history
                            quizFilterTypes = nil
                            showQuiz = true
                        } label: {
                            Label("Geschichte", systemImage: "scroll.fill")
                        }
                    } label: {
                        Label("Quiz", systemImage: "play.fill")
                    }
                }
            }
            .onAppear {
                viewModel.loadItems(for: appState.schoolLevel, region: region)
            }
            .onChange(of: appState.schoolLevel) { _, newValue in
                viewModel.loadItems(for: newValue, region: region)
            }
            .fullScreenCover(isPresented: $showQuiz) {
                GeographyQuizView(schoolLevel: appState.schoolLevel, region: region, filterType: quizFilterType, filterTypes: quizFilterTypes)
            }
    }

    // MARK: - Apple Maps

    private var appleMapContent: some View {
        Map(position: $cameraPosition) {
            ForEach(viewModel.filteredByCategory) { item in
                Annotation(item.name, coordinate: item.coordinate(for: .apple)) {
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
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll, showsTraffic: false))
    }

    // MARK: - Stumme Karte

    private var stummeKarteContent: some View {
        StummeKarteLernView()
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(title: "Alle", icon: nil, types: nil)
                ForEach(viewModel.availableCategories, id: \.name) { cat in
                    categoryChip(title: cat.name, icon: cat.icon, types: cat.types)
                }
            }
        }
    }

    private func categoryChip(title: String, icon: String?, types: [GeographyType]?) -> some View {
        let isSelected = viewModel.selectedCategory == nil && types == nil ||
            (types != nil && viewModel.selectedCategory != nil && Set(types!) == Set(viewModel.selectedCategory!))

        return Button {
            viewModel.selectCategory(types)
        } label: {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(title)
                    .font(AppFonts.caption)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule().fill(AppColors.primary)
                } else {
                    Capsule().fill(.ultraThinMaterial)
                }
            }
            .overlay {
                Capsule().strokeBorder(Color.white.opacity(isSelected ? 0.0 : 0.18), lineWidth: 0.5)
            }
            .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
            .shadow(color: isSelected ? AppColors.primary.opacity(0.3) : .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
    }
}
