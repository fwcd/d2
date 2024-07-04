import D2MessageIO

public class CleanMentionsCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Removes mentions from a message",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        await output.append(input.cleaningMentions(with: context.guild))
    }
}
