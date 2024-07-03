import Utils
import D2NetAPIs

public struct CurrencyConversion: AsyncBijection {
    private static var exchangeRates = AsyncLazyExpiring(in: 240.0 /* seconds */) {
        try await ExchangeRatesQuery().perform()
    }

    private let source: String
    private let dest: String
    private var exchangeRate: Double {
        get async {
            await ((try? Self.exchangeRates.wrappedValue.rates[dest]) ?? 1) / ((try? Self.exchangeRates.wrappedValue.rates[source]) ?? 1)
        }
    }

    public init(from source: String = "EUR", to dest: String) {
        self.source = source
        self.dest = dest
    }

    public func apply(_ value: Double) async -> Double {
        await value * exchangeRate
    }

    public func inverseApply(_ value: Double) async -> Double {
        await value / exchangeRate
    }
}
