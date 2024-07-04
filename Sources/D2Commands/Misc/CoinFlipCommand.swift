public class CoinFlipCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Flips a coin",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let result = Bool.random()
        return await output.append(result ? "Heads!" : "Tails!")
    }
}
