import Foundation

struct TrendDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let rate: Double
}
