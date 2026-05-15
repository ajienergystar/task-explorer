//
//  TaskListViewModel.swift
//

import Foundation

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published
    private(set) var state = ViewState()

    @Published
    private(set) var tasks: [TaskItem] = []

    private let repository: TaskRepositorying

    init(repository: TaskRepositorying) {
        self.repository = repository
    }

    func load() {
        Task {
            await performLoad(resetTasksOnFailure: false)
        }
    }

    /// Awaits networking so callers like `.refreshable` can finish when the reload completes.
    func reload() async {
        await performLoad(resetTasksOnFailure: false)
    }

    func retry() {
        Task {
            await performLoad(resetTasksOnFailure: true)
        }
    }

    private func performLoad(resetTasksOnFailure: Bool) async {
        state.errorMessage = nil
        state.isLoading = true
        defer { state.isLoading = false }

        do {
            tasks = try await repository.fetchTasks()
        } catch {
            if resetTasksOnFailure {
                tasks = []
            }
            state.errorMessage = Self.message(for: error)
        }
    }

    func toggleCompletion(for taskId: Int) async {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        let toggled = !tasks[index].isCompleted
        await repository.setLocallyCompleted(toggled, forTaskId: taskId)
        tasks[index].isCompleted = toggled
    }

    func applyLocallyCompleted(_ completed: Bool, forTaskId id: Int) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isCompleted = completed
    }

    /// Maps domain / infra errors into a single user-visible string without leaking implementation details everywhere.
    private static func message(for error: Error) -> String {
        if let net = error as? NetworkingError {
            return net.userMessage
        }
        return error.localizedDescription
    }
}

extension TaskListViewModel {
    struct ViewState: Equatable {
        var isLoading: Bool = false
        var errorMessage: String?
    }
}
