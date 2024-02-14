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

    public func perform() -> Promise<[YahooFinanceStockDataPoint], any Error> {
        Promise.catching { try HTTPRequest(host: "query1.finance.yahoo.com", path: "/v7/finance/download/\(stock)", query: [
            "period1": String(Int(start.timeIntervalSince1970)),
            "period2": String(Int(end.timeIntervalSince1970)),
            "interval": "1d",
            "events": "history",
            "includeAdjustedClose": "true"
        ]) }
            .then { $0.runAsync() }
            .mapCatching { try CSVDecoder {
                $0.encoding = .utf8
                $0.headerStrategy = .firstLine
            }.decode([YahooFinanceStockDataPoint].self, from: $0) }
    }
}
