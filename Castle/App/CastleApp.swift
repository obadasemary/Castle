import SwiftUI
import SwiftData

@main
struct CastleApp: App {
    @State private var environment = AppEnvironment.live()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .modelContainer(environment.container.modelContainer)
        }
    }
}
