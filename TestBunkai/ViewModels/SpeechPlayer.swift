import SwiftUI
import AVFoundation
import MediaPlayer

class SpeechPlayer: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private var synthesizer = AVSpeechSynthesizer()
    private var timer: Timer?
    private var index = 0
    private var isWaiting = false  // 🔹 無音待機中かどうか

    @Published var isPlaying = false
    @Published var currentText = ""
    @Published var currentTaskID: UUID?

    private var tasks: [TaskItem] = []

    override init() {
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
        setupRemoteCommandCenter()
    }

    func start(with tasks: [TaskItem]) {
        self.tasks = tasks.filter { !$0.isCompleted }
        guard !self.tasks.isEmpty else { return }

        index = 0
        isPlaying = true
        isWaiting = false
        scheduleNextSpeech()
    }

    func stop() {
        isPlaying = false
        isWaiting = false
        timer?.invalidate()
        synthesizer.stopSpeaking(at: .immediate)
        currentTaskID = nil
        updateNowPlayingInfo()
    }

    func skipToNext() {
        guard isPlaying, index + 1 < tasks.count else { return }
        timer?.invalidate()  // 🔹 無音待機中なら即キャンセル
        isWaiting = false
        index += 1
        scheduleNextSpeech()
    }

    private func scheduleNextSpeech() {
        guard isPlaying, index < tasks.count else {
            isPlaying = false
            currentTaskID = nil
            updateNowPlayingInfo()
            return
        }

        let task = tasks[index]
        currentTaskID = task.id
        currentText = task.task
        speak(text: task.task)
        updateNowPlayingInfo()
    }

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        synthesizer.speak(utterance)
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("❌ AudioSession 設定エラー: \(error.localizedDescription)")
        }
    }

    /// 🔹 **MPNowPlayingInfoCenter を更新**
    private func updateNowPlayingInfo() {
        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentText  // 🔹 タスクの内容を表示し続ける
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            if !(self?.isPlaying ?? false) {
                self?.start(with: self?.tasks ?? [])
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.stop()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.skipToNext()
            return .success
        }
    }

    /// 🔹 **音声が終わった後に無音待機**
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard index < tasks.count else { return }

        let task = tasks[index]
        let duration = Double(task.time.replacingOccurrences(of: "秒", with: "")) ?? 3.0

        isWaiting = true  // 🔹 無音待機モード
        updateNowPlayingInfo()

        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.isWaiting = false
            self?.index += 1
            self?.scheduleNextSpeech()
        }
    }
}
