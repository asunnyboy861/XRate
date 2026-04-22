import Foundation
import Observation

enum TimeRange: String, CaseIterable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case oneYear = "1Y"

    var days: Int {
        switch self {
        case .oneDay: return 1
        case .oneWeek: return 7
        case .oneMonth: return 30
        case .threeMonths: return 90
        case .oneYear: return 365
        }
    }

    var fromDate: Date {
        Date.daysAgo(days)
    }
}

@Observable
final class TrendViewModel {
    var trendData: [TrendDataPoint] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedRange: TimeRange = .oneWeek

    var highRate: Double? {
        trendData.map(\.rate).max()
    }

    var lowRate: Double? {
        trendData.map(\.rate).min()
    }

    var currentRate: Double? {
        trendData.last?.rate
    }

    var previousRate: Double? {
        guard trendData.count >= 2 else { return nil }
        return trendData[trendData.count - 2].rate
    }

    var dailyChange: Double? {
        guard let current = currentRate, let previous = previousRate else { return nil }
        return ((current - previous) / previous) * 100
    }

    func loadTrendData(base: String, quote: String, range: TimeRange) async {
        isLoading = true
        defer { isLoading = false }
        selectedRange = range

        do {
            let data = try await ExchangeRateService.shared.fetchTimeSeries(
                base: base,
                quote: quote,
                from: range.fromDate,
                to: Date()
            )
            trendData = data
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
