import AVFoundation

@Observable
final class SoundService {
    static let shared = SoundService()

    var isEnabled: Bool = true
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?

    private init() {}

    func playCorrect() {
        guard isEnabled else { return }
        playTone(frequency: 880, duration: 0.15, secondFrequency: 1100, secondDelay: 0.1)
    }

    func playIncorrect() {
        guard isEnabled else { return }
        playTone(frequency: 330, duration: 0.3)
    }

    func playSuccess() {
        guard isEnabled else { return }
        playTone(frequency: 523, duration: 0.1, secondFrequency: 659, secondDelay: 0.1)
    }

    func playTap() {
        guard isEnabled else { return }
        playTone(frequency: 600, duration: 0.05)
    }

    private func playTone(frequency: Double, duration: Double, secondFrequency: Double? = nil, secondDelay: Double? = nil) {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let sampleRate: Double = 44100
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)

        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                let t = Double(i) / sampleRate
                let envelope = min(1.0, min(t / 0.01, (duration - t) / 0.01))
                channelData[i] = Float(sin(2.0 * .pi * frequency * t) * 0.3 * envelope)
            }
        }

        do {
            try engine.start()
            player.play()
            player.scheduleBuffer(buffer) {
                if let secondFreq = secondFrequency, let delay = secondDelay {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                        self?.playTone(frequency: secondFreq, duration: duration)
                    }
                }
            }
            // Keep reference alive
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5) {
                engine.stop()
            }
        } catch {
            // Silently fail
        }
    }
}
