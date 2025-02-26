//
//  TaskItem.swift
//  TestBunkai
//
//  Created by 沖野匠吾 on 2025/02/22.
//

import Foundation

struct TaskItem: Identifiable, Codable {
    // サーバーのJSONには含まれないプロパティ
    var id: UUID = UUID()

    var task: String
    var time: String
    var isCompleted: Bool

    // サーバーのJSONキーが日本語の場合
    enum CodingKeys: String, CodingKey {
        case task = "タスク"
        case time = "時間"
        case isCompleted = "完了"
        // id は含めない
    }
}



