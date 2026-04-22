import Foundation

enum APIError: LocalizedError {
    case networkUnavailable
    case invalidResponse
    case decodingFailed
    case allAPIsFailed

    var errorDescription: String? {
        switch self {
        case .networkUnavailable: return "No internet connection"
        case .invalidResponse: return "Invalid server response"
        case .decodingFailed: return "Failed to parse data"
        case .allAPIsFailed: return "All API sources unavailable"
        }
    }
}

struct FrankfurterResponse: Codable {
    let amount: Double
    let base: String
    let date: String
    let rates: [String: Double]
}

struct FrankfurterTimeSeriesResponse: Codable {
    let base: String
    let start_date: String
    let end_date: String
    let rates: [String: [String: Double]]
}

struct RateResult {
    let rates: [String: Double]
    let date: Date
    let source: String
}

actor ExchangeRateService {
    static let shared = ExchangeRateService()

    private let frankfurterBaseURL = "https://api.frankfurter.dev/v2"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    func fetchLatestRates(base: String) async throws -> RateResult {
        do {
            let result = try await fetchFromFrankfurter(base: base)
            return result
        } catch {
            do {
                let result = try await fetchFromExchangeRateAPI(base: base)
                return result
            } catch {
                throw APIError.allAPIsFailed
            }
        }
    }

    func fetchTimeSeries(base: String, quote: String,
                         from: Date, to: Date) async throws -> [TrendDataPoint] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var components = URLComponents(string: "\(frankfurterBaseURL)/rates")!
        components.queryItems = [
            URLQueryItem(name: "base", value: base),
            URLQueryItem(name: "quotes", value: quote),
            URLQueryItem(name: "from", value: dateFormatter.string(from: from)),
            URLQueryItem(name: "to", value: dateFormatter.string(from: to))
        ]

        let (data, response) = try await session.data(from: components.url!)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(FrankfurterTimeSeriesResponse.self, from: data)

        var result: [TrendDataPoint] = []
        for (dateString, rates) in decoded.rates.sorted(by: { $0.key < $1.key }) {
            if let rate = rates[quote], let date = dateFormatter.date(from: dateString) {
                result.append(TrendDataPoint(date: date, rate: rate))
            }
        }

        return result
    }

    private func fetchFromFrankfurter(base: String) async throws -> RateResult {
        var components = URLComponents(string: "\(frankfurterBaseURL)/rates")!
        components.queryItems = [
            URLQueryItem(name: "base", value: base)
        ]

        let (data, response) = try await session.data(from: components.url!)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(FrankfurterResponse.self, from: data)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: decoded.date) ?? Date()

        return RateResult(rates: decoded.rates, date: date, source: "frankfurter")
    }

    private func fetchFromExchangeRateAPI(base: String) async throws -> RateResult {
        let apiKey = "YOUR_EXCHANGERATE_API_KEY"
        let urlString = "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/\(base)"

        let (data, response) = try await session.data(from: URL(string: urlString)!)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        struct ExchangeRateAPIResponse: Codable {
            let conversion_rates: [String: Double]
            let time_last_update_unix: TimeInterval
        }

        let decoded = try JSONDecoder().decode(ExchangeRateAPIResponse.self, from: data)
        let date = Date(timeIntervalSince1970: decoded.time_last_update_unix)

        return RateResult(rates: decoded.conversion_rates, date: date, source: "exchangerate-api")
    }
}
