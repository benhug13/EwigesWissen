import SwiftUI
import SwiftData

struct ProgressOverviewView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuizSession.startedAt, order: .reverse) private var sessions: [QuizSession]
    @Query(sort: \DailyProgress.date, order: .reverse) private var dailyProgress: [DailyProgress]
    @Query private var achievements: [Achievement]
    @State private var showMistakes = false
    @State private var showBookmarks = false
    @State private var wrongCapitals: [Capital] = []
    @State private var wrongGeoItems: [GeographyItem] = []
    @State private var bookmarkCapitals: [Capital] = []
    @State private var bookmarkGeoItems: [GeographyItem] = []
    @State private var wrongCount = 0
    @State private var bookmarkCount = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview stats
                    overviewStats

                    // Fehler üben
                    if wrongCount > 0 {
                        mistakesButton
                    }

                    // Favoriten üben
                    if bookmarkCount > 0 {
                        bookmarksButton
                    }

                    // Item progress detail
                    NavigationLink {
                        ItemProgressView()
                            .environment(appState)
                    } label: {
                        AppCard {
                            HStack {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.title2)
                                    .foregroundStyle(AppColors.primary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Lernfortschritt")
                                        .font(AppFonts.headline)
                                    Text("Alle Items im Überblick")
                                        .font(AppFonts.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(AppColors.textTertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    // Weekly chart
                    weeklyChart

                    // Achievements
                    achievementsSection

                    // Recent sessions
                    recentSessions
                }
                .padding()
            }
            .navigationTitle("Fortschritt")
            .onAppear {
                refreshCounts()
            }
            .onChange(of: appState.schoolLevel) { _, _ in
                refreshCounts()
            }
        }
    }

    // MARK: - Mistakes

    private var mistakesButton: some View {
        Button {
            let progress = ProgressService(modelContext: modelContext)
            wrongCapitals = progress.wrongCapitals(for: appState.schoolLevel)
            wrongGeoItems = progress.wrongGeographyItems(for: appState.schoolLevel)
            showMistakes = true
        } label: {
            AppCard {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundStyle(AppColors.warning)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Fehler üben")
                            .font(AppFonts.headline)
                        Text("\(wrongCount) Fragen zum Wiederholen")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    Text("\(wrongCount)")
                        .font(AppFonts.title3)
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(AppColors.warning)
                        .clipShape(Circle())
                }
            }
        }
        .buttonStyle(BounceButtonStyle())
        .fullScreenCover(isPresented: $showMistakes, onDismiss: {
            refreshCounts()
        }) {
            MistakeQuizView(
                schoolLevel: appState.schoolLevel,
                wrongCapitals: wrongCapitals,
                wrongGeoItems: wrongGeoItems
            )
            .environment(appState)
        }
    }

    private var bookmarksButton: some View {
        Button {
            let progress = ProgressService(modelContext: modelContext)
            bookmarkCapitals = progress.bookmarkedCapitals(for: appState.schoolLevel)
            bookmarkGeoItems = progress.bookmarkedGeographyItems(for: appState.schoolLevel)
            showBookmarks = true
        } label: {
            AppCard {
                HStack {
                    Image(systemName: "bookmark.fill")
                        .font(.title2)
                        .foregroundStyle(AppColors.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Favoriten üben")
                            .font(AppFonts.headline)
                        Text("\(bookmarkCount) markierte Fragen")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                    Text("\(bookmarkCount)")
                        .font(AppFonts.title3)
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(AppColors.accent)
                        .clipShape(Circle())
                }
            }
        }
        .buttonStyle(BounceButtonStyle())
        .fullScreenCover(isPresented: $showBookmarks, onDismiss: {
            refreshCounts()
        }) {
            MistakeQuizView(
                schoolLevel: appState.schoolLevel,
                wrongCapitals: bookmarkCapitals,
                wrongGeoItems: bookmarkGeoItems
            )
            .environment(appState)
        }
    }

    private func refreshCounts() {
        let progress = ProgressService(modelContext: modelContext)
        wrongCount = progress.wrongItemCount(for: appState.schoolLevel)
        bookmarkCount = progress.bookmarkedCount(for: appState.schoolLevel)
    }

    private var overviewStats: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                statCard(
                    value: "\(sessions.count)",
                    label: "Quizzes",
                    icon: "checkmark.circle.fill",
                    color: AppColors.primary
                )
                statCard(
                    value: "\(totalCorrect)",
                    label: "Richtig",
                    icon: "target",
                    color: AppColors.success
                )
            }
            HStack(spacing: 12) {
                statCard(
                    value: "\(totalStars)",
                    label: "Sterne",
                    icon: "star.fill",
                    color: AppColors.starFilled
                )
                statCard(
                    value: "\(Int(overallAccuracy * 100))%",
                    label: "Genauigkeit",
                    icon: "percent",
                    color: AppColors.accent
                )
            }
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        AppCard {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                VStack(alignment: .leading) {
                    Text(value)
                        .font(AppFonts.title3)
                    Text(label)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
            }
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Diese Woche")
                .font(AppFonts.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(last7Days, id: \.self) { date in
                    let progress = dailyProgress.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.primary)
                            .frame(width: 30, height: max(4, CGFloat(progress?.quizzesCompleted ?? 0) * 20))
                            .frame(maxHeight: 100, alignment: .bottom)

                        Text(dayAbbreviation(date))
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(AppColors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(AppFonts.headline)
                Spacer()
                Text("\(achievements.count)/\(AchievementType.allCases.count)")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            ProgressBarView(
                progress: Double(achievements.count) / Double(AchievementType.allCases.count)
            )

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                ForEach(AchievementType.allCases, id: \.rawValue) { type in
                    let unlocked = achievements.contains { $0.typeRawValue == type.rawValue }
                    VStack(spacing: 4) {
                        Image(systemName: type.iconName)
                            .font(.title2)
                            .foregroundStyle(unlocked ? AppColors.primary : AppColors.textTertiary)
                        Text(type.displayName)
                            .font(.system(size: 9, design: .rounded))
                            .foregroundStyle(unlocked ? AppColors.textPrimary : AppColors.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 70, height: 70)
                    .opacity(unlocked ? 1 : 0.4)
                }
            }
        }
    }

    private var recentSessions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Letzte Quizzes")
                .font(AppFonts.headline)

            if sessions.isEmpty {
                Text("Noch keine Quizzes absolviert")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(sessions.prefix(5)) { session in
                    HStack {
                        Image(systemName: session.type == .geographyPinPlacement ? "globe.europe.africa.fill" : "building.columns.fill")
                            .foregroundStyle(AppColors.primary)

                        VStack(alignment: .leading) {
                            Text(session.quizType)
                                .font(AppFonts.subheadline)
                            Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(AppFonts.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        Spacer()

                        Text("\(session.correctAnswers)/\(session.totalQuestions)")
                            .font(AppFonts.headline)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Computed

    private var totalCorrect: Int {
        sessions.reduce(0) { $0 + $1.correctAnswers }
    }

    private var totalStars: Int {
        sessions.reduce(0) { $0 + $1.totalStarsEarned }
    }

    private var overallAccuracy: Double {
        let total = sessions.reduce(0) { $0 + $1.totalQuestions }
        guard total > 0 else { return 0 }
        return Double(totalCorrect) / Double(total)
    }

    private var last7Days: [Date] {
        let today = Calendar.current.startOfDay(for: Date())
        return (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -6 + offset, to: today)
        }
    }

    private func dayAbbreviation(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_CH")
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(2))
    }
}
