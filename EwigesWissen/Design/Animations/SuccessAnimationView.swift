import SwiftUI

struct SuccessAnimationView: View {
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var checkmarkTrim: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.success.opacity(0.2))
                .frame(width: 100, height: 100)
                .scaleEffect(scale)

            Circle()
                .fill(AppColors.success)
                .frame(width: 70, height: 70)
                .scaleEffect(scale)

            Image(systemName: "checkmark")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .opacity(opacity)
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1
            }
            withAnimation(.easeIn(duration: 0.2).delay(0.2)) {
                opacity = 1
            }
        }
    }
}
