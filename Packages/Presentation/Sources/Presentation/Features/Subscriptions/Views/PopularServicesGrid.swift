import SwiftUI
import Domain

public struct PopularServicesGrid: View {
    private let services: [PopularService]
    private let onSelect: @MainActor (PopularService) -> Void

    public init(
        services: [PopularService],
        onSelect: @MainActor @escaping (PopularService) -> Void
    ) {
        self.services = services
        self.onSelect = onSelect
    }

    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 110), spacing: Spacing.md)
    ]

    public var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(services) { service in
                Button {
                    onSelect(service)
                } label: {
                    ServiceCell(service: service)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
