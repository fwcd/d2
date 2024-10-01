import Utils

public class BuzzwordBingoCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Generates a buzzword bingo matrix",
        requiredPermissionLevel: .basic
    )

    public let outputValueType: RichValueType = .components

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        await output.append(.components([.actionRow(.init(components: [
            .button(.init(customId: "a", label: "A")),
            .button(.init(customId: "b", label: "B")),
        ]))]))
    }
}
