public class EmbedFooterCommand: Command {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "Extracts the footer text from an embed",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .embed
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let embed = input.asEmbed else {
            await output.append(errorText: "Please input an embed!")
            return
        }
        guard let footerText = embed.footer?.text else {
            await output.append(errorText: "The embed has no description!")
            return
        }
        await output.append(footerText)
    }
}
