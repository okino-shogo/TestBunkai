import SwiftUI

struct VoiceView: View {
    @StateObject private var player = SpeechPlayer()
    var tasks: [TaskItem]

    var body: some View {
        VStack {
            Text("現在のタスク: \(player.currentText)")
                .font(.title)
                .padding()

            HStack {
                Button(action: {
                    player.start(with: tasks)
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
