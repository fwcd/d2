public class WouldYouRatherCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Asks an either/or question",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
}
