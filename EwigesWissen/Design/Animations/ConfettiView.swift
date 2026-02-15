import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false

    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .cyan, .pink]

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(
                        x: isAnimating ? particle.endX : particle.startX,
                        y: isAnimating ? particle.endY : particle.startY
                    )
                    .opacity(isAnimating ? 0 : 1)
                    .rotationEffect(.degrees(isAnimating ? particle.rotation : 0))
            }
        }
        .onAppear {
            particles = (0..<40).map { _ in
                ConfettiParticle(
                    color: colors.randomElement()!,
                    size: CGFloat.random(in: 4...10),
                    startX: CGFloat.random(in: -20...20),
                    startY: 0,
                    endX: CGFloat.random(in: -200...200),
                    endY: CGFloat.random(in: -400...(-100)),
                    rotation: Double.random(in: -360...360)
                )
            }

            withAnimation(.easeOut(duration: 1.5)) {
                isAnimating = true
            }
        }
        .allowsHitTesting(false)
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let rotation: Double
}
