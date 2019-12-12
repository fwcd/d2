import D2MessageIO

class DemoClientHandler: DiscordClientDelegate {
	func client(_ client: DiscordClient, didCreateMessage message: Message) {
		print("Created message \(message.content)")
	}
}
