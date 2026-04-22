import Foundation
import SwiftData

actor CacheService {
    static let shared = CacheService()

    private let cacheDuration: TimeInterval = 30 * 60

    private init() {}

    func cacheRates(base: String, rates: [String: Double], source: String, context: ModelContext) async {
        let descriptor = FetchDescriptor<CachedExchangeRate>(
            predicate: #Predicate { $0.baseCurrency == base }
        )
        if let existing = try? context.fetch(descriptor) {
            for item in existing { context.delete(item) }
        }

        if let ratesData = try? JSONEncoder().encode(rates) {
            let cached = CachedExchangeRate(
                baseCurrency: base,
                rates: ratesData,
                fetchDate: Date(),
                apiSource: source
            )
            context.insert(cached)
            try? context.save()
        }
    }

    func getCachedRates(base: String, context: ModelContext) -> (rates: [String: Double], date: Date, source: String)? {
        let descriptor = FetchDescriptor<CachedExchangeRate>(
            predicate: #Predicate { $0.baseCurrency == base }
        )

        guard let cached = try? context.fetch(descriptor).first else { return nil }

        let elapsed = Date().timeIntervalSince(cached.fetchDate)
        if elapsed > cacheDuration * 48 {
            return nil
        }

        guard let rates = try? JSONDecoder().decode([String: Double].self, from: cached.rates) else {
            return nil
        }

        return (rates, cached.fetchDate, cached.apiSource)
    }

    func isCacheValid(base: String, context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<CachedExchangeRate>(
            predicate: #Predicate { $0.baseCurrency == base }
        )

        guard let cached = try? context.fetch(descriptor).first else { return false }
        let elapsed = Date().timeIntervalSince(cached.fetchDate)
        return elapsed < cacheDuration
    }
}
