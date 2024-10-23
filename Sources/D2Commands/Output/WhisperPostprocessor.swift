import D2MessageIO
import Utils

struct WhisperPostprocessor: MessagePostprocessor {
    @Binding var configuration: WhisperConfiguration

    init(@Binding configuration: WhisperConfiguration) {
        self._configuration = _configuration
    }

    func postprocess(message: Message) async throws -> Message {
        // TODO
        fatalError()
    }
}
