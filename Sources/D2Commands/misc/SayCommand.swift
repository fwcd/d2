import D2MessageIO

public class SayCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Says something",
        longDescription: "Sends a Text-to-Speech message",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        context.channel?.send(Message(content: input, tts: true))
    }
}
