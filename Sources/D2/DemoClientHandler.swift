import Sword

class DemoClientHandler: ClientHandler {
	func on(createMessage message: Message) {
		print("Created message \(message.content)")
	}
}
