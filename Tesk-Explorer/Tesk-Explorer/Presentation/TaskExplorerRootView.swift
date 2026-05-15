// © 2026 Created by Aji Prakosa. All rights reserved.

import SwiftUI

struct TaskExplorerRootView: View {
    private let environment: TaskExplorerEnvironment
    @StateObject private var listViewModel: TaskListViewModel

    init(environment: TaskExplorerEnvironment) {
        self.environment = environment
        _listViewModel = StateObject(wrappedValue: environment.makeTaskListViewModel())
    }

    var body: some View {
        NavigationStack {
            TaskListView(viewModel: listViewModel)
                .navigationDestination(for: TaskItem.self) { task in
                    TaskDetailView(
                        viewModel: environment.makeTaskDetailViewModel(for: task, listCoordinator: listViewModel)
                    )
                    .navigationBarBackButtonHidden(false)
                }
        }
    }
}

#Preview("Root") {
    TaskExplorerRootView(environment: TaskExplorerEnvironment(repository: RootPreviewRepository()))
}

private final class RootPreviewRepository: TaskRepositorying, @unchecked Sendable {
    private var samples = TaskItem.previewSamples

    func fetchTasks() async throws -> [TaskItem] {
        samples
    }

    func setLocallyCompleted(_ completed: Bool, forTaskId id: Int) async {
        guard let ix = samples.firstIndex(where: { $0.id == id }) else { return }
        samples[ix].isCompleted = completed
    }
}
