import SwiftUI

struct AppButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void

    enum ButtonStyle {
        case primary
        case secondary
        case outline
        case destructive
    }

    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button {
            HapticService.shared.tap()
            SoundService.shared.playTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(AppFonts.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(backgroundColor)
                }
            }
            .foregroundStyle(foregroundColor)
            .overlay {
                if style == .outline {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(AppColors.primary, lineWidth: 2)
                } else if style == .secondary {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
                }
            }
            .shadow(color: style == .primary || style == .destructive
                    ? backgroundColor.opacity(0.35)
                    : .black.opacity(0.05),
                    radius: 10, x: 0, y: 4)
        }
        .buttonStyle(BounceButtonStyle())
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return AppColors.primary
        case .secondary: return AppColors.secondaryBackground
        case .outline: return .clear
        case .destructive: return AppColors.error
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return AppColors.textPrimary
        case .outline: return AppColors.primary
        case .destructive: return .white
        }
    }
}

struct BounceButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
