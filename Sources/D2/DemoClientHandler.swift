import D2MessageIO

class DemoClientHandler: MessageDelegate {
	func on(createMessage message: Message, client: MessageClient) {
		print("Created message \(message.content)")
	}
}
