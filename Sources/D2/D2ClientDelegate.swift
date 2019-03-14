import SwiftDiscord

class D2ClientDelegate: DiscordClientDelegate {
	override fun client(_ client: DiscordClient, didConnect connected: Bool) {
		print("Connected!")
	}
}
