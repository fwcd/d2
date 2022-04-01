public class CoinFlipCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Flips a coin",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        let result = Bool.random()
        output.append(result ? "Heads!" : "Tails!")
    }
}
