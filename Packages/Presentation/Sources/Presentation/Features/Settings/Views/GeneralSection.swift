import SwiftUI
import Domain

public struct GeneralSection: View {
    @Binding private var preferredCurrencyCode: String
    @Binding private var appearance: UserProfile.Appearance
    @Binding private var monthlyBudgetAmount: String

    public init(
        preferredCurrencyCode: Binding<String>,
        appearance: Binding<UserProfile.Appearance>,
        monthlyBudgetAmount: Binding<String>
    ) {
        _preferredCurrencyCode = preferredCurrencyCode
        _appearance = appearance
        _monthlyBudgetAmount = monthlyBudgetAmount
    }

    public var body: some View {
        Section("General") {
            Picker("Currency", selection: $preferredCurrencyCode) {
                ForEach(SettingsViewModel.supportedCurrencyCodes, id: \.self) { code in
                    Text(code).tag(code)
                }
            }
            Picker("Appearance", selection: $appearance) {
                ForEach(UserProfile.Appearance.allCases, id: \.self) { value in
                    Text(Self.label(for: value)).tag(value)
                }
            }
            HStack {
                Text("Monthly budget")
                Spacer()
                TextField("Optional", text: $monthlyBudgetAmount)
                    .multilineTextAlignment(.trailing)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                Text(preferredCurrencyCode)
                    .foregroundStyle(Color.castleTextSecondary)
            }
        }
    }

    private static func label(for value: UserProfile.Appearance) -> String {
        switch value {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}
