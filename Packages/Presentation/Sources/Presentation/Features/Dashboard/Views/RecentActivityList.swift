import SwiftUI
import Core
import Domain

public struct RecentActivityList: View {
    private let events: [ActivityEvent]
    private let onSelect: (UUID) -> Void
    private let formatter: CurrencyFormatter
    private let dateFormatter: DateFormatter

    public init(
        events: [ActivityEvent],
        onSelect: @escaping (UUID) -> Void,
        formatter: CurrencyFormatter = CurrencyFormatter()
    ) {
        self.events = events
        self.onSelect = onSelect
        self.formatter = formatter
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        self.dateFormatter = df
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Recent activity")
            if events.isEmpty {
                Text("Payment history will appear here as your subscriptions renew.")
                    .font(CastleFont.caption)
                    .foregroundStyle(Color.castleTextSecondary)
                    .padding(.vertical, Spacing.md)
            } else {
                VStack(spacing: 0) {
                    ForEach(events) { event in
                        Button {
                            onSelect(event.subscriptionID)
                        } label: {
                            row(event)
                        }
                        .buttonStyle(.plain)
                        if event.id != events.last?.id {
                            Divider().padding(.leading, Spacing.lg)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                        .fill(Color.castleSurfaceElevated)
                )
            }
        }
    }

    private func row(_ event: ActivityEvent) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: iconName(for: event.type))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.castleAccentBrand)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(event.subscriptionName)
                    .font(CastleFont.bodyEmphasized)
                    .foregroundStyle(Color.castleTextPrimary)
                Text(subtitle(for: event))
                    .font(CastleFont.caption)
                    .foregroundStyle(Color.castleTextSecondary)
            }
            Spacer()
            Text(dateFormatter.string(from: event.date))
                .font(CastleFont.caption)
                .foregroundStyle(Color.castleTextSecondary)
        }
        .padding(Spacing.md)
        .contentShape(Rectangle())
    }

    private func iconName(for type: ActivityEvent.EventType) -> String {
        switch type {
        case .paid: "creditcard.fill"
        case .added: "plus.circle.fill"
        case .archived: "archivebox.fill"
        case .priceChanged: "arrow.up.right.circle.fill"
        }
    }

    private func subtitle(for event: ActivityEvent) -> String {
        switch event.type {
        case .paid(let amount): "Paid \(formatter.string(from: amount))"
        case .added: "Added"
        case .archived: "Archived"
        case .priceChanged(let old, let new):
            "Price changed: \(formatter.string(from: old)) → \(formatter.string(from: new))"
        }
    }
}
