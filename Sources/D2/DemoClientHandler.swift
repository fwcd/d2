import SwiftDiscord

class DemoClientHandler: DiscordClientDelegate {
	func client(_ client: DiscordClient, didCreateMessage message: DiscordMessage) {
		print("Created message \(message.content)")
	}
}
