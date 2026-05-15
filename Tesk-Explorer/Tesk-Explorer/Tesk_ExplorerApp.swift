//
//  Tesk_ExplorerApp.swift
//  Task Explorer entry point — composition root resolves dependencies once per process.
//

import SwiftUI

@main
struct Tesk_ExplorerApp: App {
    @StateObject private var rootEnvironment = RootEnvironmentBootstrap()

    var body: some Scene {
        WindowGroup {
            TaskExplorerRootView(environment: rootEnvironment.environment)
        }
    }
}

/// Holds the live `TaskExplorerEnvironment` behind `ObservableObject` so `@StateObject` can own one instance for the app's lifetime.
@MainActor
private final class RootEnvironmentBootstrap: ObservableObject {
    let environment: TaskExplorerEnvironment

    init() {
        environment = TaskExplorerComposition.production()
    }
}
