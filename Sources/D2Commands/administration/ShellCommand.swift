import Utils

public class ShellCommand: StringCommand {
    public let info = CommandInfo(
        category: .administration,
        shortDescription: "Runs a shell command",
        helpText: "Syntax: [executable] [args]?",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        do {
            let out = try Shell().utf8Sync(for: input, useBash: true)?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "no output"
            output.append(.code(out, language: nil))
        } catch {
            output.append(error, errorText: "Could not invoke command")
        }
    }
}
