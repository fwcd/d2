public class IOPlatformCommand: StringCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Outputs the IO platform",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        output.append("You are talking with me via `\(context.client?.name ?? "?")`.")
    }
}
