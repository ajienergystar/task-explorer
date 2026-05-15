//
//  TaskListView.swift
//

import SwiftUI

struct TaskListView: View {
    @ObservedObject private var viewModel: TaskListViewModel

    init(viewModel: TaskListViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.state.isLoading, viewModel.tasks.isEmpty {
                loadingView
            } else if let message = viewModel.state.errorMessage, viewModel.tasks.isEmpty {
                errorView(message: message)
            } else {
                listContent
            }
        }
        .navigationTitle(Text("Tasks"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.load()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel(Text("Reload tasks"))
                .disabled(viewModel.state.isLoading)
            }
        }
        .task {
            guard viewModel.tasks.isEmpty else { return }
            viewModel.load()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading tasks…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Loading tasks"))
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Couldn’t load tasks", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
                .multilineTextAlignment(.center)
        } actions: {
            Button("Try again") {
                viewModel.retry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var listContent: some View {
        List(viewModel.tasks) { task in
            NavigationLink(value: task) {
                TaskRowView(
                    title: task.title,
                    isCompleted: task.isCompleted,
                    accessibilityIdentifier: task.id.description
                )
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button {
                    Task {
                        await viewModel.toggleCompletion(for: task.id)
                    }
                } label: {
                    Label(task.isCompleted ? "Mark incomplete" : "Mark complete", systemImage: "checkmark.circle")
                }
                .tint(task.isCompleted ? .orange : .green)
            }
        }
        .overlay {
            if viewModel.state.isLoading {
                ProgressView()
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .refreshable {
            await viewModel.reload()
        }
    }
}

private struct TaskRowView: View {
    let title: String
    let isCompleted: Bool
    /// Used by UI tests for stable selection when extended.
    var accessibilityIdentifier: String = ""

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isCompleted ? .green : Color.secondary)

            Text(title)
                .font(.body)
                .strikethrough(isCompleted)
                .foregroundStyle(isCompleted ? .secondary : .primary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            Text(isCompleted ? "Done" : "Open")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isCompleted ? Color.green.opacity(0.15) : Color.blue.opacity(0.12))
                )
                .foregroundStyle(isCompleted ? .green : .blue)
                .accessibilityHidden(true)
        }
        .accessibilityIdentifier("task-row-\(accessibilityIdentifier)")
    }
}

#Preview {
    NavigationStack {
        TaskListView(viewModel: TaskListViewModel(repository: PreviewMocks.repository))
    }
}

private enum PreviewMocks {
    static let repository = PreviewTaskRepository()
}

private final class PreviewTaskRepository: TaskRepositorying, @unchecked Sendable {
    private var samples = TaskItem.previewSamples

    func fetchTasks() async throws -> [TaskItem] {
        samples
    }

    func setLocallyCompleted(_ completed: Bool, forTaskId id: Int) async {
        guard let ix = samples.firstIndex(where: { $0.id == id }) else { return }
        samples[ix].isCompleted = completed
    }
}
