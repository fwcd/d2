import D2MessageIO

public class SayCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Says something",
        longDescription: "Sends a Text-to-Speech message",
        requiredPermissionLevel: .vip
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        context.channel?.send(Message(content: input, tts: true))
    }
}
