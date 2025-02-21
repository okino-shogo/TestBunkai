import Foundation

// レスポンスのJSON構造に合わせたCodable構造体
struct WorkflowResponse: Codable {
    let task_id: String
    let workflow_run_id: String
    let data: WorkflowData
}

struct WorkflowData: Codable {
    let id: String
    let workflow_id: String
    let status: String
    let outputs: [String: String]
    let error: String?
    let elapsed_time: Double
    let total_tokens: Int
    let total_steps: Int
    let created_at: Int
    let finished_at: Int
}

// ワークフロー実行関数
func runDifyWorkflow(input: String) {
    guard let url = URL(string: "https://api.dify.ai/v1/workflows/run") else {
        print("URLの生成に失敗しました")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    // APIキーを自身のものに置き換えてください
    request.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // JSONボディの設定
    let body: [String: Any] = [
        "inputs": [
            "input": input
        ],
        "user": "abc-123"  // 任意のユーザーID
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        print("JSONのシリアライズエラー: \(error)")
        return
    }

    // リクエスト実行
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("リクエストエラー: \(error)")
            return
        }

        guard let data = data else {
            print("レスポンスデータがありません")
            return
        }

        do {
            let workflowResponse = try JSONDecoder().decode(WorkflowResponse.self, from: data)
            print("ワークフロー実行成功: \(workflowResponse)")
            // outputs["output"]などで結果にアクセスできます
        } catch {
            print("JSONデコードエラー: \(error)")
        }
    }.resume()
}

