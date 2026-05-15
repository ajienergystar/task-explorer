// © 2026 Created by Aji Prakosa. All rights reserved.

@testable import Task_Explorer
import Testing
import Foundation

@Suite("Networking")
struct TodoRemoteDataSourceTests {
    @Test
    func decodeSuccess() async throws {
        let payload = """
        [
          {"userId":1,"id":1,"title":"delectus","completed":false}
        ]
        """.data(using: .utf8)!

        let client = ScriptedHTTPClient { _ in (payload, Self.http200(for: Self.sampleURL())) }
        let sut = TodoRemoteDataSource(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!, http: client)

        let todos = try await sut.fetchTodos()
        #expect(todos.count == 1)
        #expect(todos[0].id == 1)
        #expect(todos[0].title == "delectus")
        #expect(todos[0].completed == false)
    }

    @Test
    func httpErrorPropagatesInvalidResponse() async throws {
        let client = ScriptedHTTPClient { _ in (Data(), Self.http401()) }
        let sut = TodoRemoteDataSource(http: client)

        await #expect(throws: NetworkingError.invalidResponse(statusCode: 401)) {
            try await sut.fetchTodos()
        }
    }

    @Test
    func malformedJSONThrowsDecodingFailure() async throws {
        let client = ScriptedHTTPClient { _ in (#"{"broken":}"#.data(using: .utf8)!, Self.http200(for: Self.sampleURL())) }
        let sut = TodoRemoteDataSource(http: client)

        await #expect(throws: NetworkingError.self) {
            try await sut.fetchTodos()
        }
    }

    private struct ScriptedHTTPClient: HTTPClienting {
        let onRequest: @Sendable (URLRequest) async throws -> (Data, URLResponse)

        init(onRequest: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)) {
            self.onRequest = onRequest
        }

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            try await onRequest(request)
        }
    }

    private static func http200(for url: URL) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private static func http401() -> HTTPURLResponse {
        HTTPURLResponse(url: sampleURL(), statusCode: 401, httpVersion: nil, headerFields: nil)!
    }

    private static func sampleURL() -> URL {
        URL(string: "https://jsonplaceholder.typicode.com/todos")!
    }
}

@Suite("TaskListViewModel") @MainActor
struct TaskListViewModelTests {
    @Test
    func reloadFetchesTasksAndClearsPreviousErrorState() async {
        let repo = ScriptedTaskRepository()
        repo.stubTasks = [TaskItem(id: 7, title: "Alpha", isCompleted: true)]
        let vm = TaskListViewModel(repository: repo)

        await vm.reload()

        #expect(vm.tasks.count == 1)
        #expect(vm.tasks[0].id == 7)
        #expect(vm.state.errorMessage == nil)
        #expect(vm.state.isLoading == false)
    }

    @Test
    func reloadKeepsStaleContentWhenRefreshingFailsWithoutRetryFlag() async {
        let repo = ScriptedTaskRepository()
        repo.stubTasks = [TaskItem(id: 1, title: "Keep", isCompleted: false)]

        let vm = TaskListViewModel(repository: repo)
        await vm.reload()

        repo.stubTasks = []
        repo.nextFetchError = NetworkingError.invalidResponse(statusCode: 500)

        await vm.reload()

        #expect(vm.tasks.count == 1)
        #expect(vm.tasks[0].title == "Keep")
        #expect(vm.state.errorMessage != nil)
    }

    @Test
    func swipeTogglePersistsLocally() async {
        let repo = ScriptedTaskRepository()
        repo.stubTasks = [TaskItem(id: 2, title: "Next", isCompleted: false)]

        let vm = TaskListViewModel(repository: repo)
        await vm.reload()

        await vm.toggleCompletion(for: 2)

        #expect(vm.tasks[0].isCompleted == true)
        #expect(repo.persistedCompletions.contains { $0.id == 2 && $0.completed == true })
    }
}

private final class ScriptedTaskRepository: TaskRepositorying, @unchecked Sendable {
    var stubTasks: [TaskItem] = []
    var nextFetchError: Error?
    private(set) var persistedCompletions: [(id: Int, completed: Bool)] = []

    func fetchTasks() async throws -> [TaskItem] {
        if let nextFetchError {
            throw nextFetchError
        }
        return stubTasks
    }

    func setLocallyCompleted(_ completed: Bool, forTaskId id: Int) async {
        persistedCompletions.append((id, completed))
        if let idx = stubTasks.firstIndex(where: { $0.id == id }) {
            stubTasks[idx].isCompleted = completed
        }
    }
}
