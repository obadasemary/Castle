import SwiftUI
import Core
import Domain

public struct SubscriptionDetailView: View {
    @State private var viewModel: SubscriptionDetailViewModel
    @State private var showArchiveConfirmation = false
    @State private var showDeleteConfirmation = false

    public init(viewModel: SubscriptionDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            switch viewModel.state {
            case .idle, .loading:
                LoadingView(message: "Loading subscription…")
                    .frame(minHeight: 320)
            case .notFound:
                EmptyStateView(
                    symbolName: "questionmark.folder",
                    title: "Subscription not found",
                    message: "It may have been deleted from another device."
                )
            case .error(let message):
                ErrorView(message: message) {
                    Task { await viewModel.load() }
                }
            case .loaded(let detail):
                loadedContent(detail)
            }
        }
        .navigationTitle(viewModel.subscription?.serviceName ?? "Subscription")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Archive", systemImage: "archivebox") {
                        showArchiveConfirmation = true
                    }
                    .disabled(viewModel.subscription?.status == .archived)
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("Subscription actions")
                .disabled(viewModel.subscription == nil)
            }
        }
        .confirmationDialog(
            "Archive this subscription?",
            isPresented: $showArchiveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Archive", role: .destructive) {
                Task { await viewModel.archive() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Archived subscriptions are hidden but their payment history is preserved.")
        }
        .confirmationDialog(
            "Delete this subscription?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task { await viewModel.delete() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove the subscription and its payment history.")
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private func loadedContent(_ detail: FetchSubscriptionDetailUseCase.Detail) -> some View {
        let subscription = detail.subscription
        VStack(alignment: .leading, spacing: Spacing.lg) {
            VStack(spacing: Spacing.md) {
                BrandIcon(
                    symbolName: subscription.iconSymbolName,
                    brandColorHex: subscription.brandColorHex,
                    size: .large
                )
                Text(subscription.serviceName)
                    .font(CastleFont.titleLarge)
                    .foregroundStyle(Color.castleTextPrimary)
                PriceTag(money: subscription.price, cadence: cadenceLabel(for: subscription.billingCycle), size: .large)
                StatusPill(subscription.status == .active ? .active : .archived)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.xl)
            .background(Color.castleSurfaceElevated, in: RoundedRectangle(cornerRadius: CornerRadius.xl))

            statusGrid(detail: detail)

            reminderSection

            PaymentHistoryList(payments: detail.paymentHistory)
                .padding(.horizontal, Spacing.lg)
        }
        .padding(.vertical, Spacing.lg)
    }

    @ViewBuilder
    private func statusGrid(detail: FetchSubscriptionDetailUseCase.Detail) -> some View {
        HStack(spacing: Spacing.md) {
            statusCard(
                title: "Next Billing",
                value: detail.subscription.nextBillingDate.formatted(date: .abbreviated, time: .omitted)
            )
            statusCard(
                title: "Days Left",
                value: "\(max(0, detail.daysUntilNextBilling))"
            )
        }
        .padding(.horizontal, Spacing.lg)
    }

    private func statusCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(CastleFont.caption)
                .foregroundStyle(Color.castleTextSecondary)
            Text(value)
                .font(CastleFont.title)
                .foregroundStyle(Color.castleTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.castleSurfaceElevated, in: RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader("Reminder")
            Toggle(isOn: reminderBinding) {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Billing reminder")
                        .font(CastleFont.bodyEmphasized)
                        .foregroundStyle(Color.castleTextPrimary)
                    Text("Notify the day before this subscription renews.")
                        .font(CastleFont.caption)
                        .foregroundStyle(Color.castleTextSecondary)
                }
            }
            .tint(Color.castleAccentBrand)
            .padding(Spacing.md)
            .background(Color.castleSurfaceElevated, in: RoundedRectangle(cornerRadius: CornerRadius.lg))
        }
        .padding(.horizontal, Spacing.lg)
    }

    private var reminderBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isReminderEnabled },
            set: { newValue in
                Task { await viewModel.toggleReminder(enabled: newValue) }
            }
        )
    }

    private func cadenceLabel(for cycle: BillingCycle) -> String {
        switch cycle {
        case .monthly: "/ month"
        case .annual: "/ year"
        case .custom(let days): "/ \(days)d"
        }
    }
}

