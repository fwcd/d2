import Utils
import Logging
import D2NetAPIs

private let log = Logger(label: "D2Commands.CurrencyConversion")

@CommandActor
public struct CurrencyConversion: AsyncBijection {
    private static var exchangeRates = AsyncLazyExpiring(in: 240.0 /* seconds */) {
        try await ExchangeApiQuery().perform()
    }

    private let source: String
    private let dest: String
    private var exchangeRate: Double {
        get async {
            do {
                guard let destRate = try await Self.exchangeRates.wrappedValue.rates[dest.lowercased()] else {
                    throw CurrencyConversionError.missingRate(dest)
                }
                guard let sourceRate = try await Self.exchangeRates.wrappedValue.rates[source.lowercased()] else {
                    throw CurrencyConversionError.missingRate(source)
                }
                return destRate / sourceRate
            } catch {
                log.warning("Could not fetch exchange rates: \(error)")
                return .nan
            }
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
