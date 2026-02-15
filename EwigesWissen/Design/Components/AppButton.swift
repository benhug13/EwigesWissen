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
        Button(action: action) {
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
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                if style == .outline {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppColors.primary, lineWidth: 2)
                }
            }
        }
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
