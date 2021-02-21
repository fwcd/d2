public class EmbedDescriptionCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Extracts the description from an embed",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .embed
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let embed = input.asEmbed else {
            output.append(errorText: "Please input an embed!")
            return
        }
        guard let description = embed.description else {
            output.append(errorText: "The embed has no description!")
            return
        }
        output.append(description)
    }
}
