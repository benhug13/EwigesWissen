import SwiftUI

struct StreakCelebrationView: View {
    let streakCount: Int
    let onDismiss: () -> Void

    @State private var flameScale: CGFloat = 0
    @State private var flameOpacity: Double = 0
    @State private var numberScale: CGFloat = 0
    @State private var numberOpacity: Double = 0
    @State private var labelOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0
    @State private var ring2Scale: CGFloat = 0.3
    @State private var ring2Opacity: Double = 0
    @State private var backgroundOpacity: Double = 0
    @State private var particles: [FireParticle] = []
    @State private var particlesAnimating = false
    @State private var buttonOpacity: Double = 0
    @State private var flameGlow: Double = 0
    @State private var flamePulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Dark background
            Color.black.opacity(backgroundOpacity * 0.85)
                .ignoresSafeArea()
                .onTapGesture { dismissWithAnimation() }

            VStack(spacing: 24) {
                Spacer()

                // Fire particles
                ZStack {
                    ForEach(particles) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .blur(radius: particle.size * 0.3)
                            .offset(
                                x: particlesAnimating ? particle.endX : particle.startX,
                                y: particlesAnimating ? particle.endY : particle.startY
                            )
                            .opacity(particlesAnimating ? 0 : particle.opacity)
                            .scaleEffect(particlesAnimating ? 0.1 : 1)
                    }

                    // Expanding rings
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.orange, .red, .orange.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.yellow, .orange, .yellow.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(ring2Scale)
                        .opacity(ring2Opacity)

                    // Flame glow
                    Image(systemName: "flame.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.orange)
                        .blur(radius: 20)
                        .opacity(flameGlow)
                        .scaleEffect(flameScale * 1.3)

                    // Main flame
                    Image(systemName: "flame.fill")
                        .font(.system(size: 90))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(flameScale * flamePulse)
                        .opacity(flameOpacity)
                        .shadow(color: .orange.opacity(0.8), radius: 30)
                        .shadow(color: .red.opacity(0.4), radius: 50)
                }

                // Streak number
                VStack(spacing: 8) {
                    Text("\(streakCount)")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .orange.opacity(0.5), radius: 10)
                        .scaleEffect(numberScale)
                        .opacity(numberOpacity)

                    Text(streakCount == 1 ? "Tag Streak!" : "Tage Streak!")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .opacity(labelOpacity)

                    Text(motivationText)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .opacity(labelOpacity)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Dismiss button
                Button {
                    dismissWithAnimation()
                } label: {
                    Text("Weiter so!")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 48)
                        .background(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .orange.opacity(0.5), radius: 10)
                }
                .opacity(buttonOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private var motivationText: String {
        switch streakCount {
        case 1: return "Du hast angefangen! Mach morgen weiter!"
        case 2: return "Zwei Tage am Stück – weiter so!"
        case 3...4: return "Du baust dir eine Gewohnheit auf!"
        case 5...6: return "Fast eine Woche – stark!"
        case 7: return "Eine ganze Woche! Unglaublich!"
        case 8...13: return "Du bist auf Feuer! 🔥"
        case 14: return "Zwei Wochen! Nicht zu stoppen!"
        case 15...29: return "Du bist eine Lernmaschine!"
        case 30: return "Ein ganzer Monat! Legende!"
        default: return "Absolut unaufhaltbar!"
        }
    }

    private func startAnimations() {
        // Generate fire particles
        particles = (0..<30).map { _ in
            FireParticle(
                color: [.yellow, .orange, .red, Color(red: 1, green: 0.6, blue: 0)].randomElement()!,
                size: CGFloat.random(in: 6...20),
                opacity: Double.random(in: 0.5...1.0),
                startX: CGFloat.random(in: -20...20),
                startY: CGFloat.random(in: -10...10),
                endX: CGFloat.random(in: -180...180),
                endY: CGFloat.random(in: -350...(-100))
            )
        }

        // Background
        withAnimation(.easeIn(duration: 0.3)) {
            backgroundOpacity = 1
        }

        // Flame entrance
        withAnimation(.spring(response: 0.5, dampingFraction: 0.4)) {
            flameScale = 1
            flameOpacity = 1
        }

        // Glow
        withAnimation(.easeIn(duration: 0.4).delay(0.2)) {
            flameGlow = 0.6
        }

        // Rings
        withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
            ringScale = 2.5
            ringOpacity = 0
        }
        // Start ring visible
        withAnimation(.easeIn(duration: 0.1).delay(0.2)) {
            ringOpacity = 0.8
        }

        withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
            ring2Scale = 2.0
            ring2Opacity = 0
        }
        withAnimation(.easeIn(duration: 0.1).delay(0.4)) {
            ring2Opacity = 0.6
        }

        // Particles
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            particlesAnimating = true
        }

        // Number
        withAnimation(.spring(response: 0.5, dampingFraction: 0.4).delay(0.4)) {
            numberScale = 1
            numberOpacity = 1
        }

        // Label
        withAnimation(.easeOut(duration: 0.4).delay(0.7)) {
            labelOpacity = 1
        }

        // Button
        withAnimation(.easeOut(duration: 0.4).delay(1.0)) {
            buttonOpacity = 1
        }

        // Flame pulse loop
        startFlamePulse()

        // Sound
        SoundService.shared.playSuccess()
        HapticService.shared.success()
    }

    private func startFlamePulse() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            flamePulse = 1.08
        }
    }

    private func dismissWithAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundOpacity = 0
            flameScale = 0.5
            flameOpacity = 0
            numberOpacity = 0
            labelOpacity = 0
            buttonOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

struct FireParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let opacity: Double
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
}
