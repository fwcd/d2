public class PrimeFactorizationCommand: StringCommand {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Finds the prime factorization of a number",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        
    }
}
