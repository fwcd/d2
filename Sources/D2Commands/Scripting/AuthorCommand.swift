public class AuthorCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Fetches the message's author",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        guard let author = context.author else {
            output.append(errorText: "No author available")
            return
        }
        output.append(.mentions([author]))
    }
}
