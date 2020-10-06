import Utils
import D2NetAPIs

public struct CurrencyConversion: Bijection {
    @Expiring(in: 240.0 /* seconds */) private static var exchangeRates = try? ExchangeRatesQuery().perform().wait()

    private let source: String
    private let dest: String
    private var exchangeRate: Double { (Self.exchangeRates?.rates[dest] ?? 1) / (Self.exchangeRates?.rates[source] ?? 1) }

    public init(from source: String = "EUR", to dest: String) {
        self.source = source
        self.dest = dest
    }

    public func apply(_ value: Double) -> Double {
        value * exchangeRate
    }

    public func inverseApply(_ value: Double) -> Double {
        value / exchangeRate
    }
}
