import SwiftUI
import SwiftData
import MapKit

struct MistakeQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var viewModel = MistakeQuizViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.0, longitude: 10.0),
            span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 160)
        )
    )
    @State private var questionId = UUID()
    @State private var shakeOffset: CGFloat = 0
    @AppStorage("mapStyle") private var mapStyleSetting = "Apple Karten"

    let schoolLevel: SchoolLevel
    let wrongCapitals: [Capital]
    let wrongGeoItems: [GeographyItem]

    private var selectedMapStyle: MapStyle {
        MapStyle(rawValue: mapStyleSetting) ?? .apple
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isCompleted {
                    MistakeResultView(viewModel: viewModel) {
                        saveAndDismiss()
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    quizContent
                }
            }
            .navigationTitle("Fehler üben")
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
            viewModel.schoolLevel = schoolLevel
            viewModel.startQuiz(capitals: wrongCapitals, geoItems: wrongGeoItems)
        }
    }

    // MARK: - Quiz Content

    private var quizContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                ProgressBarView(progress: viewModel.progress, color: AppColors.warning)
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
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showResult)
    }

    // MARK: - Capital

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

            if viewModel.showResult {
                capitalResultOverlay
                    .transition(.scale.combined(with: .opacity))
            } else {
                capitalAnswerInput
                    .offset(x: shakeOffset)
            }
        }
        .padding()
    }

    private var capitalAnswerInput: some View {
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
                .onSubmit { submitCapitalAnswer() }
                .padding(.horizontal)

            AppButton("Prüfen", icon: "checkmark") {
                submitCapitalAnswer()
            }
            .padding(.horizontal, 40)
            .disabled(viewModel.userAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .onAppear {
            isInputFocused = true
        }
    }

    private func submitCapitalAnswer() {
        let itemId = viewModel.currentQuestion?.id ?? ""
        viewModel.submitCapitalAnswer()

        if viewModel.showResult {
            let progress = ProgressService(modelContext: modelContext)
            progress.recordAnswer(itemId: itemId, itemType: "capital", correct: viewModel.isCorrect)
            if viewModel.isCorrect {
                SoundService.shared.playCorrect()
                HapticService.shared.success()
                appState.recordCorrectAnswer()
            } else {
                SoundService.shared.playIncorrect()
                HapticService.shared.error()
                appState.recordWrongAnswer()
            }
        } else {
            SoundService.shared.playIncorrect()
            HapticService.shared.warning()
            shakeAnimation()
        }
    }

    private var capitalResultOverlay: some View {
        VStack(spacing: 16) {
            if viewModel.isCorrect {
                SuccessAnimationView()
                Text("Richtig!")
                    .font(AppFonts.title2)
                    .foregroundStyle(AppColors.success)
            } else {
                WrongAnimationView()

                Text("Die richtige Antwort:")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textSecondary)

                Text(viewModel.capitalCorrectAnswer)
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

    // MARK: - Geography

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

            geoBottomBar
                .padding()
        }
    }

    private var appleMapQuiz: some View {
        MapReader { proxy in
            Map(position: $cameraPosition) {
                if let pin = viewModel.placedPin {
                    Annotation("Deine Antwort", coordinate: pin) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(viewModel.showResult
                                ? (viewModel.isCorrect ? AppColors.success : AppColors.error)
                                : AppColors.primary)
                    }
                }
                if viewModel.showResult, case .geography(let item) = viewModel.currentQuestion {
                    Annotation("Richtig", coordinate: item.coordinate) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(AppColors.success)
                    }
                    MapCircle(center: item.coordinate, radius: item.toleranceRadiusKm * 1000)
                        .foregroundStyle(AppColors.success.opacity(0.15))
                        .stroke(AppColors.success, lineWidth: 2)
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

    private var stummeKarteQuiz: some View {
        StummeKarteQuizView(
            onTap: { coordinate in
                viewModel.placePin(at: coordinate)
                HapticService.shared.tap()
                SoundService.shared.playTap()
            },
            showTapPin: viewModel.placedPin,
            resultAnnotation: viewModel.showResult && viewModel.currentQuestion != nil ? {
                if case .geography(let item) = viewModel.currentQuestion {
                    return StummeKarteResultAnnotation(
                        coordinate: item.coordinate,
                        isCorrect: viewModel.isCorrect,
                        toleranceRadiusKm: item.toleranceRadiusKm
                    )
                }
                return nil
            }() : nil
        )
    }

    private var geoBottomBar: some View {
        VStack(spacing: 8) {
            if viewModel.showResult {
                HStack {
                    if viewModel.isCorrect {
                        MiniSuccessView()
                    } else {
                        MiniWrongView()
                    }
                    Text(viewModel.isCorrect ? "Richtig!" : "Leider falsch")
                        .font(AppFonts.headline)
                        .foregroundStyle(viewModel.isCorrect ? AppColors.success : AppColors.error)
                    Spacer()
                    Text(String(format: "%.0f km Abstand", viewModel.distanceKm))
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .transition(.scale.combined(with: .opacity))

                AppButton("Weiter", icon: "arrow.right") {
                    HapticService.shared.selection()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.nextQuestion()
                        questionId = UUID()
                    }
                }
            } else {
                AppButton("Bestätigen", icon: "checkmark") {
                    if let question = viewModel.currentQuestion {
                        let itemId = question.id
                        viewModel.confirmGeoAnswer()
                        let progress = ProgressService(modelContext: modelContext)
                        progress.recordAnswer(itemId: itemId, itemType: "geography", correct: viewModel.isCorrect)
                    }
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
                .disabled(viewModel.placedPin == nil)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.showResult)
    }

    // MARK: - Helpers

    private func shakeAnimation() {
        withAnimation(.spring(response: 0.08, dampingFraction: 0.2)) { shakeOffset = 12 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.08, dampingFraction: 0.2)) { shakeOffset = -12 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.spring(response: 0.08, dampingFraction: 0.2)) { shakeOffset = 8 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) { shakeOffset = 0 }
        }
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

// MARK: - Result View

struct MistakeResultView: View {
    let viewModel: MistakeQuizViewModel
    let onDismiss: () -> Void
    @State private var iconScale: CGFloat = 0
    @State private var titleOpacity: Double = 0
    @State private var statsOpacity: Double = 0
    @State private var listOpacity: Double = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    if accuracy >= 0.8 {
                        ConfettiView()
                    }

                    Image(systemName: resultIcon)
                        .font(.system(size: 60))
                        .foregroundStyle(resultColor)
                        .scaleEffect(iconScale)

                    Text(viewModel.correctCount == viewModel.questions.count
                         ? "Alle Fehler korrigiert!"
                         : "Fehler üben beendet!")
                        .font(AppFonts.title)
                        .opacity(titleOpacity)

                    Text(resultMessage)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(titleOpacity)
                }

                HStack(spacing: 20) {
                    statBox(value: "\(viewModel.correctCount)/\(viewModel.questions.count)", label: "Richtig")
                    statBox(value: "\(viewModel.totalStars)", label: "Sterne", icon: "star.fill", iconColor: AppColors.starFilled)
                }
                .opacity(statsOpacity)

                // Results
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ergebnisse")
                        .font(AppFonts.headline)

                    ForEach(viewModel.results) { result in
                        HStack {
                            Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(result.isCorrect ? AppColors.success : AppColors.error)

                            VStack(alignment: .leading) {
                                Text(result.questionText)
                                    .font(AppFonts.subheadline)
                                if !result.isCorrect {
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
        if accuracy >= 1.0 { return "trophy.fill" }
        if accuracy >= 0.5 { return "hand.thumbsup.fill" }
        return "arrow.counterclockwise"
    }

    private var resultColor: Color {
        if accuracy >= 1.0 { return AppColors.starFilled }
        if accuracy >= 0.5 { return AppColors.primary }
        return AppColors.textSecondary
    }

    private var resultMessage: String {
        if accuracy >= 1.0 { return "Super! Du hast alle Fehler korrigiert!" }
        if accuracy >= 0.5 { return "Gut! Übe die restlichen Fehler nochmal." }
        return "Weiter üben - du schaffst das!"
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
