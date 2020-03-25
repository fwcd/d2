import D2MessageIO
import Logging

fileprivate let log = Logger(label: "DemoClientHandler")

public class DemoClientHandler: MessageDelegate {
	public func on(createMessage message: Message, client: MessageClient) {
		log.info("Created message \(message.content)")
	}
}
