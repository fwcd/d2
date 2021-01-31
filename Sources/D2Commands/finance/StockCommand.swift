public class StockCommand: StringCommand {
    public let info = CommandInfo(
        category: .finance,
        shortDescription: "Plots the price of a stock",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
}
