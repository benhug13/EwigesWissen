import SwiftUI
import SwiftData

struct ItemProgressView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var refreshId = UUID()

    var body: some View {
        VStack(spacing: 0) {
            Picker("Kategorie", selection: $selectedTab) {
                Text("Hauptstädte").tag(0)
                Text("Geografie").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == 0 {
                capitalsProgressList
            } else {
                geographyProgressList
            }
        }
        .id(refreshId)
        .navigationTitle("Lernfortschritt")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Capitals

    private var capitalsProgressList: some View {
        let capitals = DataService.shared.capitals(for: appState.schoolLevel)
        let progress = ProgressService(modelContext: modelContext)
        let allProgress = progress.allProgress()
        let progressMap = Dictionary(uniqueKeysWithValues: allProgress.map { ($0.itemId, $0) })

        return List {
            ForEach(capitals.sorted(by: { $0.country < $1.country })) { capital in
                let itemProgress = progressMap[capital.id]
                HStack {
                    Circle()
                        .fill(masteryColor(for: itemProgress))
                        .frame(width: 10, height: 10)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(capital.country)
                            .font(AppFonts.subheadline)
                        Text(capital.capital)
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    if let p = itemProgress {
                        Text("\(p.correctCount)/\(p.correctCount + p.incorrectCount)")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    bookmarkButton(itemId: capital.id, itemType: "capital", isBookmarked: itemProgress?.isBookmarked ?? false)
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Geography

    private var geographyProgressList: some View {
        let items = DataService.shared.geographyItems(for: appState.schoolLevel)
        let progress = ProgressService(modelContext: modelContext)
        let allProgress = progress.allProgress()
        let progressMap = Dictionary(uniqueKeysWithValues: allProgress.map { ($0.itemId, $0) })
        let categories = Dictionary(grouping: items, by: { $0.type.category })
        let sortedCategories = categories.sorted { a, b in
            let orderA = a.value.first?.type.categoryOrder ?? 99
            let orderB = b.value.first?.type.categoryOrder ?? 99
            return orderA < orderB
        }

        return List {
            ForEach(sortedCategories, id: \.key) { category, categoryItems in
                Section {
                    ForEach(categoryItems.sorted(by: { $0.name < $1.name })) { item in
                        let itemProgress = progressMap[item.id]
                        HStack {
                            Circle()
                                .fill(masteryColor(for: itemProgress))
                                .frame(width: 10, height: 10)
                            Image(systemName: item.type.iconName)
                                .font(.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                            Text(item.name)
                                .font(AppFonts.subheadline)
                            Spacer()
                            if let p = itemProgress {
                                Text("\(p.correctCount)/\(p.correctCount + p.incorrectCount)")
                                    .font(AppFonts.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            bookmarkButton(itemId: item.id, itemType: "geography", isBookmarked: itemProgress?.isBookmarked ?? false)
                        }
                    }
                } header: {
                    Text(category)
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Helpers

    private func bookmarkButton(itemId: String, itemType: String, isBookmarked: Bool) -> some View {
        Button {
            let progress = ProgressService(modelContext: modelContext)
            progress.toggleBookmark(itemId: itemId, itemType: itemType)
            HapticService.shared.tap()
            refreshId = UUID()
        } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .foregroundStyle(isBookmarked ? AppColors.accent : AppColors.textTertiary)
                .font(.subheadline)
        }
        .buttonStyle(.plain)
    }

    private func masteryColor(for progress: ItemProgress?) -> Color {
        guard let p = progress else { return AppColors.textTertiary.opacity(0.3) }
        let total = p.correctCount + p.incorrectCount
        guard total > 0 else { return AppColors.textTertiary.opacity(0.3) }
        let ratio = Double(p.correctCount) / Double(total)
        if ratio >= 0.8 { return AppColors.success }
        if ratio >= 0.5 { return AppColors.warning }
        return AppColors.error
    }
}
