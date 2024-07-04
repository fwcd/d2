import Utils

public class ShellCommand: StringCommand {
    public let info = CommandInfo(
        category: .administration,
        shortDescription: "Runs a shell command",
        helpText: "Syntax: [executable] [args]?",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let out = try Shell().utf8Sync(for: input, useBash: true)?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "no output"
            await output.append(.code(out, language: nil))
        } catch {
            await output.append(error, errorText: "Could not invoke command")
        }
    }
}
