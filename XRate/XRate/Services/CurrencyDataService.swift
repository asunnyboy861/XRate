import Foundation

actor CurrencyDataService {
    static let shared = CurrencyDataService()

    private init() {}

    func loadCurrencies() -> [Currency] {
        guard let url = Bundle.main.url(forResource: "Currencies", withExtension: "json") else {
            return defaultCurrencies()
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([CurrencyJSON].self, from: data)
            return decoded.map { Currency(
                code: $0.code,
                name: $0.name,
                symbol: $0.symbol,
                flagEmoji: $0.flagEmoji,
                continent: $0.continent,
                isPopular: $0.isPopular
            )}
        } catch {
            return defaultCurrencies()
        }
    }

    private func defaultCurrencies() -> [Currency] {
        [
            Currency(code: "USD", name: "US Dollar", symbol: "$", flagEmoji: "🇺🇸", continent: "North America", isPopular: true),
            Currency(code: "EUR", name: "Euro", symbol: "€", flagEmoji: "🇪🇺", continent: "Europe", isPopular: true),
            Currency(code: "GBP", name: "British Pound", symbol: "£", flagEmoji: "🇬🇧", continent: "Europe", isPopular: true),
            Currency(code: "JPY", name: "Japanese Yen", symbol: "¥", flagEmoji: "🇯🇵", continent: "Asia", isPopular: true),
            Currency(code: "CAD", name: "Canadian Dollar", symbol: "CA$", flagEmoji: "🇨🇦", continent: "North America", isPopular: true),
            Currency(code: "AUD", name: "Australian Dollar", symbol: "A$", flagEmoji: "🇦🇺", continent: "Oceania", isPopular: true),
            Currency(code: "CHF", name: "Swiss Franc", symbol: "CHF", flagEmoji: "🇨🇭", continent: "Europe", isPopular: true),
            Currency(code: "CNY", name: "Chinese Yuan", symbol: "¥", flagEmoji: "🇨🇳", continent: "Asia", isPopular: true)
        ]
    }
}

struct CurrencyJSON: Codable {
    let code: String
    let name: String
    let symbol: String
    let flagEmoji: String
    let continent: String
    let isPopular: Bool
}
