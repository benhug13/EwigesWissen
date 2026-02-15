import SwiftUI

struct ProgressBarView: View {
    let progress: Double // 0.0 to 1.0
    let color: Color
    let height: CGFloat

    init(progress: Double, color: Color = AppColors.primary, height: CGFloat = 8) {
        self.progress = min(max(progress, 0), 1)
        self.color = color
        self.height = height
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color.opacity(0.2))
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.spring(duration: 0.5), value: progress)
            }
        }
        .frame(height: height)
    }
}
