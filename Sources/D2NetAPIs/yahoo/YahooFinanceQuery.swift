import CodableCSV
import Foundation
import Utils

public struct YahooFinanceQuery {
    private let stock: String
    private let start: Date
    private let end: Date

    public init(stock: String, from start: Date, to end: Date) {
        self.stock = stock
        self.start = start
        self.end = end
    }

    public func perform() -> Promise<[YahooFinanceStockDataPoint], Error> {
        Promise.catching { try HTTPRequest(host: "query1.finance.yahoo.com", path: "/v7/finance/download/\(stock)") }
            .then { $0.runAsync() }
            .mapCatching { try CSVDecoder().decode([YahooFinanceStockDataPoint].self, from: $0) }
    }
}
