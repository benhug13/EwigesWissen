import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false

    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .cyan, .pink, .mint, .indigo]
    let shapes: [String] = ["circle.fill", "star.fill", "heart.fill", "diamond.fill"]

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: particle.shape)
                    .font(.system(size: particle.size))
                    .foregroundStyle(particle.color)
                    .offset(
                        x: isAnimating ? particle.endX : particle.startX,
                        y: isAnimating ? particle.endY : particle.startY
                    )
                    .opacity(isAnimating ? 0 : 1)
                    .rotationEffect(.degrees(isAnimating ? particle.rotation : 0))
                    .scaleEffect(isAnimating ? 0.2 : 1.0)
            }
        }
        .onAppear {
            particles = (0..<50).map { _ in
                ConfettiParticle(
                    color: colors.randomElement()!,
                    size: CGFloat.random(in: 6...14),
                    shape: shapes.randomElement()!,
                    startX: CGFloat.random(in: -30...30),
                    startY: CGFloat.random(in: -10...10),
                    endX: CGFloat.random(in: -250...250),
                    endY: CGFloat.random(in: -500...(-80)),
                    rotation: Double.random(in: -720...720)
                )
            }

            withAnimation(.easeOut(duration: 2.0)) {
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
    let shape: String
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let rotation: Double
}
