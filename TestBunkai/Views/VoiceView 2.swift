import SwiftUI

struct VoiceView: View {
    @StateObject private var player = SpeechPlayer()
    var tasks: [TaskItem]

    var body: some View {
        VStack {
            Text("現在のタスク: \(player.currentText)")
                .font(.title)
                .padding()

            List(tasks) { task in
                HStack {
                    Text(task.task)
                        .font(.headline)
                        .foregroundColor(player.currentTaskID == task.id ? .blue : .primary) // 🔹 再生中のタスクを青色に！

                    Spacer()

                    Text(task.time)
                        .foregroundColor(.gray)
                }
                .background(player.currentTaskID == task.id ? Color.yellow.opacity(0.3) : Color.clear) // 🔹 背景色でハイライト
                .cornerRadius(10)
            }

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
