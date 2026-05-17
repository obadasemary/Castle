import SwiftUI
import Presentation

struct RootView: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        RootTabView(coordinator: environment.container.coordinator)
    }
}
