import SwiftUI

struct ComboExplosionView: View {
    let onDismiss: () -> Void

    @State private var particles: [ExplosionParticle] = []
    @State private var animating = false
    @State private var textScale: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.2
    @State private var ringOpacity: Double = 1
    @State private var ring2Scale: CGFloat = 0.2
    @State private var ring2Opacity: Double = 1
    @State private var backgroundFlash: Double = 0
    @State private var shakeOffset: CGFloat = 0

    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple,
        .pink, .cyan, .mint, .indigo,
        Color(red: 1, green: 0.8, blue: 0),
        Color(red: 1, green: 0.4, blue: 0)
    ]
    private let shapes = ["circle.fill", "star.fill", "heart.fill", "sparkle", "flame.fill"]

    var body: some View {
        ZStack {
            // Flash
            Color.white.opacity(backgroundFlash)
                .ignoresSafeArea()

            // Particles
            ForEach(particles) { p in
                Image(systemName: p.shape)
                    .font(.system(size: p.size))
                    .foregroundStyle(p.color)
                    .offset(
                        x: animating ? p.endX : 0,
                        y: animating ? p.endY : 0
                    )
                    .opacity(animating ? 0 : 1)
                    .rotationEffect(.degrees(animating ? p.rotation : 0))
                    .scaleEffect(animating ? 0.1 : 1.2)
            }

            // Rings
            Circle()
                .stroke(
                    LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom),
                    lineWidth: 4
                )
                .frame(width: 150, height: 150)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            Circle()
                .stroke(
                    LinearGradient(colors: [.cyan, .blue, .purple], startPoint: .top, endPoint: .bottom),
                    lineWidth: 3
                )
                .frame(width: 120, height: 120)
                .scaleEffect(ring2Scale)
                .opacity(ring2Opacity)

            // Text
            VStack(spacing: 4) {
                Text("10x")
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.6), radius: 15)
                Text("COMBO!")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 8)
            }
            .scaleEffect(textScale)
            .opacity(textOpacity)
            .offset(x: shakeOffset)
        }
        .allowsHitTesting(false)
        .onAppear {
            startExplosion()
        }
    }

    private func startExplosion() {
        // Generate lots of particles
        particles = (0..<80).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 150...400)
            return ExplosionParticle(
                color: colors.randomElement()!,
                size: CGFloat.random(in: 8...22),
                shape: shapes.randomElement()!,
                endX: cos(angle) * distance,
                endY: sin(angle) * distance,
                rotation: Double.random(in: -720...720)
            )
        }

        // White flash
        withAnimation(.easeIn(duration: 0.1)) {
            backgroundFlash = 0.8
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
            backgroundFlash = 0
        }

        // Screen shake
        shakeScreen()

        // Text
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4).delay(0.1)) {
            textScale = 1
            textOpacity = 1
        }

        // Rings
        withAnimation(.easeOut(duration: 0.8)) {
            ringScale = 3.0
            ringOpacity = 0
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
            ring2Scale = 2.5
            ring2Opacity = 0
        }

        // Particles
        withAnimation(.easeOut(duration: 1.5)) {
            animating = true
        }

        // Sound + haptic
        SoundService.shared.playSuccess()
        HapticService.shared.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            HapticService.shared.heavyImpact()
        }

        // Dismiss after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                textOpacity = 0
                textScale = 0.5
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            onDismiss()
        }
    }

    private func shakeScreen() {
        let steps: [(CGFloat, Double)] = [
            (12, 0.05), (-12, 0.1), (10, 0.15), (-10, 0.2),
            (6, 0.25), (-6, 0.3), (0, 0.4)
        ]
        for (offset, delay) in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: 0.05)) {
                    shakeOffset = offset
                }
            }
        }
    }
}

struct ExplosionParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let shape: String
    let endX: CGFloat
    let endY: CGFloat
    let rotation: Double
}
