import SwiftUI

/// Compact success indicator for side-by-side results (e.g. Duel mode)
struct MiniSuccessView: View {
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.success.opacity(0.2))
                .frame(width: 50, height: 50)
                .scaleEffect(scale * 1.2)

            Circle()
                .fill(AppColors.success)
                .frame(width: 36, height: 36)
                .scaleEffect(scale)
                .shadow(color: AppColors.success.opacity(0.3), radius: 6)

            Image(systemName: "checkmark")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .opacity(opacity)
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
                scale = 1
            }
            withAnimation(.easeIn(duration: 0.15).delay(0.15)) {
                opacity = 1
            }
        }
    }
}

/// Compact wrong indicator for side-by-side results (e.g. Duel mode)
struct MiniWrongView: View {
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var shakeX: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.error.opacity(0.15))
                .frame(width: 50, height: 50)
                .scaleEffect(scale * 1.2)

            Circle()
                .fill(AppColors.error)
                .frame(width: 36, height: 36)
                .scaleEffect(scale)
                .shadow(color: AppColors.error.opacity(0.3), radius: 6)

            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .opacity(opacity)
                .scaleEffect(scale)
        }
        .offset(x: shakeX)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
                scale = 1
            }
            withAnimation(.easeIn(duration: 0.15).delay(0.15)) {
                opacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.08, dampingFraction: 0.2)) { shakeX = 8 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
                withAnimation(.spring(response: 0.08, dampingFraction: 0.2)) { shakeX = -8 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.46) {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) { shakeX = 0 }
            }
        }
    }
}
