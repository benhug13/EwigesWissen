import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var showTest = false
    @State private var showDuel = false
    @State private var streakScale: CGFloat = 1.0
    @State private var flameAnimation = false

    private var user: User? { appState.currentUser }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome header
                    welcomeHeader

                    // Level picker
                    levelPicker

                    // Stats row
                    if let user {
                        statsRow(user: user)
                    }

                    // Quick actions
                    quickActions

                    // Recent achievements
                    if let user, !user.achievements.isEmpty {
                        recentAchievements(user: user)
                    }

                    // Daily challenge
                    dailyChallengeCard
                }
                .padding()
            }
            .navigationTitle("EwigesWissen")
        }
    }

    // MARK: - Daily Challenge

    private var dailyChallengeCard: some View {
        let challenge = DailyChallengeService(modelContext: modelContext).todayChallenge(for: user)
        return AppCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: challenge.icon)
                        .font(.title3)
                        .foregroundStyle(challenge.isCompleted ? AppColors.success : AppColors.accent)
                    Text("Tägliche Challenge")
                        .font(AppFonts.headline)
                    Spacer()
                    if challenge.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.success)
                    }
                }
                Text(challenge.description)
                    .font(AppFonts.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                ProgressBarView(
                    progress: challenge.progress,
                    color: challenge.isCompleted ? AppColors.success : AppColors.accent
                )
                Text("\(challenge.current)/\(challenge.target)")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    // MARK: - Welcome

    private var welcomeHeader: some View {
        AppCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Willkommen!")
                        .font(AppFonts.title2)

                    if let user {
                        if user.currentStreak > 0 {
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                                    .scaleEffect(streakScale)
                                    .symbolEffect(.bounce, value: flameAnimation)
                                Text("\(user.currentStreak)")
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                    .foregroundStyle(.orange)
                                    .contentTransition(.numericText())
                                Text(user.currentStreak == 1 ? "Tag Streak" : "Tage Streak")
                                    .font(AppFonts.subheadline)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "flame")
                                    .font(.title3)
                                    .foregroundStyle(AppColors.textTertiary)
                                Text("Starte deine Streak!")
                                    .font(AppFonts.subheadline)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                    }
                }
                Spacer()
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppColors.primary)
            }
        }
        .onAppear {
            if let user, user.currentStreak > 0 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.4).delay(0.3)) {
                    streakScale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        streakScale = 1.0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    flameAnimation.toggle()
                }
            }
        }
    }

    private var levelPicker: some View {
        @Bindable var state = appState
        return AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Schulstufe")
                    .font(AppFonts.headline)

                Picker("Schulstufe", selection: $state.schoolLevel) {
                    ForEach(SchoolLevel.allCases) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private func statsRow(user: User) -> some View {
        HStack(spacing: 12) {
            statCard(
                icon: "star.fill",
                color: AppColors.starFilled,
                value: "\(user.totalStars)",
                label: "Sterne"
            )
            statCard(
                icon: "checkmark.circle.fill",
                color: AppColors.success,
                value: "\(user.quizSessions.count)",
                label: "Quizzes"
            )
            statCard(
                icon: "flame.fill",
                color: .orange,
                value: "\(user.longestStreak)",
                label: "Bester Streak"
            )
        }
    }

    private func statCard(icon: String, color: Color, value: String, label: String) -> some View {
        AppCard {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Text(value)
                    .font(AppFonts.title3)
                Text(label)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Schnellstart")
                .font(AppFonts.headline)

            HStack(spacing: 12) {
                quickActionButton(
                    title: "Hauptstädte",
                    icon: "building.columns.fill",
                    color: AppColors.primary
                ) {
                    appState.selectedTab = .capitals
                }

                quickActionButton(
                    title: "Geografie",
                    icon: "globe.europe.africa.fill",
                    color: AppColors.secondary
                ) {
                    appState.selectedTab = .geography
                }
            }

            HStack(spacing: 12) {
                quickActionButton(
                    title: "Probeprüfung",
                    icon: "doc.text.fill",
                    color: AppColors.accent
                ) {
                    showTest = true
                }

                quickActionButton(
                    title: "Duell",
                    icon: "person.2.fill",
                    color: .orange
                ) {
                    showDuel = true
                }
            }
            .fullScreenCover(isPresented: $showTest) {
                TestQuizView(schoolLevel: appState.schoolLevel)
                    .environment(appState)
            }
            .fullScreenCover(isPresented: $showDuel) {
                DuelView(schoolLevel: appState.schoolLevel)
            }
        }
    }

    private func quickActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            AppCard {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                    Text(title)
                        .font(AppFonts.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func recentAchievements(user: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(AppFonts.headline)

            ForEach(user.achievements.suffix(3)) { achievement in
                HStack(spacing: 12) {
                    Image(systemName: achievement.type.iconName)
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 36)

                    VStack(alignment: .leading) {
                        Text(achievement.type.displayName)
                            .font(AppFonts.subheadline)
                        Text(achievement.type.description)
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()

                    if achievement.isNew {
                        Text("NEU")
                            .font(AppFonts.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppColors.accent)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

}
