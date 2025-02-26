import Foundation

/// Node.jsサーバーから返ってくるJSONのモデル
/// 例: { "task": { "id": 1, "name": "買い物リスト", "status": "new" },
///       "subtasks": [{ "id": 10, "content": "牛乳を買う", "completed": false }, ...],
///       "generated": true }
struct NodeTaskResponse: Codable {
    let task: NodeTask
    let subtasks: [NodeSubtask]
    let generated: Bool
}

struct NodeTask: Codable {
    let id: Int
    let name: String
    let status: String
}

struct NodeSubtask: Codable {
    let id: Int?
    let content: String
    let completed: Bool
}




class ApiService {

    /// (1) タスク取得: Node.jsサーバーへGET
    static func fetchTasks(inputText: String) async throws -> [TaskItem] {
        // 例: http://localhost:3000/task?name=買い物リスト
        guard let encodedName = inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://localhost:3000/task?name=\(encodedName)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // 通信
        let (data, _) = try await URLSession.shared.data(for: request)

        // デバッグ用ログ
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Node.jsレスポンス: \(responseString)")
        }

        // Node.jsからのレスポンスをデコード
        let nodeResponse = try JSONDecoder().decode(NodeTaskResponse.self, from: data)

        let tasks = nodeResponse.subtasks.map { sub in
            TaskItem(
                id: UUID(),          // サーバーの `id` を参照しない
                task: sub.content,
                time: "",
                isCompleted: sub.completed
            )
        }



        return tasks
    }

    /// (2) タスク完了: Node.jsサーバーへPOST (タスク名＋サブタスクを送信して保存)
    static func saveTasks(taskName: String, tasks: [TaskItem]) async throws {
        guard let url = URL(string: "http://localhost:3000/task") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // サブタスクをDBに保存するため、content と completed を持たせる
        let subtasksPayload = tasks.map { t in
            [
                "content": t.task,
                "completed": t.isCompleted
            ]
        }

        let body: [String: Any] = [
            "name": taskName,
            "subtasks": subtasksPayload
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, _) = try await URLSession.shared.data(for: request)

        // デバッグ用ログ
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Node.js保存レスポンス: \(responseString)")
        }
    }
}

