import SwiftUI
import Core
import Domain

public struct CustomSubscriptionForm: View {
    @Bindable private var viewModel: AddSubscriptionViewModel
    private let onSaved: @MainActor () -> Void

    public init(viewModel: AddSubscriptionViewModel, onSaved: @MainActor @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSaved = onSaved
    }

    private let currencyCodes = ["USD", "EUR", "GBP", "JPY", "INR", "CAD", "AUD"]
    private let billingCycles: [BillingCycle] = [.monthly, .annual]

    public var body: some View {
        Form {
            Section("Service") {
                TextField("Name", text: $viewModel.input.serviceName)
                Picker("Category", selection: $viewModel.input.category) {
                    ForEach(Domain.Category.allCases, id: \.self) { cat in
                        Text(cat.displayName).tag(cat)
                    }
                }
            }

            Section("Pricing") {
                priceField
                Picker("Currency", selection: $viewModel.input.currencyCode) {
                    ForEach(currencyCodes, id: \.self) { code in
                        Text(code).tag(code)
                    }
                }
                Picker("Billing cycle", selection: $viewModel.input.billingCycle) {
                    ForEach(billingCycles, id: \.self) { cycle in
                        Text(label(for: cycle)).tag(cycle)
                    }
                }
                DatePicker(
                    "Next billing",
                    selection: $viewModel.input.nextBillingDate,
                    displayedComponents: .date
                )
            }

            Section("Reminder") {
                Toggle("Notify before billing", isOn: reminderEnabledBinding)
                if viewModel.input.reminderOffset != nil {
                    Stepper(
                        value: leadDaysBinding,
                        in: 1...30
                    ) {
                        let days = viewModel.input.reminderOffset ?? 1
                        Text("\(days) day\(days == 1 ? "" : "s") before")
                    }
                }
            }

            if !viewModel.validationErrors.isEmpty {
                Section("Fix the following") {
                    ForEach(viewModel.validationErrors, id: \.self) { error in
                        Label(message(for: error), systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.castleStatusExpiring)
                    }
                }
            }

            if let saveError = viewModel.saveErrorMessage {
                Section {
                    Text(saveError)
                        .font(CastleFont.caption)
                        .foregroundStyle(Color.castleStatusExpiring)
                }
            }
        }
        .navigationTitle(viewModel.input.serviceName.isEmpty ? "New Subscription" : viewModel.input.serviceName)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        if await viewModel.save() {
                            onSaved()
                        }
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
    }

    @ViewBuilder
    private var priceField: some View {
        #if os(iOS)
        TextField(
            "Price",
            value: $viewModel.input.price,
            format: .number.precision(.fractionLength(2))
        )
        .keyboardType(.decimalPad)
        #else
        TextField(
            "Price",
            value: $viewModel.input.price,
            format: .number.precision(.fractionLength(2))
        )
        #endif
    }

    private var reminderEnabledBinding: Binding<Bool> {
        Binding(
            get: { viewModel.input.reminderOffset != nil },
            set: { newValue in
                viewModel.input.reminderOffset = newValue ? 1 : nil
            }
        )
    }

    private var leadDaysBinding: Binding<Int> {
        Binding(
            get: { viewModel.input.reminderOffset ?? 1 },
            set: { newValue in
                viewModel.input.reminderOffset = newValue
            }
        )
    }

    private func label(for cycle: BillingCycle) -> String {
        switch cycle {
        case .monthly: "Monthly"
        case .annual: "Annual"
        case .custom(let days): "Every \(days)d"
        }
    }

    private func message(for error: ValidationError) -> String {
        switch error {
        case .emptyServiceName: "Service name is required."
        case .nonPositivePrice: "Price must be greater than zero."
        case .invalidCurrencyCode: "Currency code must be three letters."
        case .pastBillingDate: "Next billing must be in the future."
        }
    }
}
