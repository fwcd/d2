import D2MessageIO
import Utils

struct WhisperPostprocessor: MessagePostprocessor {
    @Binding var configuration: WhisperConfiguration

    init(@Binding configuration: WhisperConfiguration) {
        self._configuration = _configuration
    }

    func postprocess(message: Message) async throws -> Message {
        var message = message

        if let channelId = message.channelId, configuration.enabledChannelIds.contains(channelId) {
            message.content.replace("\n", with: "\n-# ")
        }

        return message
    }
}
