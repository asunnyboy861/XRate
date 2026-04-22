import Foundation
import SwiftData

@Model
final class Currency {
    @Attribute(.unique) var code: String
    var name: String
    var symbol: String
    var flagEmoji: String
    var continent: String
    var isPopular: Bool
    var lastUsedOrder: Int

    init(code: String, name: String, symbol: String,
         flagEmoji: String, continent: String,
         isPopular: Bool = false, lastUsedOrder: Int = 0) {
        self.code = code
        self.name = name
        self.symbol = symbol
        self.flagEmoji = flagEmoji
        self.continent = continent
        self.isPopular = isPopular
        self.lastUsedOrder = lastUsedOrder
    }
}
