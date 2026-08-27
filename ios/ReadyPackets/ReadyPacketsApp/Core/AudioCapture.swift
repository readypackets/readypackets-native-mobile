import AVFoundation
import Foundation

@MainActor final class AudioCapture: NSObject, ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var duration: TimeInterval = 0
    @Published var error: String?
    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private(set) var recordingURL: URL?

    func start() async {
        do {
            let granted = await AVAudioApplication.requestRecordPermission()
            guard granted else { error = "Microphone access is required to record an order response."; return }
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .spokenAudio, options: [])
            try session.setActive(true)
            let file = FileManager.default.temporaryDirectory.appending(path: "readypackets-\(UUID().uuidString).m4a")
            let settings: [String: Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44_100, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            recorder = try AVAudioRecorder(url: file, settings: settings)
            recorder?.record(); recordingURL = file; duration = 0; isRecording = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.duration += 1 }
        } catch { self.error = error.localizedDescription }
    }

    func stop() -> URL? {
        timer?.invalidate(); timer = nil; recorder?.stop(); recorder = nil; isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false)
        return recordingURL
    }
}
