import SwiftUI
import SwiftData

struct CapitalsQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var viewModel = CapitalsQuizViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var questionId = UUID()
    @State private var shakeOffset: CGFloat = 0
    @AppStorage("sessionLength") private var sessionLength = 10

    let schoolLevel: SchoolLevel
    let direction: QuizDirection
    var isMultipleChoice: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isCompleted {
                    CapitalResultView(viewModel: viewModel) {
                        saveAndDismiss()
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
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
            viewModel.startQuiz(
                level: schoolLevel,
                questionCount: sessionLength,
                direction: direction,
                multipleChoice: isMultipleChoice
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

            // Question with transition
            VStack(spacing: 16) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppColors.primary)
                    .symbolEffect(.bounce, value: questionId)

                Text(viewModel.questionText)
                    .font(AppFonts.quizQuestion)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .id(questionId)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

            Spacer()

            // Answer input
            if viewModel.showResult {
                resultOverlay
                    .transition(.scale.combined(with: .opacity))
            } else if viewModel.isMultipleChoice {
                mcAnswerInput
            } else {
                answerInput
                    .offset(x: shakeOffset)
            }
        }
        .padding()
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showResult)
    }

    private var answerInput: some View {
        VStack(spacing: 16) {
            if viewModel.attemptNumber > 1 {
                Text("Versuch \(viewModel.attemptNumber) von 3")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.warning)
                    .transition(.scale.combined(with: .opacity))
            }

            if let hint = viewModel.hintText {
                Text(hint)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.1))
                    .clipShape(Capsule())
                    .transition(.scale.combined(with: .opacity))
            }

            TextField("Antwort eingeben...", text: $viewModel.userAnswer)
                .font(AppFonts.quizInput)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .focused($isInputFocused)
                .onSubmit {
                    submitAnswer()
                }
                .padding(.horizontal)

            AppButton("Prüfen", icon: "checkmark") {
                submitAnswer()
            }
            .padding(.horizontal, 40)
            .disabled(viewModel.userAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .onAppear {
            isInputFocused = true
        }
    }

    private var mcAnswerInput: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.mcOptions, id: \.self) { option in
                Button {
                    viewModel.submitMcAnswer(option)
                    if let question = viewModel.currentQuestion {
                        let progress = ProgressService(modelContext: modelContext)
                        progress.recordAnswer(itemId: question.id, itemType: "capital", correct: viewModel.isCorrect)
                    }
                    if viewModel.isCorrect {
                        SoundService.shared.playCorrect()
                        HapticService.shared.success()
                    } else {
                        SoundService.shared.playIncorrect()
                        HapticService.shared.error()
                    }
                } label: {
                    Text(option)
                        .font(AppFonts.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.secondaryBackground)
                        .foregroundStyle(AppColors.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(BounceButtonStyle())
            }
        }
        .padding(.horizontal)
    }

    private func submitAnswer() {
        viewModel.submitAnswer()

        if viewModel.showResult {
            // Answer was final (correct or 3rd attempt) - record progress
            if let question = viewModel.currentQuestion {
                let progress = ProgressService(modelContext: modelContext)
                progress.recordAnswer(itemId: question.id, itemType: "capital", correct: viewModel.isCorrect)
            }
            if viewModel.isCorrect {
                SoundService.shared.playCorrect()
                HapticService.shared.success()
            } else {
                SoundService.shared.playIncorrect()
                HapticService.shared.error()
            }
        } else {
            // Wrong but more attempts remain - shake
            SoundService.shared.playIncorrect()
            HapticService.shared.warning()
            shakeAnimation()
        }
    }

    private func shakeAnimation() {
        withAnimation(.spring(response: 0.08, dampingFraction: 0.2)) {
            shakeOffset = 12
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.08, dampingFraction: 0.2)) {
                shakeOffset = -12
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.spring(response: 0.08, dampingFraction: 0.2)) {
                shakeOffset = 8
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                shakeOffset = 0
            }
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
                WrongAnimationView()

                Text("Die richtige Antwort:")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textSecondary)

                Text(viewModel.correctAnswer)
                    .font(AppFonts.quizAnswer)
                    .foregroundStyle(AppColors.primary)
            }

            AppButton("Weiter", icon: "arrow.right") {
                HapticService.shared.selection()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.nextQuestion()
                    questionId = UUID()
                }
                isInputFocused = true
            }
            .padding(.horizontal, 40)
        }
    }

    private func starsView(count: Int) -> some View {
        StarsAnimationView(count: count)
    }

    private func saveAndDismiss() {
        let session = viewModel.createSession()

        if let user = appState.currentUser {
            let engagement = EngagementService(modelContext: modelContext)
            let streakContinued = engagement.recordQuizCompletion(session: session, user: user)
            if streakContinued {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    appState.showStreakCelebration = user.currentStreak
                }
            }
        } else {
            modelContext.insert(session)
            try? modelContext.save()
        }

        dismiss()
    }

}
