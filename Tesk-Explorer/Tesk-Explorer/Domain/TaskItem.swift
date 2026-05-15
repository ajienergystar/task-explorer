// © 2026 Created by Aji Prakosa. All rights reserved.

import Foundation

struct TaskItem: Identifiable, Equatable, Hashable, Sendable {
    let id: Int
    let title: String
    var isCompleted: Bool
}

extension TaskItem {
    static let previewSamples: [TaskItem] = [
        TaskItem(id: 1, title: "Write unit tests", isCompleted: false),
        TaskItem(id: 2, title: "Ship Task Explorer", isCompleted: true)
    ]
}
