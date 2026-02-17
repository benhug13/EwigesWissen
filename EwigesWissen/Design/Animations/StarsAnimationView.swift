import SwiftUI

struct StarsAnimationView: View {
    let count: Int
    @State private var appeared = false
    @State private var starScales: [CGFloat] = [0, 0, 0]
    @State private var starRotations: [Double] = [-30, -30, -30]
    @State private var glowOpacities: [Double] = [0, 0, 0]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                ZStack {
                    // Glow behind filled stars
                    if index < count {
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundStyle(AppColors.starFilled)
                            .blur(radius: 8)
                            .opacity(glowOpacities[index])
                            .scaleEffect(starScales[index] * 1.5)
                    }

                    Image(systemName: index < count ? "star.fill" : "star")
                        .font(.title)
                        .foregroundStyle(index < count ? AppColors.starFilled : AppColors.starEmpty)
                        .scaleEffect(starScales[index])
                        .rotationEffect(.degrees(starRotations[index]))
                }
            }
        }
        .onAppear {
            guard !appeared else { return }
            appeared = true
            for index in 0..<3 {
                let delay = Double(index) * 0.2
                withAnimation(.spring(response: 0.4, dampingFraction: 0.4).delay(delay)) {
                    starScales[index] = index < count ? 1.1 : 0.8
                    starRotations[index] = index < count ? 10 : 0
                }
                // Settle to final scale
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(delay + 0.2)) {
                    starScales[index] = index < count ? 1.0 : 0.8
                    starRotations[index] = 0
                }
                // Glow pulse
                if index < count {
                    withAnimation(.easeIn(duration: 0.2).delay(delay)) {
                        glowOpacities[index] = 0.6
                    }
                    withAnimation(.easeOut(duration: 0.5).delay(delay + 0.3)) {
                        glowOpacities[index] = 0
                    }
                }
            }
        }
    }
}
