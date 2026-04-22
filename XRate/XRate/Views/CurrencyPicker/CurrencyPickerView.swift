import SwiftUI

struct CurrencyPickerView: View {
    let isPickingSource: Bool
    let selectedCurrency: Currency
    let allCurrencies: [Currency]
    let onSelect: (Currency) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var recentCurrencyCodes: [String] = []

    var filteredCurrencies: [Currency] {
        guard !searchText.isEmpty else { return allCurrencies }
        let query = searchText.lowercased()
        return allCurrencies.filter {
            $0.code.lowercased().contains(query) ||
            $0.name.lowercased().contains(query) ||
            $0.continent.lowercased().contains(query)
        }
    }

    var groupedCurrencies: [(String, [Currency])] {
        Dictionary(grouping: filteredCurrencies, by: \.continent)
            .sorted { $0.key < $1.key }
    }

    var popularCurrencies: [Currency] {
        allCurrencies.filter(\.isPopular)
    }

    var recentCurrencies: [Currency] {
        recentCurrencyCodes.compactMap { code in
            allCurrencies.first { $0.code == code }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty && !recentCurrencies.isEmpty {
                    Section("Recent") {
                        ForEach(recentCurrencies) { currency in
                            currencyRow(currency)
                        }
                    }
                }

                if searchText.isEmpty {
                    Section("Popular") {
                        ForEach(popularCurrencies) { currency in
                            currencyRow(currency)
                        }
                    }
                }

                ForEach(groupedCurrencies, id: \.0) { continent, currencies in
                    Section(continent) {
                        ForEach(currencies) { currency in
                            currencyRow(currency)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search currency or country")
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            recentCurrencyCodes = UserDefaults.standard.stringArray(forKey: "recentCurrencyCodes") ?? []
        }
    }

    @ViewBuilder
    private func currencyRow(_ currency: Currency) -> some View {
        Button {
            addToRecent(currency.code)
            onSelect(currency)
            dismiss()
        } label: {
            HStack(spacing: 12) {
                Text(currency.flagEmoji)
                    .font(.system(size: 32))
                VStack(alignment: .leading) {
                    Text(currency.code)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Text(currency.name)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if currency.code == selectedCurrency.code {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    private func addToRecent(_ code: String) {
        recentCurrencyCodes.removeAll { $0 == code }
        recentCurrencyCodes.insert(code, at: 0)
        if recentCurrencyCodes.count > 5 {
            recentCurrencyCodes = Array(recentCurrencyCodes.prefix(5))
        }
        UserDefaults.standard.set(recentCurrencyCodes, forKey: "recentCurrencyCodes")
    }
}
