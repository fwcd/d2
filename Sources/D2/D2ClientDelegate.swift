import SwiftDiscord

class D2ClientDelegate: DiscordClientDelegate {
	override func client(_ client: DiscordClient, didConnect connected: Bool) {
		print("Connected!")
	}
}
