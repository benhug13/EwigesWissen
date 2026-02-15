import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    private var user: User? { users.first }

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
                }
                .padding()
            }
            .navigationTitle("EwigesWissen")
            .onAppear {
                ensureUser()
            }
        }
    }

    private var welcomeHeader: some View {
        AppCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Willkommen!")
                        .font(AppFonts.title2)

                    if let user {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                            Text("\(user.currentStreak) Tage Streak")
                                .font(AppFonts.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
                Spacer()
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppColors.primary)
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

    private func ensureUser() {
        if users.isEmpty {
            let newUser = User()
            newUser.preferences = UserPreferences()
            modelContext.insert(newUser)
            try? modelContext.save()
            appState.currentUser = newUser
        } else {
            appState.currentUser = users.first
            if let user = users.first {
                appState.schoolLevel = user.level
            }
        }
    }
}
