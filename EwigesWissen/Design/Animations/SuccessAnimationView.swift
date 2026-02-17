import SwiftUI

struct SuccessAnimationView: View {
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 1
    @State private var sparkles: [SparkleParticle] = []
    @State private var sparkleAnimating = false

    var body: some View {
        ZStack {
            // Expanding ring
            Circle()
                .stroke(AppColors.success.opacity(0.4), lineWidth: 3)
                .frame(width: 120, height: 120)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            // Sparkle particles
            ForEach(sparkles) { sparkle in
                Image(systemName: "sparkle")
                    .font(.system(size: sparkle.size))
                    .foregroundStyle(sparkle.color)
                    .offset(
                        x: sparkleAnimating ? sparkle.endX : 0,
                        y: sparkleAnimating ? sparkle.endY : 0
                    )
                    .opacity(sparkleAnimating ? 0 : 1)
                    .scaleEffect(sparkleAnimating ? 0.3 : 1)
            }

            // Background circle
            Circle()
                .fill(AppColors.success.opacity(0.2))
                .frame(width: 100, height: 100)
                .scaleEffect(scale)

            // Main circle
            Circle()
                .fill(AppColors.success)
                .frame(width: 70, height: 70)
                .scaleEffect(scale)
                .shadow(color: AppColors.success.opacity(0.4), radius: 12)

            // Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .opacity(opacity)
                .scaleEffect(scale)
        }
        .onAppear {
            // Sparkles
            sparkles = (0..<8).map { _ in
                SparkleParticle(
                    size: CGFloat.random(in: 8...16),
                    color: [AppColors.success, .yellow, .green, .cyan].randomElement()!,
                    endX: CGFloat.random(in: -80...80),
                    endY: CGFloat.random(in: -80...80)
                )
            }

            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                scale = 1
            }
            withAnimation(.easeIn(duration: 0.2).delay(0.2)) {
                opacity = 1
            }
            withAnimation(.easeOut(duration: 0.8)) {
                ringScale = 2.0
                ringOpacity = 0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                sparkleAnimating = true
            }
        }
    }
}

struct SparkleParticle: Identifiable {
    let id = UUID()
    let size: CGFloat
    let color: Color
    let endX: CGFloat
    let endY: CGFloat
}
