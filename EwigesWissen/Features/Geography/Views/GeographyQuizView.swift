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
            center: CLLocationCoordinate2D(latitude: 48.0, longitude: 14.0),
            span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 40)
        )
    )

    let schoolLevel: SchoolLevel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isCompleted {
                    GeographyResultView(viewModel: viewModel) {
                        saveAndDismiss()
                    }
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
            let prefs = fetchPreferences()
            viewModel.startQuiz(level: schoolLevel, questionCount: prefs?.sessionLength ?? 10)
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
                    Text("Wo liegt \(question.name)?")
                        .font(AppFonts.headline)
                }
                .padding(.vertical, 8)
            }

            // Map with tap
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
                .mapStyle(.standard(elevation: .realistic))
                .onTapGesture { position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        viewModel.placePin(at: coordinate)
                    }
                }
            }

            // Bottom bar
            bottomBar
                .padding()
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 8) {
            if viewModel.showResult {
                HStack {
                    Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(viewModel.isCorrect ? AppColors.success : AppColors.error)
                    Text(viewModel.isCorrect ? "Richtig!" : "Leider falsch")
                        .font(AppFonts.headline)
                    Spacer()
                    Text(String(format: "%.0f km Abstand", viewModel.distanceKm))
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                AppButton("Weiter", icon: "arrow.right") {
                    viewModel.nextQuestion()
                }
            } else {
                AppButton("Bestätigen", icon: "checkmark") {
                    viewModel.confirmAnswer()
                }
                .disabled(viewModel.placedPin == nil)
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
