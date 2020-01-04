import SwiftDiscord
import Logging

fileprivate let log = Logger(label: "DemoClientHandler")

class DemoClientHandler: DiscordClientDelegate {
	func client(_ client: DiscordClient, didCreateMessage message: DiscordMessage) {
		log.info("Created message \(message.content)")
	}
}
