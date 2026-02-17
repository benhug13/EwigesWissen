import SwiftUI

enum QuizDirection: String, CaseIterable, Identifiable {
    case countryToCapital = "L → H"
    case capitalToCountry = "H → L"
    case mixed = "Gemischt"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .countryToCapital: return "Land → Hauptstadt"
        case .capitalToCountry: return "Hauptstadt → Land"
        case .mixed: return "Gemischt"
        }
    }
}

struct CapitalsLearningView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = CapitalsLearningViewModel()
    @State private var showQuizMode = false // picker: Lernen vs Quiz-Setup
    @State private var showQuizCover = false // fullScreenCover trigger
    @State private var quizDirection: QuizDirection = .countryToCapital
    @State private var quizMC: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Mode picker
                Picker("Modus", selection: $showQuizMode) {
                    Text("Lernen").tag(false)
                    Text("Quiz").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if showQuizMode {
                    quizSetupView
                } else {
                    flashcardView
                }
            }
            .navigationTitle("Hauptstädte")
            .onAppear {
                viewModel.loadCapitals(for: appState.schoolLevel)
            }
            .onChange(of: appState.schoolLevel) { _, newValue in
                viewModel.loadCapitals(for: newValue)
            }
            .fullScreenCover(isPresented: $showQuizCover) {
                CapitalsQuizView(
                    schoolLevel: appState.schoolLevel,
                    direction: quizDirection,
                    isMultipleChoice: quizMC
                )
            }
        }
    }

    // MARK: - Flashcard View

    @ViewBuilder
    private var flashcardView: some View {
        if let capital = viewModel.currentCapital {
            VStack(spacing: 16) {
                ProgressBarView(progress: viewModel.progress)
                    .padding(.horizontal)

                Text(viewModel.progressText)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                // Flashcard
                flashcard(for: capital)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            viewModel.flip()
                        }
                    }

                Text("Tippe zum Umdrehen")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textTertiary)

                Spacer()

                // Navigation buttons
                HStack(spacing: 16) {
                    Button {
                        viewModel.previous()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                    }
                    .disabled(!viewModel.hasPrevious)

                    Button {
                        viewModel.shuffle()
                    } label: {
                        Image(systemName: "shuffle")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                    }

                    Button {
                        viewModel.next()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                    }
                    .disabled(!viewModel.hasNext)
                }
                .tint(AppColors.primary)
                .padding(.bottom)
            }
        } else {
            ContentUnavailableView(
                "Keine Hauptstädte",
                systemImage: "building.columns",
                description: Text("Keine Daten verfügbar")
            )
        }
    }

    private func flashcard(for capital: Capital) -> some View {
        ZStack {
            // Back (answer)
            AppCard {
                VStack(spacing: 12) {
                    Text("Hauptstadt")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(capital.capital)
                        .font(AppFonts.quizAnswer)
                        .foregroundStyle(AppColors.primary)
                    Divider()
                    Text(capital.country)
                        .font(AppFonts.headline)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            }
            .rotation3DEffect(
                .degrees(viewModel.isFlipped ? 0 : -90),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(viewModel.isFlipped ? 1 : 0)

            // Front (question)
            AppCard {
                VStack(spacing: 12) {
                    Text("Land")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(capital.country)
                        .font(AppFonts.quizQuestion)
                    Text("🏳️")
                        .font(.system(size: 40))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            }
            .rotation3DEffect(
                .degrees(viewModel.isFlipped ? 90 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(viewModel.isFlipped ? 0 : 1)
        }
        .padding(.horizontal)
    }

    // MARK: - Quiz Setup

    private var quizSetupView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "building.columns.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.primary)

            Text("Hauptstädte-Quiz")
                .font(AppFonts.title)

            VStack(spacing: 12) {
                Text("Richtung wählen:")
                    .font(AppFonts.headline)

                Picker("Richtung", selection: $quizDirection) {
                    ForEach(QuizDirection.allCases) { dir in
                        Text(dir.rawValue).tag(dir)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Text(quizDirection.displayName)
                    .font(AppFonts.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }

            VStack(spacing: 12) {
                Text("Antwortmodus:")
                    .font(AppFonts.headline)

                Picker("Modus", selection: $quizMC) {
                    Text("Texteingabe").tag(false)
                    Text("Multiple Choice").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }

            AppButton("Quiz starten", icon: "play.fill") {
                showQuizCover = true
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }
}
