import Sword

class D2ClientHandler {
	func on(createMessage message: Message) {
		print("Created message \(message.content)")
	}
}
