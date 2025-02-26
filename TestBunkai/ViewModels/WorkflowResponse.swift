//
//  WorkflowResponse.swift
//  TestBunkai
//
//  Created by 沖野匠吾 on 2025/02/22.
//

import Foundation
struct WorkflowResponse: Codable {
    let data: WorkflowData
}

struct WorkflowData: Codable {
    let outputs: WorkflowOutputs
}

struct WorkflowOutputs: Codable {
    let text: String  // 🔹 JSONの文字列として取得
}
