import SwiftUI
import SwiftData

struct ProgressOverviewView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \QuizSession.startedAt, order: .reverse) private var sessions: [QuizSession]
    @Query(sort: \DailyProgress.date, order: .reverse) private var dailyProgress: [DailyProgress]
    @Query private var achievements: [Achievement]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview stats
                    overviewStats

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
        }
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
        (0..<7).map { offset in
            Calendar.current.date(byAdding: .day, value: -6 + offset, to: Calendar.current.startOfDay(for: Date()))!
        }
    }

    private func dayAbbreviation(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_CH")
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(2))
    }
}
