import Foundation
import Observation

@Observable
final class CurrencyListViewModel {
    var searchText: String = ""
    var allCurrencies: [Currency] = []
    var recentCurrencyCodes: [String] = []

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

    func addToRecent(_ code: String) {
        recentCurrencyCodes.removeAll { $0 == code }
        recentCurrencyCodes.insert(code, at: 0)
        if recentCurrencyCodes.count > 5 {
            recentCurrencyCodes = Array(recentCurrencyCodes.prefix(5))
        }
        UserDefaults.standard.set(recentCurrencyCodes, forKey: "recentCurrencyCodes")
    }

    func loadRecentCurrencies() {
        recentCurrencyCodes = UserDefaults.standard.stringArray(forKey: "recentCurrencyCodes") ?? []
    }
}
