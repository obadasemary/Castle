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
                .modelContainer(environment.container.modelContainer)
        }
    }
}
