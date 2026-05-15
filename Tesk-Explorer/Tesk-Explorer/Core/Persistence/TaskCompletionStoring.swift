// © 2026 Created by Aji Prakosa. All rights reserved.

import Foundation

protocol TaskCompletionStoring: Sendable {
    func persistedCompletion(forTaskId id: Int) -> Bool?

    func setPersistedCompletion(_ completed: Bool, forTaskId id: Int)
}

final class UserDefaultsTaskCompletionStore: TaskCompletionStoring, @unchecked Sendable {
    private enum Keys {
        static let completions = "taskExplorer.completionOverrides"
    }

    private let lock = NSLock()
    private let defaults: UserDefaults

    nonisolated init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    nonisolated func persistedCompletion(forTaskId id: Int) -> Bool? {
        lock.withLock {
            loadMapLocked()[String(id)]
        }
    }

    nonisolated func setPersistedCompletion(_ completed: Bool, forTaskId id: Int) {
        lock.withLock {
            var map = loadMapLocked()
            map[String(id)] = completed
            defaults.set(map, forKey: Keys.completions)
        }
    }

    private func loadMapLocked() -> [String: Bool] {
        defaults.dictionary(forKey: Keys.completions) as? [String: Bool] ?? [:]
    }
}

private extension NSLock {
    func withLock<R>(_ body: () -> R) -> R {
        lock()
        defer { unlock() }
        return body()
    }
}
