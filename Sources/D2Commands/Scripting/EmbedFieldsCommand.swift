public class EmbedFieldsCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Extracts the fields from an embed as a table",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .embed
    public let outputValueType: RichValueType = .table

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        guard let embed = input.asEmbed else {
            output.append(errorText: "Please input an embed!")
            return
        }
        output.append(.table(embed.fields.map { [$0.name, $0.value] }))
    }
}
