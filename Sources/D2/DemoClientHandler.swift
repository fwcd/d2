import D2MessageIO
import Logging

fileprivate let log = Logger(label: "DemoClientHandler")

class DemoClientHandler: MessageDelegate {
	func on(createMessage message: Message, client: MessageClient) {
		log.info("Created message \(message.content)")
	}
}
