import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Handlers.DemoDelegate")

public class DemoDelegate: MessageDelegate {
    public func on(createMessage message: Message, client: any MessageClient) {
        log.info("Created message \(message.content)")
    }
}
