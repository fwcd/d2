public class EmbedFieldsCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Extracts the footer text from an embed",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .embed
    public let outputValueType: RichValueType = .table

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let embed = input.asEmbed else {
            output.append(errorText: "Please input an embed!")
            return
        }
        output.append(.table(embed.fields.map { [$0.name, $0.value] }))
    }
}
