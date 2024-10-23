import D2MessageIO
import Utils

struct WhisperPostprocessor: MessagePostprocessor {
    func postprocess(message: Message, context: CommandContext) async throws -> Message {
        var message = message

        if let channelId = context.channel?.id,
           let config = context.whisperConfiguration,
           config.wrappedValue.enabledChannelIds.contains(channelId) {
            message.content.replace(#/(?<prefix>^|\n)(?<suffix>\S)/#) { "\($0.prefix)-# \($0.suffix)" }
        }

        return message
    }
}
