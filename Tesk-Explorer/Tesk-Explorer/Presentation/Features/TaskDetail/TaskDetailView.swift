// © 2026 Created by Aji Prakosa. All rights reserved.

import SwiftUI

struct TaskDetailView: View {
    @ObservedObject private var viewModel: TaskDetailViewModel

    init(viewModel: TaskDetailViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top) {
                    Image(systemName: viewModel.task.isCompleted ? "checkmark.seal.fill" : "seal")
                        .font(.largeTitle)
                        .foregroundStyle(viewModel.task.isCompleted ? .green : .secondary)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.task.title)
                            .font(.title2.weight(.semibold))
                            .strikethrough(viewModel.task.isCompleted)
                            .foregroundStyle(viewModel.task.isCompleted ? .secondary : .primary)
                        Label(
                            viewModel.task.isCompleted ? "Completed locally" : "Not completed",
                            systemImage: viewModel.task.isCompleted ? "bookmark.fill" : "bookmark"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Identifier")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.task.id)")
                        .font(.body.monospacedDigit())
                        .accessibilityIdentifier("task-detail-id")
                }

                Button {
                    viewModel.toggleCompletion()
                } label: {
                    if viewModel.state.isSaving {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(viewModel.task.isCompleted ? "Mark as not done" : "Mark as completed")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.state.isSaving)

                Text("Completion changes are saved on this device only; the demo API does not persist edits.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(Text("Detail"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.state.isSaving {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(
            viewModel: TaskDetailViewModel(
                task: TaskItem(id: 42, title: "Sample detail", isCompleted: false),
                repository: DetailPreviewRepo()
            )
        )
    }
}

private struct DetailPreviewRepo: TaskRepositorying {
    func fetchTasks() async throws -> [TaskItem] {
        []
    }

    func setLocallyCompleted(_: Bool, forTaskId _: Int) async {}
}
