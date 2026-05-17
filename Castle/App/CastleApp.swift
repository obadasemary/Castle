import SwiftUI
import SwiftData
import Presentation

@main
struct CastleApp: App {
    @State private var environment = AppEnvironment.live()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .environment(\.subscriptionsViewModelFactory, environment.container)
                .environment(\.dashboardViewModelFactory, environment.container)
                .environment(\.analyticsViewModelFactory, environment.container)
                .environment(\.settingsViewModelFactory, environment.container)
                .modelContainer(environment.container.modelContainer)
        }
    }
}
