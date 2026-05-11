// ── FILE: Castle/App/RootView.swift ──
//
// Top-level navigation scaffold. PR 4 replaces the placeholder body with a
// TabView wiring Dashboard / Subscriptions / Analytics / Settings feature
// views via their respective routers. For PR 1 we just render proof-of-life
// text confirming every module is linked.

import SwiftUI
import Core
import Domain
import Data
import Presentation

struct RootView: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("Castle")
                .font(.largeTitle.bold())
            Text("Subscription tracker scaffold")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 4) {
                row("Core", CoreModule.identifier)
                row("Domain", DomainModule.identifier)
                row("Data", DataModule.identifier)
                row("Presentation", PresentationModule.identifier)
                row("Flavour", environment.buildFlavour.rawValue)
            }
            .font(.caption.monospaced())
            .padding(.top, 12)
        }
        .padding()
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    RootView()
        .environment(AppEnvironment(buildFlavour: .debug, bundleIdentifier: "com.SamuraiStudios.Castle"))
}
