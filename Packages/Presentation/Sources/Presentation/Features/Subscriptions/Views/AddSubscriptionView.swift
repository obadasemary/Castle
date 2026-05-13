import SwiftUI
import Domain

public struct AddSubscriptionView: View {
    @State private var viewModel: AddSubscriptionViewModel
    private let onClose: @MainActor () -> Void
    @State private var path = NavigationPath()

    private enum Step: Hashable {
        case form
    }

    public init(viewModel: AddSubscriptionViewModel, onClose: @MainActor @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onClose = onClose
    }

    public var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    searchField

                    Button {
                        viewModel.selectCustom()
                        path.append(Step.form)
                    } label: {
                        Label("Add Custom Subscription", systemImage: "plus.circle.fill")
                            .font(CastleFont.bodyEmphasized)
                            .foregroundStyle(Color.castleAccentBrand)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(Color.castleSurfaceElevated, in: RoundedRectangle(cornerRadius: CornerRadius.lg))
                    }
                    .buttonStyle(.plain)

                    SectionHeader("Popular Services")

                    catalogContent
                }
                .padding(Spacing.lg)
            }
            .navigationTitle("Add Subscription")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onClose() }
                }
            }
            .navigationDestination(for: Step.self) { step in
                switch step {
                case .form:
                    CustomSubscriptionForm(viewModel: viewModel) {
                        onClose()
                    }
                }
            }
            .task { await viewModel.loadCatalog() }
        }
    }

    @ViewBuilder
    private var searchField: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.castleTextSecondary)
            TextField("Search services", text: queryBinding)
                .textInputAutocapitalizationIfNeeded()
        }
        .padding(Spacing.md)
        .background(Color.castleSurfaceElevated, in: Capsule())
    }

    @ViewBuilder
    private var catalogContent: some View {
        switch viewModel.catalogState {
        case .idle, .loading:
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding(.vertical, Spacing.xl)
        case .loaded(let services) where services.isEmpty:
            Text("No services match your search.")
                .font(CastleFont.body)
                .foregroundStyle(Color.castleTextSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, Spacing.xl)
        case .loaded(let services):
            PopularServicesGrid(services: services) { service in
                viewModel.selectPopular(service)
                path.append(Step.form)
            }
        case .error(let message):
            ErrorView(message: message) {
                Task { await viewModel.loadCatalog() }
            }
            .frame(minHeight: 240)
        }
    }

    private var queryBinding: Binding<String> {
        Binding(
            get: { viewModel.query },
            set: { newValue in
                Task { await viewModel.search(newValue) }
            }
        )
    }
}

private extension View {
    @ViewBuilder
    func textInputAutocapitalizationIfNeeded() -> some View {
        #if os(iOS)
        self.textInputAutocapitalization(.never)
        #else
        self
        #endif
    }
}
