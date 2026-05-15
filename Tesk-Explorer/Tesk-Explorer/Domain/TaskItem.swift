//
//  TaskItem.swift
//  Task Explorer — domain model (decoupled from API / persistence shapes).
//

import Foundation

/// User-facing task, after merging remote payload with locally persisted completion edits.
struct TaskItem: Identifiable, Equatable, Hashable, Sendable {
    let id: Int
    let title: String
    var isCompleted: Bool
}

extension TaskItem {
    /// Shared fixtures for Xcode previews (`#Preview`).
    static let previewSamples: [TaskItem] = [
        TaskItem(id: 1, title: "Write unit tests", isCompleted: false),
        TaskItem(id: 2, title: "Ship Task Explorer", isCompleted: true)
    ]
}
