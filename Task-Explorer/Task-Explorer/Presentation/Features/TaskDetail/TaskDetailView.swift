// © 2026 Created by Aji Prakosa. All rights reserved.

import SwiftUI

struct TaskDetailView: View {
    @ObservedObject private var viewModel: TaskDetailViewModel

    init(viewModel: TaskDetailViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            taskExplorerBackground

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard

                    identifierCard

                    actionButton

                    disclaimerCard

                    Spacer(minLength: 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(Text("Detail"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            if viewModel.state.isSaving {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                        .tint(Color(red: 0.38, green: 0.4, blue: 0.92))
                }
            }
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

    private static let coralAccentGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.42, blue: 0.38),
            Color(red: 1.0, green: 0.62, blue: 0.35)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private var haloGradient: LinearGradient {
        viewModel.task.isCompleted ? Self.mintGradient : Self.blueGradient
    }

    private var statusBadgeFill: LinearGradient {
        LinearGradient(
            colors: viewModel.task.isCompleted
                ? [
                    Color(red: 0.75, green: 0.95, blue: 0.82),
                    Color(red: 0.82, green: 0.99, blue: 0.88)
                ]
                : [
                    Color(red: 1.0, green: 0.88, blue: 0.82),
                    Color(red: 1.0, green: 0.94, blue: 0.78)
                ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var statusBadgeBorder: Color {
        viewModel.task.isCompleted
            ? Color(red: 0.1, green: 0.65, blue: 0.52).opacity(0.45)
            : Color(red: 1.0, green: 0.45, blue: 0.28).opacity(0.42)
    }

    private var statusBadgeTextColor: Color {
        viewModel.task.isCompleted
            ? Color(red: 0.04, green: 0.55, blue: 0.42)
            : Color(red: 0.82, green: 0.28, blue: 0.12)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(haloGradient.opacity(0.26))
                        .frame(width: 56, height: 56)

                    Image(systemName: viewModel.task.isCompleted ? "checkmark.seal.fill" : "sparkles")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(haloGradient)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.task.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color(red: 0.14, green: 0.12, blue: 0.28))
                        .strikethrough(viewModel.task.isCompleted)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        Image(systemName: viewModel.task.isCompleted ? "bookmark.fill" : "bookmark.slash.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(
                                viewModel.task.isCompleted ? Self.mintGradient : Self.coralAccentGradient
                            )

                        Text(viewModel.task.isCompleted ? "Completed locally" : "Not completed")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(statusBadgeTextColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(statusBadgeFill)
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .strokeBorder(statusBadgeBorder, lineWidth: 1)
                            )
                    }
                }

                Spacer(minLength: 0)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: Color(red: 0.42, green: 0.35, blue: 0.65).opacity(0.14), radius: 18, y: 8)
                .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.65),
                            (viewModel.task.isCompleted ? Color.green : Color.blue).opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var identifierCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Identifier", systemImage: "number")
                .font(.caption.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.35, green: 0.35, blue: 0.95),
                            Color(red: 0.55, green: 0.25, blue: 0.85)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("\(viewModel.task.id)")
                .font(.title.monospacedDigit().weight(.semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.2, blue: 0.42),
                            Color(red: 0.32, green: 0.28, blue: 0.62)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .accessibilityIdentifier("task-detail-id")
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.72),
                            Color(red: 0.93, green: 0.92, blue: 1.0).opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(red: 0.38, green: 0.32, blue: 0.72).opacity(0.12), radius: 14, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color(red: 0.42, green: 0.35, blue: 0.94).opacity(0.22), lineWidth: 1)
        )
    }

    private var primaryButtonGradient: LinearGradient {
        viewModel.task.isCompleted
            ? Self.coralAccentGradient
            : LinearGradient(
                colors: [
                    Color(red: 0.42, green: 0.35, blue: 0.94),
                    Color(red: 0.22, green: 0.55, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }

    private var actionButton: some View {
        Button {
            viewModel.toggleCompletion()
        } label: {
            Group {
                if viewModel.state.isSaving {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                } else {
                    Label(
                        viewModel.task.isCompleted ? "Mark as not done" : "Mark as completed",
                        systemImage: viewModel.task.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill"
                    )
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
            }
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(primaryButtonGradient)
                    .shadow(color: Color(red: 0.32, green: 0.22, blue: 0.62).opacity(0.35), radius: 16, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.state.isSaving)
    }

    private var disclaimerCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title3)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.35, green: 0.45, blue: 0.92),
                            Color(red: 0.52, green: 0.28, blue: 0.72)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Completion changes are saved on this device only; the demo API does not persist edits.")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color(red: 0.28, green: 0.26, blue: 0.42))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.65), lineWidth: 1)
        )
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
