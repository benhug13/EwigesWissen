import SwiftUI
import AVFoundation

struct TeacherOverlayView: View {
    let onDismiss: () -> Void

    @State private var backgroundOpacity: Double = 0
    @State private var teacherScale: CGFloat = 0
    @State private var teacherY: CGFloat = 300
    @State private var bubbleScale: CGFloat = 0
    @State private var bubbleOpacity: Double = 0
    @State private var headShake: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var synthesizer = AVSpeechSynthesizer()

    private let message = "Du musst noch sehr viel üben!"

    var body: some View {
        ZStack {
            Color.black.opacity(backgroundOpacity * 0.7)
                .ignoresSafeArea()
                .onTapGesture { dismissWithAnimation() }

            VStack(spacing: 0) {
                Spacer()

                // Speech bubble
                VStack(spacing: 0) {
                    Text(message)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.error.opacity(0.3), lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10)
                        .scaleEffect(bubbleScale)
                        .opacity(bubbleOpacity)
                        .padding(.horizontal, 30)

                    // Arrow
                    TeacherTriangle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 20, height: 12)
                        .opacity(bubbleOpacity)
                }

                // Teacher
                ZStack {
                    // Body
                    Capsule()
                        .fill(Color(red: 0.3, green: 0.3, blue: 0.5))
                        .frame(width: 90, height: 60)
                        .offset(y: 30)

                    // Head
                    ZStack {
                        // Face
                        Circle()
                            .fill(Color(red: 1.0, green: 0.85, blue: 0.7))
                            .frame(width: 90, height: 90)

                        // Hair
                        Ellipse()
                            .fill(Color(red: 0.35, green: 0.25, blue: 0.15))
                            .frame(width: 95, height: 50)
                            .offset(y: -28)

                        // Eyes
                        HStack(spacing: 20) {
                            TeacherEye()
                            TeacherEye()
                        }
                        .offset(y: -2)

                        // Glasses
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.7), lineWidth: 2.5)
                                .frame(width: 28, height: 24)
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.7), lineWidth: 2.5)
                                .frame(width: 28, height: 24)
                        }
                        .offset(y: -2)

                        // Bridge
                        Rectangle()
                            .fill(Color.gray.opacity(0.7))
                            .frame(width: 6, height: 2.5)
                            .offset(y: -2)

                        // Frown
                        TeacherFrownShape()
                            .stroke(Color(red: 0.7, green: 0.3, blue: 0.3), lineWidth: 2.5)
                            .frame(width: 24, height: 10)
                            .offset(y: 18)
                    }
                    .rotationEffect(.degrees(headShake))
                }
                .scaleEffect(teacherScale)
                .offset(y: teacherY)

                Spacer()
                    .frame(height: 40)

                // Button
                Button {
                    dismissWithAnimation()
                } label: {
                    Text("OK, ich übe mehr!")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 40)
                        .background(AppColors.primary)
                        .clipShape(Capsule())
                }
                .opacity(buttonOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
        .onDisappear {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func startAnimations() {
        // Background
        withAnimation(.easeIn(duration: 0.3)) {
            backgroundOpacity = 1
        }

        // Teacher slides up
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
            teacherScale = 1
            teacherY = 0
        }

        // Bubble appears
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.8)) {
            bubbleScale = 1
            bubbleOpacity = 1
        }

        // Speak the message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            speakMessage()
        }

        // Head shake
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            shakeHead()
        }

        // Button
        withAnimation(.easeOut(duration: 0.4).delay(2.5)) {
            buttonOpacity = 1
        }
    }

    private func speakMessage() {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-CH")
            ?? AVSpeechSynthesisVoice(language: "de-DE")
        utterance.rate = 0.45
        utterance.pitchMultiplier = 0.9
        utterance.volume = 0.8
        synthesizer.speak(utterance)
    }

    private func shakeHead() {
        withAnimation(.easeInOut(duration: 0.15)) { headShake = 10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.15)) { headShake = -10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.15)) { headShake = 8 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeInOut(duration: 0.15)) { headShake = -8 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.15)) { headShake = 5 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeInOut(duration: 0.2)) { headShake = 0 }
        }
    }

    private func dismissWithAnimation() {
        synthesizer.stopSpeaking(at: .immediate)
        withAnimation(.easeIn(duration: 0.3)) {
            backgroundOpacity = 0
            teacherY = 300
            teacherScale = 0.5
            bubbleOpacity = 0
            buttonOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Helper Shapes

private struct TeacherTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - 10, y: 0))
        path.addLine(to: CGPoint(x: rect.midX + 10, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct TeacherEye: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(.white)
                .frame(width: 14, height: 16)
            Circle()
                .fill(.black)
                .frame(width: 7, height: 7)
                .offset(y: 1)
        }
    }
}

private struct TeacherFrownShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: 0),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}
