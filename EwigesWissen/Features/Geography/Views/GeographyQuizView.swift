import SwiftUI
import SwiftData
import MapKit

struct GeographyQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var viewModel = GeographyQuizViewModel()
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.0, longitude: 10.0),
            span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 160)
        )
    )
    @State private var questionId = UUID()
    @State private var pinScale: CGFloat = 0
    @AppStorage("sessionLength") private var sessionLength = 10
    @AppStorage("mapStyle") private var mapStyleSetting = "Apple Karten"

    let schoolLevel: SchoolLevel
    var filterType: GeographyType? = nil
    var filterTypes: [GeographyType]? = nil

    private var selectedMapStyle: MapStyle {
        MapStyle(rawValue: mapStyleSetting) ?? .apple
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isCompleted {
                    GeographyResultView(viewModel: viewModel) {
                        saveAndDismiss()
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    quizContent
                }
            }
            .navigationTitle("Geografie-Quiz")
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
            viewModel.startQuiz(level: schoolLevel, questionCount: sessionLength, type: filterType, types: filterTypes)
        }
    }

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

            // Question
            if let question = viewModel.currentQuestion {
                HStack {
                    Image(systemName: question.type.iconName)
                        .foregroundStyle(AppColors.geographyColor(for: question.type))
                        .symbolEffect(.bounce, value: questionId)
                    Text("Wo liegt \(question.name)?")
                        .font(AppFonts.headline)
                }
                .padding(.vertical, 8)
                .id(questionId)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }

            // Map
            if selectedMapStyle == .stummeKarte {
                stummeKarteQuiz
            } else {
                appleMapQuiz
            }

            // Bottom bar
            bottomBar
                .padding()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: questionId)
    }

    // MARK: - Apple Maps Quiz

    private var appleMapQuiz: some View {
        MapReader { proxy in
            Map(position: $cameraPosition) {
                // Placed pin
                if let pin = viewModel.placedPin {
                    Annotation("Deine Antwort", coordinate: pin) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(viewModel.showResult
                                ? (viewModel.isCorrect ? AppColors.success : AppColors.error)
                                : AppColors.primary)
                            .scaleEffect(pinScale)
                    }
                }

                // Show correct location after answer
                if viewModel.showResult, let question = viewModel.currentQuestion {
                    Annotation("Richtig", coordinate: question.coordinate) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(AppColors.success)
                    }

                    // Tolerance circle
                    MapCircle(center: question.coordinate, radius: question.toleranceRadiusKm * 1000)
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
                    animatePinDrop()
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
            resultAnnotation: viewModel.showResult && viewModel.currentQuestion != nil
                ? StummeKarteResultAnnotation(
                    coordinate: viewModel.currentQuestion!.coordinate,
                    isCorrect: viewModel.isCorrect,
                    toleranceRadiusKm: viewModel.currentQuestion!.toleranceRadiusKm
                )
                : nil
        )
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
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
                        pinScale = 0
                    }
                }
            } else {
                AppButton("Bestätigen", icon: "checkmark") {
                    if let question = viewModel.currentQuestion {
                        viewModel.confirmAnswer()
                        let progress = ProgressService(modelContext: modelContext)
                        progress.recordAnswer(itemId: question.id, itemType: "geography", correct: viewModel.isCorrect)
                    }
                    if viewModel.isCorrect {
                        SoundService.shared.playCorrect()
                        HapticService.shared.success()
                    } else {
                        SoundService.shared.playIncorrect()
                        HapticService.shared.error()
                    }
                }
                .disabled(viewModel.placedPin == nil)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.showResult)
    }

    private func animatePinDrop() {
        pinScale = 0
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            pinScale = 1.0
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
