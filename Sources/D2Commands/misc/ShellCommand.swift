import D2Utils

public class ShellCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Runs a shell command",
        helpText: "Syntax: [executable] [args]?",
        requiredPermissionLevel: .admin
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            let parsedInput = input.split(separator: " ").map { String($0) }
            guard let cmd = parsedInput.first else {
                output.append(errorText: info.helpText!)
                return
            }
            let args = parsedInput.dropFirst()
            let out = try Shell().outputSync(for: cmd, args: Array(args))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "no output"
            if !out.isEmpty {
                output.append(.code(out, language: nil))
            }
        } catch {
            output.append(error, errorText: "Could not invoke command")
        }
    }
}
