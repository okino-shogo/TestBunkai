////
////  Api.swift
////  TestBunkai
////
////  Created by 沖野匠吾 on 2025/02/22.
////
//
//import Foundation
//// レスポンスのJSON構造に合わせたCodable構造体
//
//
//struct ContentView: View {
//    @State private var inputText: String = ""
//    @State private var outputText: String = ""
//    @State private var isLoading: Bool = false
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            // テキスト入力フィールド
//            TextField("テキストを入力してください", text: $inputText)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal)
//
//            // 送信ボタン
//            Button(action: {
//                Task {
//                    await runWorkflow()
//                }
//            }) {
//                HStack {
//                    Image(systemName: "paperplane.fill")
//                    Text("送信")
//                }
//                .padding()
//                .foregroundColor(.white)
//                .background(Color.blue)
//                .cornerRadius(8)
//            }
//            .padding(.horizontal)
//
//            // ローディング中の表示
//            if isLoading {
//                HStack {
//                    ProgressView()
//                    Text("実行中...")
//                }
//                .padding(.horizontal)
//            }
//
//            // APIからの出力結果を表示
//            Text("出力:")
//                .font(.headline)
//                .padding(.horizontal)
//            Text(outputText)
//                .padding()
//                .foregroundColor(.primary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color(UIColor.secondarySystemBackground))
//                .cornerRadius(8)
//                .padding(.horizontal)
//
//            Spacer()
//        }
//        .padding(.top)
//    }
//
//    // APIを実行して結果を取得する非同期関数
//    func runWorkflow() async {
//        guard let url = URL(string: "https://api.dify.ai/v1/workflows/run") else {
//            outputText = "URL生成エラー"
//            return
//        }
//
//        isLoading = true
//        defer { isLoading = false }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        // 実際のAPIキーに置き換えてください
//        request.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // リクエストボディの作成
//        let body: [String: Any] = [
//            "inputs": [
//                "input": inputText
//            ],
//            "user": "abc-123"  // 任意のユーザーID
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
//        } catch {
//            outputText = "JSON変換エラー: \(error.localizedDescription)"
//            return
//        }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(for: request)
//            let response = try JSONDecoder().decode(WorkflowResponse.self, from: data)
//            // outputs 辞書から "output" キーの値を取得
//            DispatchQueue.main.async {
//                self.outputText = response.data.outputs["output"] ?? "結果が見つかりません"
//            }
//        } catch {
//            DispatchQueue.main.async {
//                self.outputText = "APIエラー: \(error.localizedDescription)"
//            }
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//
//#Preview {
//    ContentView()
//}
