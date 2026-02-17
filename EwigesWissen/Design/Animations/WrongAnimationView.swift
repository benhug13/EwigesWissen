import SwiftUI

struct WrongAnimationView: View {
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var shakeX: CGFloat = 0

    var body: some View {
        ZStack {
            // Background pulse
            Circle()
                .fill(AppColors.error.opacity(0.15))
                .frame(width: 100, height: 100)
                .scaleEffect(scale * 1.3)

            // Main circle
            Circle()
                .fill(AppColors.error)
                .frame(width: 70, height: 70)
                .scaleEffect(scale)
                .shadow(color: AppColors.error.opacity(0.3), radius: 10)

            // X mark
            Image(systemName: "xmark")
                .font(.system(size: 34, weight: .bold))
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
            // Shake
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.08, dampingFraction: 0.2)) { shakeX = 15 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
                withAnimation(.spring(response: 0.08, dampingFraction: 0.2)) { shakeX = -15 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.46) {
                withAnimation(.spring(response: 0.08, dampingFraction: 0.2)) { shakeX = 10 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.54) {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) { shakeX = 0 }
            }
        }
    }
}
