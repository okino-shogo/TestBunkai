import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var tasks: [TaskItem] = []
    @State private var isLoading: Bool = false
    @State private var showVoiceView = false

    var body: some View {
        VStack {
            TextField("入力をここに...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                Task {
                    do {
                        self.tasks = try await ApiService.fetchTasks(inputText: inputText)
                    } catch {
                        print("❌ APIエラー: \(error.localizedDescription)")
                    }
                }
            }) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("タスクを取得")
                }
            }
            .padding()

            List($tasks) { $task in
                HStack {
                    Button(action: {
                        task.isCompleted.toggle()
                    }) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                    }

                    Text(task.task)
                        .font(.headline)
                        .strikethrough(task.isCompleted, color: .gray)
                        .opacity(task.isCompleted ? 0.5 : 1.0)

                    Spacer()

                    Text(task.time)
                        .foregroundColor(.gray)
                }
            }

            Button(action: {
                showVoiceView = true
            }) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("タスクを音声で再生")
                }
            }
            .padding()
            .sheet(isPresented: $showVoiceView) {
                VoiceView(tasks: tasks)
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

