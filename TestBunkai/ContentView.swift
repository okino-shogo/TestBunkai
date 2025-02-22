import SwiftUI

struct TaskItem: Codable, Identifiable {
    let id = UUID()  // リスト表示用の一意なID
    let task: String
    let time: String
    var isCompleted: Bool = false  // ✅ 完了状態を追加！

    enum CodingKeys: String, CodingKey {
        case task = "タスク"
        case time = "時間"
    }
}


struct WorkflowData: Codable {
    let id: String
    let status: String
    let outputs: [String: String]  // 🔹 `outputs` を追加！
}


struct WorkflowResponse: Codable {
    let task_id: String
    let workflow_run_id: String
    let data: WorkflowData
}


struct ContentView: View {
    @State private var inputText: String = ""  // ✅ ユーザーの入力を管理
    @State private var tasks: [TaskItem] = []
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            // ✅ ユーザーが入力できるテキストフィールド
            TextField("入力をここに...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                Task {
                    await runWorkflow()
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
                    // ✅ チェックボタン（トグル）
                    Button(action: {
                        task.isCompleted.toggle()
                    }) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                    }

                    // ✅ タスクのテキスト（完了したら取り消し線）
                    Text(task.task)
                        .font(.headline)
                        .strikethrough(task.isCompleted, color: .gray)  // 🔹 完了したら取り消し線
                        .opacity(task.isCompleted ? 0.5 : 1.0)  // 🔹 ちょっと薄くする

                    Spacer()

                    Text(task.time)
                        .foregroundColor(.gray)
                }
            }

        }
    }

    func runWorkflow() async {
        guard let url = URL(string: "https://api.dify.ai/v1/workflows/run") else {
            print("❌ URLが無効")
            return
        }

        isLoading = true
        defer { isLoading = false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer app-29l22pU5BSP03Dk6KVYwjjVg", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "inputs": ["task": inputText],
            "user": "abc-123"
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📤 送信するJSONデータ: \(jsonString)")
            }

        } catch {
            print("❌ JSON変換エラー: \(error.localizedDescription)")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 APIレスポンス: \(responseString)")
            }

            let responseData = try JSONDecoder().decode(WorkflowResponse.self, from: data)

            // ✅ `outputs["text"]` をデコードする処理
            if let jsonData = responseData.data.outputs["text"]?.data(using: .utf8) {
                let taskList = try JSONDecoder().decode([TaskItem].self, from: jsonData)
                DispatchQueue.main.async {
                    self.tasks = taskList
                }
            } else {
                print("❌ `outputs[\"text\"]` のデータ変換に失敗！")
            }

        } catch {
            print("❌ APIエラー: \(error.localizedDescription)")
        }
    }


}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

