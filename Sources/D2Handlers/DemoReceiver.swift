import D2MessageIO
import Logging

private let log = Logger(label: "D2Handlers.DemoReceiver")

public final class DemoReceiver: Receiver {
    public func on(createMessage message: Message, sink: any Sink) {
        log.info("Created message \(message.content)")
    }
}
