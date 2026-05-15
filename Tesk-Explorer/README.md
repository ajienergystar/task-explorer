## Task Explorer (iOS)

Take-home submission: SwiftUI application that pulls todos from [`jsonplaceholder.typicode.com/todos`](https://jsonplaceholder.typicode.com/todos), renders a list/detail flow, persists completion toggles locally, and separates networking/business/UI concerns for testability.

### Setup

- Open `Tesk-Explorer.xcodeproj` in Xcode 16+.  
- Scheme: **Tesk-Explorer**, destination: **iPhone simulator**.  
- Requires network access on first fetch (JSONPlaceholder HTTPS).

### Architecture

- **Domain** — Model `TaskItem` used across navigation and repositories.  
- **Data** — `TodoDTO` + `TodoRemoteDataSource` (decode + HTTP status handling) plus `DefaultTaskRepository` merges API payloads with persisted overrides from `TaskCompletionStoring`.  
- **Core** — `HTTPClienting` wraps `URLSession` for mocking; persistence uses `UserDefaults` behind a mutex-backed implementation.  
- **Presentation** — Patterns aligned with the BankDKI/Vello sample: `@MainActor` ViewModels adopting `ObservableObject`, nested `ViewState` structs, feature folder slices, lightweight composition (`TaskExplorerComposition` / `TaskExplorerEnvironment`) instead of a third-party DI container.

Persistence stores per-task booleans keyed by todo `id`; remote `completed` is used until the user edits completion locally—which matches JSONPlaceholder semantics (writes are not persisted remotely).

Unit tests (`TaskExplorerUnitTests`) exercise mocked HTTP decoding/errors and mocked repository flows for `TaskListViewModel`.

### Trade-offs & assumptions

- JSONPlaceholder ignores mutations; UX copy clarifies offline-only edits.  
- Full reload on pull-to-refresh / toolbar reload is acceptable for demo scale (~200 todos). Pagination could slide in behind the same repository boundary.  
- Product name typo `Tesk-Explorer` is kept to avoid churn on bundle identifiers tied to the existing Xcode target.  
- Targets are **iOS only** (iPhone / iPad / simulator); macOS & visionOS were removed from Xcode supported platforms.

### AI Usage Report

- **Tools** — Cursor agent (LLM-assisted coding assistant).  
- **Assisted tasks** — Turning PDF requirements into module boundaries and SwiftUI flow, scaffolding networking/persistence/protocols, unit tests against mocked collaborators, iterating on concurrency diagnostics.  
- **Manual decisions** — Folder layering echoing referenced BankDKI conventions, persistence strategy (local overrides map), UX for loading/error/refresh parity, deliberately avoiding extra SPM dependencies so the Xcode project stays self-contained.  
- **Limitations / corrections** — An initial actor-backed storage tripped Swift 6 `Sendable` warnings across previews/tests; reworked persistence to mutex-backed synchronous accessors. Verified with `xcodebuild` simulator tests locally.
