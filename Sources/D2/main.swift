import Foundation
import SwiftDiscord

func main() throws {
	// 'discordToken' should be declared in 'authtoken.swift'
	let client = DiscordClient(token: DiscordToken(stringLiteral: "Bot \(discordToken)"), delegate: D2ClientDelegate(), configuration: [.log(.info)])
	client.connect()
}

try main()
