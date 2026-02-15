import SwiftUI
import SwiftData

struct CapitalsQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var viewModel = CapitalsQuizViewModel()
    @FocusState private var isInputFocused: Bool

    let schoolLevel: SchoolLevel
    let isCountryToCapital: Bool

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isCompleted {
                    CapitalResultView(viewModel: viewModel) {
                        saveAndDismiss()
                    }
                } else {
                    quizContent
                }
            }
            .navigationTitle("Hauptstädte-Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            let prefs = fetchPreferences()
            viewModel.startQuiz(
                level: schoolLevel,
                questionCount: prefs?.sessionLength ?? 10,
                countryToCapital: isCountryToCapital
            )
        }
    }

    private var quizContent: some View {
        VStack(spacing: 20) {
            ProgressBarView(progress: viewModel.progress)
                .padding(.horizontal)

            Text(viewModel.progressText)
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            // Question
            VStack(spacing: 16) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppColors.primary)

                Text(viewModel.questionText)
                    .font(AppFonts.quizQuestion)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            // Answer input
            if viewModel.showResult {
                resultOverlay
            } else {
                answerInput
            }
        }
        .padding()
    }

    private var answerInput: some View {
        VStack(spacing: 16) {
            if viewModel.attemptNumber > 1 {
                Text("Versuch \(viewModel.attemptNumber) von 3")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.warning)
            }

            TextField("Antwort eingeben...", text: $viewModel.userAnswer)
                .font(AppFonts.quizInput)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .focused($isInputFocused)
                .onSubmit {
                    viewModel.submitAnswer()
                }
                .padding(.horizontal)

            AppButton("Prüfen", icon: "checkmark") {
                viewModel.submitAnswer()
            }
            .padding(.horizontal, 40)
            .disabled(viewModel.userAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .onAppear {
            isInputFocused = true
        }
    }

    private var resultOverlay: some View {
        VStack(spacing: 16) {
            if viewModel.isCorrect {
                SuccessAnimationView()
                Text("Richtig!")
                    .font(AppFonts.title2)
                    .foregroundStyle(AppColors.success)

                starsView(count: viewModel.results.last?.starsEarned ?? 0)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppColors.error)

                Text("Die richtige Antwort:")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textSecondary)

                Text(viewModel.correctAnswer)
                    .font(AppFonts.quizAnswer)
                    .foregroundStyle(AppColors.primary)
            }

            AppButton("Weiter", icon: "arrow.right") {
                viewModel.nextQuestion()
                isInputFocused = true
            }
            .padding(.horizontal, 40)
        }
    }

    private func starsView(count: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < count ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundStyle(index < count ? AppColors.starFilled : AppColors.starEmpty)
            }
        }
    }

    private func saveAndDismiss() {
        let session = viewModel.createSession()

        if let user = appState.currentUser {
            let engagement = EngagementService(modelContext: modelContext)
            engagement.recordQuizCompletion(session: session, user: user)
        } else {
            modelContext.insert(session)
            try? modelContext.save()
        }

        dismiss()
    }

    private func fetchPreferences() -> UserPreferences? {
        let descriptor = FetchDescriptor<UserPreferences>()
        return try? modelContext.fetch(descriptor).first
    }
}
