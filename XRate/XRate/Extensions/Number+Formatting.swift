import Foundation

extension NumberFormatter {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4
        return formatter
    }()

    static let inputFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

extension Double {
    var formattedRate: String {
        NumberFormatter.currencyFormatter.string(from: NSNumber(value: self)) ?? "0"
    }

    var formattedAmount: String {
        NumberFormatter.inputFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

extension String {
    var numericValue: Double? {
        let cleanValue = replacingOccurrences(of: ",", with: "")
        return Double(cleanValue)
    }
}
