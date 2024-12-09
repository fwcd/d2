public class BubblewrapCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Some bubble wrap for you",
        helpText: "Syntax: [bubbles]?",
        requiredPermissionLevel: .basic
    )

    private let defaultBubbles: Int

    public init(defaultBubbles: Int = 128) {
        self.defaultBubbles = defaultBubbles
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let bubbles = Int(input) ?? defaultBubbles
        await output.append(Array(repeating: "||pop!||", count: bubbles).joined(separator: " "))
    }
}
