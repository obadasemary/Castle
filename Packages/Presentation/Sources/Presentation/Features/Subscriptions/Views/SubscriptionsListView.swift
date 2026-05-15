import SwiftUI
import Domain

public struct SubscriptionsListView: View {
    @State private var viewModel: SubscriptionsListViewModel
    private let coordinator: AppCoordinator
    private let factory: any SubscriptionsViewModelFactory

    public init(
        coordinator: AppCoordinator,
        factory: any SubscriptionsViewModelFactory
    ) {
        self.coordinator = coordinator
        self.factory = factory
        _viewModel = State(initialValue: factory.makeSubscriptionsListViewModel())
    }

    public var body: some View {
        @Bindable var coordinator = coordinator
        @Bindable var viewModel = viewModel
        NavigationStack(path: $coordinator.subscriptionsPath) {
            content
                .navigationTitle("Subscriptions")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            viewModel.presentAdd()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add subscription")
                    }
                }
                .navigationDestination(for: SubscriptionsRoute.self) { route in
                    switch route {
                    case .detail(let id):
                        SubscriptionDetailView(viewModel: factory.makeSubscriptionDetailViewModel(id: id))
                    }
                }
                .sheet(isPresented: $coordinator.isPresentingAddSubscription) {
                    AddSubscriptionView(
                        viewModel: factory.makeAddSubscriptionViewModel(),
                        onClose: { coordinator.isPresentingAddSubscription = false }
                    )
                }
                .onChange(of: coordinator.isPresentingAddSubscription) { _, isPresenting in
                    if !isPresenting { Task { await viewModel.load() } }
                }
                .task { await viewModel.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            Picker("Filter", selection: filterBinding) {
                ForEach(SubscriptionsListViewModel.Filter.allCases, id: \.self) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)

            switch viewModel.state {
            case .idle, .loading:
                LoadingView(message: "Loading subscriptions…")
            case .loaded(let subs) where subs.isEmpty:
                EmptyStateView(
                    symbolName: viewModel.filter == .active ? "creditcard.fill" : "archivebox.fill",
                    title: viewModel.filter == .active ? "No active subscriptions" : "Nothing archived",
                    message: viewModel.filter == .active
                        ? "Tap the plus button to add your first subscription."
                        : "Archived subscriptions will appear here.",
                    actionTitle: viewModel.filter == .active ? "Add subscription" : nil,
                    action: viewModel.filter == .active ? { viewModel.presentAdd() } : nil
                )
            case .loaded(let subs):
                List {
                    ForEach(subs) { subscription in
                        Button {
                            viewModel.showDetail(subscription.id)
                        } label: {
                            SubscriptionRow(subscription: subscription)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if subscription.status == .active {
                                Button(role: .destructive) {
                                    Task { await viewModel.archive(id: subscription.id) }
                                } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                            }
                            Button(role: .destructive) {
                                Task { await viewModel.delete(id: subscription.id) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            case .error(let message):
                ErrorView(message: message) {
                    Task { await viewModel.load() }
                }
            }
        }
    }

    private var filterBinding: Binding<SubscriptionsListViewModel.Filter> {
        Binding(
            get: { viewModel.filter },
            set: { newValue in
                Task { await viewModel.setFilter(newValue) }
            }
        )
    }
}
