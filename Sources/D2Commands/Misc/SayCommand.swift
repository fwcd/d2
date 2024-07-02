import D2MessageIO

public class SayCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Says something",
        longDescription: "Sends a Text-to-Speech message",
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            try await context.channel?.send(Message(content: input, tts: true))
        } catch {
            await output.append(error, errorText: "Could not say anything")
        }
    }
}
