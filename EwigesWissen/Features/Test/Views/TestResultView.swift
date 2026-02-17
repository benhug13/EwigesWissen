import SwiftUI

struct TestResultView: View {
    let viewModel: TestQuizViewModel
    let onDismiss: () -> Void
    @State private var showShareSheet = false
    @State private var iconScale: CGFloat = 0
    @State private var titleOpacity: Double = 0
    @State private var gradeScale: CGFloat = 0
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

                    Text(viewModel.timerExpired ? "Zeit abgelaufen!" : "Probeprüfung beendet!")
                        .font(AppFonts.title)
                        .opacity(titleOpacity)

                    Text(resultMessage)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(titleOpacity)
                }

                // Note
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", grade))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(gradeColor)
                    Text("Note")
                        .font(AppFonts.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.vertical, 4)
                .scaleEffect(gradeScale)

                // Stats
                HStack(spacing: 20) {
                    statBox(
                        value: "\(viewModel.correctCount)/\(viewModel.questions.count)",
                        label: "Richtig"
                    )
                    statBox(
                        value: "\(viewModel.totalStars)",
                        label: "Sterne",
                        icon: "star.fill",
                        iconColor: AppColors.starFilled
                    )
                    statBox(
                        value: "\(Int(accuracy * 100))%",
                        label: "Genauigkeit"
                    )
                }
                .opacity(statsOpacity)

                // Grouped results
                let capitalResults = zip(viewModel.questions, viewModel.results)
                    .filter { $0.0.isCapitalQuestion }
                let geoResults = zip(viewModel.questions, viewModel.results)
                    .filter { !$0.0.isCapitalQuestion }

                Group {
                    if !capitalResults.isEmpty {
                        resultsSection(
                            title: "Hauptstädte",
                            icon: "building.columns",
                            items: Array(capitalResults)
                        )
                    }

                    if !geoResults.isEmpty {
                        resultsSection(
                            title: "Geografie",
                            icon: "globe.europe.africa.fill",
                            items: Array(geoResults)
                        )
                    }
                }
                .opacity(listOpacity)

                HStack(spacing: 12) {
                    ShareLink(
                        item: shareText,
                        subject: Text("Probeprüfung"),
                        message: Text(shareText)
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Teilen")
                        }
                        .font(AppFonts.headline)
                        .foregroundStyle(AppColors.primary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(AppColors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    AppButton("Fertig", icon: "checkmark") {
                        onDismiss()
                    }
                }
                .padding(.horizontal, 20)
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
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.5)) {
                gradeScale = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.7)) {
                statsOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.9)) {
                listOpacity = 1
            }
        }
    }

    private var shareText: String {
        let emoji: String
        if grade >= 5.0 { emoji = "🏆" }
        else if grade >= 4.0 { emoji = "👍" }
        else { emoji = "📝" }

        return """
        \(emoji) EwigesWissen Probeprüfung
        Note: \(String(format: "%.1f", grade))
        Richtig: \(viewModel.correctCount)/\(viewModel.questions.count) (\(Int(accuracy * 100))%)
        Sterne: \(viewModel.totalStars) ⭐
        """
    }

    // MARK: - Results Section

    private func resultsSection(title: String, icon: String, items: [(TestQuestion, QuizResult)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(AppColors.primary)
                Text(title)
                    .font(AppFonts.headline)
            }

            ForEach(Array(items.enumerated()), id: \.offset) { _, pair in
                let (_, result) = pair
                HStack {
                    Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(result.isCorrect ? AppColors.success : AppColors.error)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.questionText)
                            .font(AppFonts.subheadline)

                        if result.isCorrect {
                            Text("Deine Antwort: \(result.userAnswer)")
                                .font(AppFonts.caption)
                                .foregroundStyle(AppColors.success)
                        } else {
                            Text("Deine Antwort: \(result.userAnswer)")
                                .font(AppFonts.caption)
                                .foregroundStyle(AppColors.error)
                            Text("Richtig: \(result.correctAnswer)")
                                .font(AppFonts.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

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
    }

    // MARK: - Computed Properties

    private var accuracy: Double {
        guard !viewModel.questions.isEmpty else { return 0 }
        return Double(viewModel.correctCount) / Double(viewModel.questions.count)
    }

    /// Schweizer Notenskala: 1 (schlechteste) bis 6 (beste)
    /// Formel: Note = 1 + 5 × (richtig / total), gerundet auf 0.5
    private var grade: Double {
        let raw = 1.0 + 5.0 * accuracy
        return (raw * 2).rounded() / 2 // auf 0.5 runden
    }

    private var gradeColor: Color {
        if grade >= 5.0 { return AppColors.success }
        if grade >= 4.0 { return AppColors.primary }
        if grade >= 3.5 { return AppColors.warning }
        return AppColors.error
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
        if viewModel.timerExpired {
            return "Die Zeit ist abgelaufen. \(viewModel.correctCount) von \(viewModel.questions.count) richtig."
        }
        if accuracy >= 0.8 { return "Hervorragend! Du bist bestens vorbereitet!" }
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
