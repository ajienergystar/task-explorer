// © 2026 Created by Aji Prakosa. All rights reserved.

import SwiftUI

@main
struct Task_ExplorerApp: App {
    @StateObject private var rootEnvironment = RootEnvironmentBootstrap()

    var body: some Scene {
        WindowGroup {
            TaskExplorerRootView(environment: rootEnvironment.environment)
        }
    }
}

@MainActor
private final class RootEnvironmentBootstrap: ObservableObject {
    let environment: TaskExplorerEnvironment

    init() {
        environment = TaskExplorerComposition.production()
    }
}
