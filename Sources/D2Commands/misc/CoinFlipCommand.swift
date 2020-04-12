public class CoinFlipCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Flips a coin",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let result = Bool.random()
        output.append(result ? "Heads!" : "Tails!")
    }
}
