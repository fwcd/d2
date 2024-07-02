import D2Permissions

public class TriggerTypingCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Begins to type",
        longDescription: "Triggers the channel's typing indicator",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .none
    public let outputValueType: RichValueType = .none

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        do {
            try await context.channel?.triggerTyping()
        } catch {
            await output.append(error, errorText: "Could not trigger typing indicator")
        }
    }
}
