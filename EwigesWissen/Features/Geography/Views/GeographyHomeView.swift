import SwiftUI

struct GeographyHomeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let bottomSafe = geo.safeAreaInsets.bottom
                let topSafe = geo.safeAreaInsets.top
                let usableHeight = geo.size.height - topSafe - bottomSafe - 24
                let cardHeight = (usableHeight - 16) / CGFloat(GeographyRegion.allCases.count)

                VStack(spacing: 16) {
                    ForEach(GeographyRegion.allCases) { region in
                        NavigationLink {
                            GeographyLearningView(region: region)
                                .environment(appState)
                        } label: {
                            regionCard(region)
                                .frame(height: cardHeight)
                        }
                        .buttonStyle(PressableCardStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .navigationTitle("Geografie")
        }
    }

    private func regionCard(_ region: GeographyRegion) -> some View {
        let count = DataService.shared.geographyItems(for: appState.schoolLevel, region: region).count

        return ZStack(alignment: .bottomLeading) {
            // Map image as soft background
            Image(backgroundImage(for: region))
                .resizable()
                .scaledToFill()
                .opacity(0.55)
                .clipped()

            // Color tint for legibility + brand feel
            LinearGradient(
                colors: [
                    cardColor(for: region).opacity(0.10),
                    cardColor(for: region).opacity(0.55),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(region.displayName)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 2)
                    Text("\(count) Lerneinträge")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 1)
                }
                Spacer(minLength: 12)
                Image(systemName: region.iconName)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 2)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.6)
        )
        .shadow(color: cardColor(for: region).opacity(0.30), radius: 18, x: 0, y: 8)
    }

    private func backgroundImage(for region: GeographyRegion) -> String {
        switch region {
        case .world: return "StummeKarte"
        case .northAmerica: return "StummeKarteNordamerika"
        }
    }

    private func cardColor(for region: GeographyRegion) -> Color {
        switch region {
        case .world: return AppColors.secondary
        case .northAmerica: return AppColors.accent
        }
    }
}

private struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
