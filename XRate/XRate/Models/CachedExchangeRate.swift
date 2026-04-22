import Foundation
import SwiftData

@Model
final class CachedExchangeRate {
    @Attribute(.unique) var baseCurrency: String
    var rates: Data
    var fetchDate: Date
    var apiSource: String

    init(baseCurrency: String, rates: Data, fetchDate: Date, apiSource: String) {
        self.baseCurrency = baseCurrency
        self.rates = rates
        self.fetchDate = fetchDate
        self.apiSource = apiSource
    }
}
