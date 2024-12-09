public class BubblewrapCommand: VoidCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Some bubble wrap for you",
        requiredPermissionLevel: .basic
    )

    private let bubbles: Int

    public init(bubbles: Int = 128) {
        self.bubbles = bubbles
    }

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        await output.append(Array(repeating: "||pop!||", count: bubbles).joined(separator: " "))
    }
}
