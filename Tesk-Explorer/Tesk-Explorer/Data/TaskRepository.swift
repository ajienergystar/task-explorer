//
//  TaskRepository.swift
//

import Foundation

protocol TaskRepositorying: Sendable {
    func fetchTasks() async throws -> [TaskItem]
    func setLocallyCompleted(_ completed: Bool, forTaskId id: Int) async
}

struct DefaultTaskRepository: TaskRepositorying {
    private let remote: TodoRemoteDataSourcing
    private let completionStore: TaskCompletionStoring

    init(remote: TodoRemoteDataSourcing, completionStore: TaskCompletionStoring) {
        self.remote = remote
        self.completionStore = completionStore
    }

    func fetchTasks() async throws -> [TaskItem] {
        let dtos = try await remote.fetchTodos()
        var items: [TaskItem] = []
        items.reserveCapacity(dtos.count)

        for dto in dtos {
            let persisted = completionStore.persistedCompletion(forTaskId: dto.id)
            let merged = persisted ?? dto.completed
            items.append(TaskItem(id: dto.id, title: dto.title, isCompleted: merged))
        }

        items.sort { $0.id < $1.id }
        return items
    }

    func setLocallyCompleted(_ completed: Bool, forTaskId id: Int) async {
        completionStore.setPersistedCompletion(completed, forTaskId: id)
    }
}
