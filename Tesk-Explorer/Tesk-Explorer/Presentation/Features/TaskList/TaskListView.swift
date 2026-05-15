// © 2026 Created by Aji Prakosa. All rights reserved.

import SwiftUI

struct TaskListView: View {
    @ObservedObject private var viewModel: TaskListViewModel

    @Environment(\.accessibilityReduceMotion)
    private var accessibilityReduceMotion

    @State
    private var revealedTaskIDs: Set<Int> = []

    init(viewModel: TaskListViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            taskExplorerBackground

            Group {
                if viewModel.state.isLoading, viewModel.tasks.isEmpty {
                    loadingView
                } else if let message = viewModel.state.errorMessage, viewModel.tasks.isEmpty {
                    errorView(message: message)
                } else {
                    listContent
                }
            }
        }
        .navigationTitle(Text("Tasks"))
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.load()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .symbolEffect(.rotate, isActive: viewModel.state.isLoading)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.35, green: 0.35, blue: 0.95),
                                    Color(red: 0.55, green: 0.25, blue: 0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .accessibilityLabel(Text("Reload tasks"))
                .disabled(viewModel.state.isLoading)
            }
        }
        .task {
            guard viewModel.tasks.isEmpty else { return }
            viewModel.load()
        }
        .onChange(of: viewModel.tasks.map(\.id)) { _, newIDs in
            scheduleRowReveal(forIDs: newIDs)
        }
    }

    private var taskExplorerBackground: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.92, green: 0.94, blue: 1.0), location: 0),
                .init(color: Color(red: 1.0, green: 0.93, blue: 0.97), location: 0.45),
                .init(color: Color(red: 0.99, green: 0.96, blue: 0.88), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
                .tint(Color(red: 0.38, green: 0.4, blue: 0.92))

            Text("Loading tasks…")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.35, green: 0.35, blue: 0.75),
                            Color(red: 0.52, green: 0.28, blue: 0.72)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
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
            .tint(Color(red: 0.42, green: 0.35, blue: 0.94))
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
                    .opacity(revealedTaskIDs.contains(task.id) ? 1 : 0)
                    .offset(
                        x: accessibilityReduceMotion || revealedTaskIDs.contains(task.id) ? 0 : 28,
                        y: accessibilityReduceMotion || revealedTaskIDs.contains(task.id) ? 0 : 12
                    )
                    .animation(
                        accessibilityReduceMotion
                            ? .default
                            : .spring(response: 0.52, dampingFraction: 0.78, blendDuration: 0),
                        value: revealedTaskIDs.contains(task.id)
                    )
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
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
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .listRowSpacing(4)
        .overlay {
            if viewModel.state.isLoading {
                ProgressView()
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 16, y: 6)
            }
        }
        .refreshable {
            await viewModel.reload()
        }
    }

    private func scheduleRowReveal(forIDs newIDs: [Int]) {
        guard !newIDs.isEmpty else {
            revealedTaskIDs = []
            return
        }

        if accessibilityReduceMotion {
            revealedTaskIDs = Set(newIDs)
            return
        }

        revealedTaskIDs = []

        let stagger: TimeInterval = 0.046
        for (index, id) in newIDs.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + stagger * Double(index)) {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                    _ = revealedTaskIDs.insert(id)
                }
            }
        }
    }
}

private struct TaskRowView: View {
    let title: String
    let isCompleted: Bool
    /// Used by UI tests for stable selection when extended.
    var accessibilityIdentifier: String = ""

    private static let blueGradient = LinearGradient(
        colors: [
            Color(red: 0.16, green: 0.48, blue: 0.98),
            Color(red: 0.22, green: 0.72, blue: 0.98)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private static let mintGradient = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.65, blue: 0.52),
            Color(red: 0.12, green: 0.78, blue: 0.48)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private var haloGradient: LinearGradient {
        isCompleted ? Self.mintGradient : Self.blueGradient
    }

    private var badgeFill: LinearGradient {
        LinearGradient(
            colors: isCompleted
                ? [
                    Color(red: 0.75, green: 0.95, blue: 0.82),
                    Color(red: 0.82, green: 0.99, blue: 0.88)
                ]
                : [
                    Color(red: 0.82, green: 0.9, blue: 1.0),
                    Color(red: 0.92, green: 0.95, blue: 1.0)
                ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var badgeBorder: Color {
        isCompleted ? Color(red: 0.1, green: 0.65, blue: 0.52).opacity(0.45)
            : Color(red: 0.2, green: 0.45, blue: 1.0).opacity(0.42)
    }

    private var badgeTextColor: Color {
        isCompleted ? Color(red: 0.04, green: 0.55, blue: 0.42) : Color(red: 0.1, green: 0.35, blue: 0.92)
    }

    private var titleOpenColor: Color {
        Color(red: 0.14, green: 0.12, blue: 0.28)
    }

    private var cardEdgeGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.6),
                (isCompleted ? Color.green : Color.blue).opacity(0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(haloGradient.opacity(0.22))
                    .frame(width: 44, height: 44)

                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(haloGradient)
            }

            Text(title)
                .font(.body.weight(.medium))
                .multilineTextAlignment(.leading)
                .strikethrough(isCompleted, color: Color.secondary.opacity(0.72))
                .foregroundStyle(isCompleted ? Color.secondary : titleOpenColor)

            Spacer(minLength: 8)

            Text(isCompleted ? "Done" : "Open")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .foregroundStyle(badgeTextColor)
                .background(
                    Capsule(style: .continuous)
                        .fill(badgeFill)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(badgeBorder, lineWidth: 1)
                )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: Color(red: 0.42, green: 0.35, blue: 0.65).opacity(0.12), radius: 14, y: 6)
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(cardEdgeGradient, lineWidth: 1)
        )
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
