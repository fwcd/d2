public class MessageDatabaseCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Configures the local message database",
        requiredPermissionLevel: .admin
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
}
