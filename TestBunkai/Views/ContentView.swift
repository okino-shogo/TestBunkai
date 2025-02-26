import SwiftUI



struct ContentView: View {
    @State private var inputText: String = ""
    @State private var tasks: [TaskItem] = []
    @State private var isLoading: Bool = false
    @State private var showVoiceView = false

    // (A) 編集モード管理
    @State private var editMode: EditMode = .inactive

    // (B) 新規サブタスク用
    @State private var newSubtaskName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // (1) タスク名入力 + 取得ボタン
                HStack {
                    TextField("入力をここに...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        Task {
                            do {
                                // Node.jsサーバーからタスク一覧を取得
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
                }
                .padding()

                // (2) サブタスクリスト + 削除 & 並び替え & 新規追加行
                List {
                    // A) 既存のサブタスクを表示
                    ForEach($tasks) { $task in
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
                    .onDelete(perform: deleteSubtasks)   // スワイプ削除 or Editモード
                    .onMove(perform: moveSubtasks)       // ドラッグで並び替え

                    // B) 新規サブタスクを追加する行
                    //    tasks が空でない時だけ表示したい場合は: if !tasks.isEmpty { ... }
                    HStack {
                        TextField("新しいサブタスク", text: $newSubtaskName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("追加") {
                            addNewSubtask()
                        }
                    }
                }
                // Editモードをリストに適用
                .environment(\.editMode, $editMode)

                // (3) タスク完了ボタン
                Button(action: {
                    Task {
                        do {
                            try await ApiService.saveTasks(taskName: inputText, tasks: tasks)
                            print("✅ タスクを完了として保存しました")
                        } catch {
                            print("❌ タスク保存エラー: \(error.localizedDescription)")
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("完了として保存")
                    }
                }
                .padding()

                // (4) 音声読み上げボタン
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
            .navigationTitle("タスク管理")
            // (C) EditButton をツールバーに配置 (iOS14+)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    // 新規サブタスク追加
    private func addNewSubtask() {
        guard !newSubtaskName.isEmpty else { return }
        let newItem = TaskItem(
            id: UUID(),          // ← ここを UUID() に
            task: newSubtaskName,
            time: "",
            isCompleted: false
        )
        tasks.append(newItem)
        newSubtaskName = ""
    }

    // 削除機能
    private func deleteSubtasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    // 並び替え機能
    private func moveSubtasks(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
