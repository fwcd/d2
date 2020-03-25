public class IOBackendCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Outputs the IO backend",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        output.append("You are talking with me via `\(context.client?.name ?? "?")`.")
    }
}
