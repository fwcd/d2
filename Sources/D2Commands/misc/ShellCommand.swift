public class ShellCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Runs a shell command",
        requiredPermissionLevel: .admin
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let out = try Shell().outputSync(for: input).trimmingCharacters(in: .whitespacesAndNewlines)
        if !out.isEmpty {
            output.append(.code(out, language: nil))
        }
    }
}
