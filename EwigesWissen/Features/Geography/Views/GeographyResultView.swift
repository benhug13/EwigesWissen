import SwiftUI

struct GeographyResultView: View {
    let viewModel: GeographyQuizViewModel
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    if viewModel.correctCount == viewModel.questions.count {
                        ConfettiView()
                    }

                    Image(systemName: resultIcon)
                        .font(.system(size: 60))
                        .foregroundStyle(resultColor)

                    Text("Quiz beendet!")
                        .font(AppFonts.title)

                    Text(resultMessage)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Stats
                HStack(spacing: 20) {
                    statBox(value: "\(viewModel.correctCount)/\(viewModel.questions.count)", label: "Richtig")
                    statBox(value: "\(viewModel.totalStars)", label: "Sterne", icon: "star.fill", iconColor: AppColors.starFilled)
                }

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

                AppButton("Fertig", icon: "checkmark") {
                    onDismiss()
                }
                .padding(.horizontal, 40)
            }
            .padding()
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
