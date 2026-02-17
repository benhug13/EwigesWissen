import AudioToolbox
import AVFoundation

@Observable
final class SoundService {
    static let shared = SoundService()

    var isEnabled: Bool = true

    private init() {}

    func playCorrect() {
        guard isEnabled else { return }
        // Ascending two-tone chime
        AudioServicesPlaySystemSound(1025)
    }

    func playIncorrect() {
        guard isEnabled else { return }
        // Short low thud
        AudioServicesPlaySystemSound(1073)
    }

    func playSuccess() {
        guard isEnabled else { return }
        // Triumphant fanfare sound
        AudioServicesPlaySystemSound(1115)
    }

    func playTap() {
        guard isEnabled else { return }
        // Soft click
        AudioServicesPlaySystemSound(1104)
    }
}
