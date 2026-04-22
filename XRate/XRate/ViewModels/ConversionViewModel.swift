import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
final class ConversionViewModel {
    var sourceCurrency: Currency
    var targetCurrency: Currency
    var sourceAmount: String = "1"
    var convertedAmount: String = ""
    var rates: [String: Double] = [:]
    var lastUpdated: Date?
    var isOffline: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    var quickAccessCurrencies: [Currency] = []
    var allCurrencies: [Currency] = []

    private let rateService = ExchangeRateService.shared
    private let cacheService = CacheService.shared
    private let currencyService = CurrencyDataService.shared

    init(sourceCurrency: Currency, targetCurrency: Currency) {
        self.sourceCurrency = sourceCurrency
        self.targetCurrency = targetCurrency
    }

    var convertedValue: Double {
        guard let amount = sourceAmount.numericValue,
              let rate = rates[targetCurrency.code] else {
            return 0
        }
        return amount * rate
    }

    var exchangeRate: Double? {
        rates[targetCurrency.code]
    }

    var rateDisplay: String {
        guard let rate = exchangeRate else { return "--" }
        return "1 \(sourceCurrency.code) = \(rate.formattedRate) \(targetCurrency.code)"
    }

    func loadCurrencies() {
        Task {
            let currencies = await currencyService.loadCurrencies()
            await MainActor.run {
                self.allCurrencies = currencies
                self.quickAccessCurrencies = currencies.filter(\.isPopular)
            }
        }
    }

    func loadRates(context: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        if let cached = await cacheService.getCachedRates(base: sourceCurrency.code, context: context) {
            rates = cached.rates
            lastUpdated = cached.date
            if await cacheService.isCacheValid(base: sourceCurrency.code, context: context) {
                isOffline = false
                updateConvertedAmount()
                Task {
                    await refreshRatesInBackground(context: context)
                }
                return
            }
        }

        do {
            let result = try await rateService.fetchLatestRates(base: sourceCurrency.code)
            rates = result.rates
            lastUpdated = result.date
            isOffline = result.source == "cache"
            await cacheService.cacheRates(base: sourceCurrency.code, rates: result.rates, source: result.source, context: context)
            updateConvertedAmount()
        } catch {
            isOffline = true
            errorMessage = error.localizedDescription
        }
    }

    private func refreshRatesInBackground(context: ModelContext) async {
        do {
            let result = try await rateService.fetchLatestRates(base: sourceCurrency.code)
            await MainActor.run {
                rates = result.rates
                lastUpdated = result.date
                isOffline = false
                updateConvertedAmount()
            }
            await cacheService.cacheRates(base: sourceCurrency.code, rates: result.rates, source: result.source, context: context)
        } catch {
            await MainActor.run {
                isOffline = true
            }
        }
    }

    func swapCurrencies() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            let temp = sourceCurrency
            sourceCurrency = targetCurrency
            targetCurrency = temp
            sourceAmount = convertedAmount
        }
    }

    func updateConvertedAmount() {
        let value = convertedValue
        convertedAmount = value.formattedRate
    }

    func selectQuickAccessCurrency(_ currency: Currency) {
        withAnimation {
            targetCurrency = currency
        }
    }
}
