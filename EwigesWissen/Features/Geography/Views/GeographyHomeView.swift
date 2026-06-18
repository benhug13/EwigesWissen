import SwiftUI

struct GeographyHomeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Was möchtest du lernen?")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)

                ForEach(GeographyRegion.allCases) { region in
                    NavigationLink {
                        GeographyLearningView(region: region)
                            .environment(appState)
                    } label: {
                        regionCard(region)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Geografie")
        }
    }

    private func regionCard(_ region: GeographyRegion) -> some View {
        let count = DataService.shared.geographyItems(for: appState.schoolLevel, region: region).count
        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(cardColor(for: region).opacity(0.18))
                    .frame(width: 56, height: 56)
                Image(systemName: region.iconName)
                    .font(.title)
                    .foregroundStyle(cardColor(for: region))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(region.displayName)
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(count) Lerneinträge")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
        )
        .shadow(color: cardColor(for: region).opacity(0.18), radius: 16, x: 0, y: 6)
    }

    private func cardColor(for region: GeographyRegion) -> Color {
        switch region {
        case .world: return AppColors.secondary
        case .northAmerica: return AppColors.accent
        }
    }
}
