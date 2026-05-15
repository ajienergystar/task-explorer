//
//  TaskDetailViewModel.swift
//

import Foundation

@MainActor
final class TaskDetailViewModel: ObservableObject {
    @Published
    private(set) var state = ViewState()

    @Published
    private(set) var task: TaskItem

    private let repository: TaskRepositorying
    private let onCompletionChanged: (@MainActor (_ taskId: Int, _ completed: Bool) -> Void)?

    init(
        task: TaskItem,
        repository: TaskRepositorying,
        onCompletionChanged: (@MainActor (_ taskId: Int, _ completed: Bool) -> Void)? = nil
    ) {
        self.task = task
        self.repository = repository
        self.onCompletionChanged = onCompletionChanged
    }

    func sync(from latest: TaskItem) {
        task = latest
    }

    func toggleCompletion() {
        Task {
            let next = !task.isCompleted
            state.isSaving = true
            defer { state.isSaving = false }
            await repository.setLocallyCompleted(next, forTaskId: task.id)
            task.isCompleted = next
            onCompletionChanged?(task.id, next)
        }
    }
}

extension TaskDetailViewModel {
    struct ViewState: Equatable {
        var isSaving: Bool = false
    }
}
