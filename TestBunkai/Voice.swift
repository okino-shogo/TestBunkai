//
//  Voice.swift
//  TestBunkai
//
//  Created by 沖野匠吾 on 2025/02/22.
//
import SwiftUI
import AVFoundation

struct SpeechItem {
    let text: String
    let time: TimeInterval // 秒
}

class SpeechPlayer: ObservableObject {
    private var synthesizer = AVSpeechSynthesizer()
    private var timer: Timer?
    private var index = 0

    @Published var isPlaying = false
    @Published var currentText = ""

    let speechList: [SpeechItem] = [
        SpeechItem(text: "こんにちは", time: 3),
        SpeechItem(text: "次の文章です", time: 5),
        SpeechItem(text: "Swiftは楽しい！", time: 7)
    ]

    func start() {
        guard !speechList.isEmpty else { return }
        index = 0
        isPlaying = true
        scheduleNextSpeech()
    }

    func stop() {
        isPlaying = false
        timer?.invalidate()
        synthesizer.stopSpeaking(at: .immediate)
    }

    private func scheduleNextSpeech() {
        guard isPlaying, index < speechList.count else {
            isPlaying = false
            return
        }

        let item = speechList[index]
        currentText = item.text
        speak(text: item.text)

        timer = Timer.scheduledTimer(withTimeInterval: item.time, repeats: false) { [weak self] _ in
            self?.index += 1
            self?.scheduleNextSpeech()
        }
    }

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        synthesizer.speak(utterance)
    }
}

struct Voice: View {
    @StateObject private var player = SpeechPlayer()

    var body: some View {
        VStack {
            Text("現在のテキスト: \(player.currentText)")
                .font(.title)
                .padding()

            HStack {
                Button(action: {
                    player.start()
                }) {
                    Text("再生")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    player.stop()
                }) {
                    Text("停止")
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

@main
struct SpeechApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
#Preview {
    Voice()
}
