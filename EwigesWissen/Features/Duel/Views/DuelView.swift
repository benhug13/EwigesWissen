import SwiftUI

struct DuelView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var viewModel = DuelViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var questionId = UUID()
    @State private var showSetup = true
    @State private var selectedDifficulty: BotDifficulty = .medium
    @State private var resultIconScale: CGFloat = 0
    @State private var resultTitleOpacity: Double = 0
    @State private var resultScoreOpacity: Double = 0
    @State private var resultListOpacity: Double = 0

    let schoolLevel: SchoolLevel

    var body: some View {
        NavigationStack {
            Group {
                if showSetup {
                    setupView
                } else if viewModel.isCompleted {
                    duelResultView
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    quizContent
                }
            }
            .navigationTitle("Duell vs Bot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }

    // MARK: - Setup

    private var setupView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "cpu")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Duell vs Bot")
                .font(AppFonts.title)

            Text("Wähle die Schwierigkeit:")
                .font(AppFonts.headline)

            Picker("Schwierigkeit", selection: $selectedDifficulty) {
                ForEach(BotDifficulty.allCases) { diff in
                    Text(diff.rawValue).tag(diff)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 40)

            Spacer()

            AppButton("Los geht's!", icon: "play.fill") {
                viewModel.difficulty = selectedDifficulty
                viewModel.startDuel(level: schoolLevel)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showSetup = false
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Quiz Content

    private var quizContent: some View {
        VStack(spacing: 20) {
            // Score bar
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                    Text("Du")
                        .font(AppFonts.caption)
                }
                .foregroundStyle(AppColors.primary)
                Text("\(viewModel.player1Score)")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.primary)
                Spacer()
                Text(viewModel.progressText)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text("\(viewModel.player2Score)")
                    .font(AppFonts.headline)
                    .foregroundStyle(.orange)
                HStack(spacing: 4) {
                    Text("Bot")
                        .font(AppFonts.caption)
                    Image(systemName: "cpu")
                        .font(.caption)
                }
                .foregroundStyle(.orange)
            }
            .padding(.horizontal)

            ProgressBarView(progress: viewModel.progress)
                .padding(.horizontal)

            Spacer()

            // Question
            VStack(spacing: 16) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppColors.primary)
                    .symbolEffect(.bounce, value: questionId)

                Text(viewModel.questionText)
                    .font(AppFonts.quizQuestion)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .id(questionId)

            Spacer()

            // Answer
            if viewModel.showResult {
                resultView
                    .transition(.scale.combined(with: .opacity))
            } else {
                answerInput
            }
        }
        .padding()
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showResult)
    }

    private var answerInput: some View {
        VStack(spacing: 16) {
            TextField("Antwort eingeben...", text: $viewModel.userAnswer)
                .font(AppFonts.quizInput)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .focused($isInputFocused)
                .onSubmit { submitAnswer() }
                .padding(.horizontal)

            AppButton("Prüfen", icon: "checkmark") {
                submitAnswer()
            }
            .padding(.horizontal, 40)
            .disabled(viewModel.userAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .onAppear { isInputFocused = true }
    }

    private var resultView: some View {
        VStack(spacing: 16) {
            // Your result
            HStack(spacing: 30) {
                VStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                    if viewModel.isCorrect {
                        MiniSuccessView()
                    } else {
                        MiniWrongView()
                    }
                    Text(viewModel.isCorrect ? "Richtig!" : "Falsch")
                        .font(AppFonts.caption)
                        .foregroundStyle(viewModel.isCorrect ? AppColors.success : AppColors.error)
                }

                VStack(spacing: 8) {
                    Image(systemName: "cpu")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    if viewModel.botCorrect {
                        MiniSuccessView()
                    } else {
                        MiniWrongView()
                    }
                    Text(viewModel.botCorrect ? "Richtig" : "Falsch")
                        .font(AppFonts.caption)
                        .foregroundStyle(viewModel.botCorrect ? AppColors.success : AppColors.error)
                }
            }

            if !viewModel.isCorrect {
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

    private func submitAnswer() {
        viewModel.submitAnswer()
        if viewModel.isCorrect {
            SoundService.shared.playCorrect()
            HapticService.shared.success()
            appState.recordCorrectAnswer()
        } else {
            SoundService.shared.playIncorrect()
            HapticService.shared.error()
            appState.recordWrongAnswer()
        }
    }

    // MARK: - Result

    private var duelResultView: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.isDraw {
                    Image(systemName: "equal.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(AppColors.primary)
                        .scaleEffect(resultIconScale)
                    Text("Unentschieden!")
                        .font(AppFonts.title)
                        .opacity(resultTitleOpacity)
                } else if viewModel.player1Score > viewModel.player2Score {
                    ConfettiView()
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(AppColors.starFilled)
                        .scaleEffect(resultIconScale)
                    Text("Du gewinnst!")
                        .font(AppFonts.title)
                        .opacity(resultTitleOpacity)
                } else {
                    Image(systemName: "cpu")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)
                        .scaleEffect(resultIconScale)
                    Text("Bot gewinnt!")
                        .font(AppFonts.title)
                        .opacity(resultTitleOpacity)
                }

                // Final score
                HStack(spacing: 40) {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                            Text("Du")
                        }
                        .font(AppFonts.headline)
                        Text("\(viewModel.player1Score)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(viewModel.player1Score >= viewModel.player2Score ? AppColors.success : AppColors.textSecondary)
                        Text("/ \(viewModel.questions.count)")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Text("vs")
                        .font(AppFonts.title2)
                        .foregroundStyle(AppColors.textTertiary)
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "cpu")
                            Text("Bot")
                        }
                        .font(AppFonts.headline)
                        Text("\(viewModel.player2Score)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(viewModel.player2Score >= viewModel.player1Score ? AppColors.success : AppColors.textSecondary)
                        Text("/ \(viewModel.questions.count)")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .opacity(resultScoreOpacity)

                // Question-by-question comparison
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ergebnisse")
                        .font(AppFonts.headline)

                    ForEach(Array(viewModel.questions.enumerated()), id: \.offset) { index, capital in
                        HStack {
                            Text(capital.country)
                                .font(AppFonts.subheadline)
                            Spacer()
                            Image(systemName: index < viewModel.player1Results.count && viewModel.player1Results[index] ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(index < viewModel.player1Results.count && viewModel.player1Results[index] ? AppColors.success : AppColors.error)
                            Text("/")
                                .foregroundStyle(AppColors.textTertiary)
                            Image(systemName: index < viewModel.player2Results.count && viewModel.player2Results[index] ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(index < viewModel.player2Results.count && viewModel.player2Results[index] ? AppColors.success : AppColors.error)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding()
                .background(AppColors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .opacity(resultListOpacity)

                AppButton("Fertig", icon: "checkmark") {
                    dismiss()
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
        .onAppear {
            SoundService.shared.playSuccess()
            HapticService.shared.success()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                resultIconScale = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                resultTitleOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                resultScoreOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.7)) {
                resultListOpacity = 1
            }
        }
    }
}
