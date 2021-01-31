import Foundation
import D2NetAPIs
import D2MessageIO

public class StockCommand: StringCommand {
    public let info = CommandInfo(
        category: .finance,
        shortDescription: "Plots the price of a stock",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please mention a stock name!")
            return
        }

        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -30, to: end)!
        YahooFinanceQuery(stock: input.uppercased(), from: start, to: end).perform().listen {
            do {
                let values = try $0.get()
                output.append(.table(Array(values.map { [$0.date, "\($0.high)", "\($0.low)", "\($0.close)"] }.prefix(10))))
            } catch {
                output.append(error, errorText: "Could not query stock")
            }
        }
    }
}
