import SwiftUI

struct GeographyResultView: View {
    let viewModel: GeographyQuizViewModel
    let onDismiss: () -> Void
    @State private var iconScale: CGFloat = 0
    @State private var titleOpacity: Double = 0
    @State private var statsOpacity: Double = 0
    @State private var listOpacity: Double = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    if accuracy >= 0.8 {
                        ConfettiView()
                    }

                    Image(systemName: resultIcon)
                        .font(.system(size: 60))
                        .foregroundStyle(resultColor)
                        .scaleEffect(iconScale)

                    Text("Quiz beendet!")
                        .font(AppFonts.title)
                        .opacity(titleOpacity)

                    Text(resultMessage)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(titleOpacity)
                }

                // Stats
                HStack(spacing: 20) {
                    statBox(value: "\(viewModel.correctCount)/\(viewModel.questions.count)", label: "Richtig")
                    statBox(value: "\(viewModel.totalStars)", label: "Sterne", icon: "star.fill", iconColor: AppColors.starFilled)
                }
                .opacity(statsOpacity)

                // Results detail
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ergebnisse")
                        .font(AppFonts.headline)

                    ForEach(Array(zip(viewModel.questions.indices, viewModel.results)), id: \.0) { index, result in
                        let item = viewModel.questions[index]
                        HStack {
                            Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(result.isCorrect ? AppColors.success : AppColors.error)

                            Image(systemName: item.type.iconName)
                                .foregroundStyle(AppColors.geographyColor(for: item.type))
                                .font(.caption)

                            Text(item.name)
                                .font(AppFonts.subheadline)

                            Spacer()

                            HStack(spacing: 2) {
                                ForEach(0..<3, id: \.self) { i in
                                    Image(systemName: i < result.starsEarned ? "star.fill" : "star")
                                        .font(.caption)
                                        .foregroundStyle(i < result.starsEarned ? AppColors.starFilled : AppColors.starEmpty)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(AppColors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .opacity(listOpacity)

                AppButton("Fertig", icon: "checkmark") {
                    onDismiss()
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
        .onAppear {
            SoundService.shared.playSuccess()
            HapticService.shared.success()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                iconScale = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                titleOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                statsOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.7)) {
                listOpacity = 1
            }
        }
    }

    private var accuracy: Double {
        guard !viewModel.questions.isEmpty else { return 0 }
        return Double(viewModel.correctCount) / Double(viewModel.questions.count)
    }

    private var resultIcon: String {
        if accuracy >= 0.8 { return "trophy.fill" }
        if accuracy >= 0.5 { return "hand.thumbsup.fill" }
        return "arrow.counterclockwise"
    }

    private var resultColor: Color {
        if accuracy >= 0.8 { return AppColors.starFilled }
        if accuracy >= 0.5 { return AppColors.primary }
        return AppColors.textSecondary
    }

    private var resultMessage: String {
        if accuracy >= 0.8 { return "Hervorragend! Du bist ein Geografie-Experte!" }
        if accuracy >= 0.5 { return "Gut gemacht! Weiter üben!" }
        return "Übung macht den Meister. Versuch es nochmal!"
    }

    private func statBox(value: String, label: String, icon: String? = nil, iconColor: Color = AppColors.primary) -> some View {
        AppCard {
            VStack(spacing: 4) {
                if let icon {
                    HStack(spacing: 4) {
                        Image(systemName: icon)
                            .foregroundStyle(iconColor)
                        Text(value)
                            .font(AppFonts.statNumber)
                    }
                } else {
                    Text(value)
                        .font(AppFonts.statNumber)
                }
                Text(label)
                    .font(AppFonts.statLabel)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}
