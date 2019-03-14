import SwiftDiscord

class D2ClientDelegate: DiscordClientDelegate {
	func client(_ client: DiscordClient, didConnect connected: Bool) {
		print("Connected!")
	}
}
