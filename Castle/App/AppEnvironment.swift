import Foundation
import Observation

@Observable
@MainActor
final class AppEnvironment {
    enum BuildFlavour: String {
        case debug, release
    }

    let buildFlavour: BuildFlavour
    let bundleIdentifier: String
    let container: AppDependencyContainer

    init(buildFlavour: BuildFlavour, bundleIdentifier: String, container: AppDependencyContainer) {
        self.buildFlavour = buildFlavour
        self.bundleIdentifier = bundleIdentifier
        self.container = container
    }

    static func live() -> AppEnvironment {
        #if DEBUG
        let flavour: BuildFlavour = .debug
        #else
        let flavour: BuildFlavour = .release
        #endif
        return AppEnvironment(
            buildFlavour: flavour,
            bundleIdentifier: Bundle.main.bundleIdentifier ?? "com.SamuraiStudios.Castle",
            container: AppDependencyContainer.live()
        )
    }
}
