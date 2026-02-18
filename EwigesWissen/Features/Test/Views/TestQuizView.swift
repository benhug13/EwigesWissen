import SwiftUI
import SwiftData
import MapKit

struct TestQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var viewModel = TestQuizViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.0, longitude: 10.0),
            span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 160)
        )
    )
    @State private var timer: Timer?
    @State private var questionId = UUID()
    @State private var lastWarningMinute: Int = -1
    @AppStorage("mapStyle") private var mapStyleSetting = "Apple Karten"

    let schoolLevel: SchoolLevel

    private var selectedMapStyle: MapStyle {
        MapStyle(rawValue: mapStyleSetting) ?? .apple
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isCompleted {
                    TestResultView(viewModel: viewModel) {
                        saveAndDismiss()
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    quizContent
                }
            }
            .navigationTitle("Probeprüfung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        stopTimer()
                        dismiss()
                    }
                }
                if !viewModel.isCompleted {
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.subheadline)
                                .symbolEffect(.pulse, isActive: viewModel.timeRemaining <= 60)
                            Text(viewModel.timerText)
                                .font(.system(.headline, design: .monospaced))
                        }
                        .foregroundStyle(viewModel.timerColor)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.timerColor)
                    }
                }
            }
        }
        .onAppear {
            viewModel.startTest(level: schoolLevel)
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            viewModel.tick()
            checkTimerWarnings()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func checkTimerWarnings() {
        let minutesLeft = Int(viewModel.timeRemaining) / 60
        // Haptic warning at 5, 3, 1 minute marks
        if minutesLeft != lastWarningMinute && [5, 3, 1].contains(minutesLeft) && Int(viewModel.timeRemaining) % 60 == 0 {
            lastWarningMinute = minutesLeft
            HapticService.shared.warning()
        }
        // Heavy haptic every 10 seconds in last minute
        if viewModel.timeRemaining <= 60 && viewModel.timeRemaining > 0 && Int(viewModel.timeRemaining) % 10 == 0 {
            HapticService.shared.heavyImpact()
        }
        // Time's up
        if viewModel.timeRemaining <= 0 {
            HapticService.shared.error()
            SoundService.shared.playIncorrect()
        }
    }

    // MARK: - Quiz Content

    private var quizContent: some View {
        VStack(spacing: 0) {
            // Progress
            VStack(spacing: 4) {
                ProgressBarView(progress: viewModel.progress)
                Text(viewModel.progressText)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if let question = viewModel.currentQuestion {
                Group {
                    switch question {
                    case .countryToCapital, .capitalToCountry:
                        capitalQuizContent(question: question)
                    case .geography(let item):
                        geographyQuizContent(item: item)
                    }
                }
                .id(questionId)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: questionId)
    }

    // MARK: - Capital Quiz Content

    private func capitalQuizContent(question: TestQuestion) -> some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: question.typeIcon)
                    .font(.system(size: 44))
                    .foregroundStyle(AppColors.primary)
                    .symbolEffect(.bounce, value: questionId)

                Text(viewModel.capitalQuestionText)
                    .font(AppFonts.quizQuestion)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 16) {
                TextField("Antwort eingeben...", text: $viewModel.userAnswer)
                    .font(AppFonts.quizInput)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .focused($isInputFocused)
                    .onSubmit {
                        if !viewModel.userAnswer.trimmingCharacters(in: .whitespaces).isEmpty {
                            submitCapitalAndAdvance()
                        }
                    }
                    .padding(.horizontal)

                AppButton("Weiter", icon: "arrow.right") {
                    submitCapitalAndAdvance()
                }
                .padding(.horizontal, 40)
                .disabled(viewModel.userAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .onAppear {
                isInputFocused = true
            }
        }
        .padding()
    }

    private func submitCapitalAndAdvance() {
        HapticService.shared.impact()
        let itemId = viewModel.currentQuestion?.id ?? ""
        viewModel.submitCapitalAnswer()
        // Record progress from last result
        if let lastResult = viewModel.results.last {
            let progress = ProgressService(modelContext: modelContext)
            progress.recordAnswer(itemId: itemId, itemType: "capital", correct: lastResult.isCorrect)
            if lastResult.isCorrect {
                appState.recordCorrectAnswer()
            } else {
                appState.recordWrongAnswer()
            }
        }
        isInputFocused = true
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            questionId = UUID()
        }
    }

    // MARK: - Geography Quiz Content

    private func geographyQuizContent(item: GeographyItem) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: item.type.iconName)
                    .foregroundStyle(AppColors.geographyColor(for: item.type))
                    .symbolEffect(.bounce, value: questionId)
                Text("Wo liegt \(item.name)?")
                    .font(AppFonts.headline)
            }
            .padding(.vertical, 8)

            if selectedMapStyle == .stummeKarte {
                stummeKarteQuiz
            } else {
                appleMapQuiz
            }

            AppButton("Weiter", icon: "arrow.right") {
                HapticService.shared.impact()
                let itemId = viewModel.currentQuestion?.id ?? ""
                viewModel.confirmGeoAnswer()
                if let lastResult = viewModel.results.last {
                    let progress = ProgressService(modelContext: modelContext)
                    progress.recordAnswer(itemId: itemId, itemType: "geography", correct: lastResult.isCorrect)
                    if lastResult.isCorrect {
                        appState.recordCorrectAnswer()
                    } else {
                        appState.recordWrongAnswer()
                    }
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    questionId = UUID()
                }
            }
            .disabled(viewModel.placedPin == nil)
            .padding()
        }
    }

    // MARK: - Apple Maps Quiz

    private var appleMapQuiz: some View {
        MapReader { proxy in
            Map(position: $cameraPosition) {
                if let pin = viewModel.placedPin {
                    Annotation("Deine Antwort", coordinate: pin) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(AppColors.primary)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll, showsTraffic: false))
            .onTapGesture { position in
                if let coordinate = proxy.convert(position, from: .local) {
                    viewModel.placePin(at: coordinate)
                    HapticService.shared.tap()
                    SoundService.shared.playTap()
                }
            }
        }
    }

    // MARK: - Stumme Karte Quiz

    private var stummeKarteQuiz: some View {
        StummeKarteQuizView(
            onTap: { coordinate in
                viewModel.placePin(at: coordinate)
                HapticService.shared.tap()
                SoundService.shared.playTap()
            },
            showTapPin: viewModel.placedPin,
            resultAnnotation: nil
        )
    }

    // MARK: - Helpers

    private func saveAndDismiss() {
        stopTimer()
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

        // Check grade - show teacher if under 3.0
        let accuracy = viewModel.questions.isEmpty ? 0 : Double(viewModel.correctCount) / Double(viewModel.questions.count)
        let grade = ((1.0 + 5.0 * accuracy) * 2).rounded() / 2
        if grade < 3.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                appState.showTeacherMessage = true
            }
        }

        dismiss()
    }
}
