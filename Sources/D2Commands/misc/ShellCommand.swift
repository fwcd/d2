public class ShellCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Runs a shell command",
        requiredPermissionLevel: .admin
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
}
