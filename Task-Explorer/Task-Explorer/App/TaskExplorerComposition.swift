// © 2026 Created by Aji Prakosa. All rights reserved.

import Foundation

@MainActor
enum TaskExplorerComposition {
    static func production() -> TaskExplorerEnvironment {
        let http = URLSessionHTTPClient()
        let remote = TodoRemoteDataSource(http: http)
        let store = UserDefaultsTaskCompletionStore()
        let repository = DefaultTaskRepository(remote: remote, completionStore: store)
        return TaskExplorerEnvironment(repository: repository)
    }
}

@MainActor
struct TaskExplorerEnvironment {
    let repository: TaskRepositorying

    func makeTaskListViewModel() -> TaskListViewModel {
        TaskListViewModel(repository: repository)
    }

    func makeTaskDetailViewModel(for task: TaskItem, listCoordinator: TaskListViewModel?) -> TaskDetailViewModel {
        TaskDetailViewModel(task: task, repository: repository) { taskId, completed in
            listCoordinator?.applyLocallyCompleted(completed, forTaskId: taskId)
        }
    }
}
