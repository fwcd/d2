import Foundation
import Logging
import SwiftDiscord
import D2Commands
import D2Utils

func main() throws {
	let logLevel = CommandLine.arguments[safely: 1].flatMap(Logger.Level.init(rawValue:)) ?? .info
	LoggingSystem.bootstrap { D2LogHandler(label: $0, logLevel: logLevel) }

	let log = Logger(label: "main")
	let args = CommandLine.arguments
	let config = try? DiskJsonSerializer().readJson(as: Config.self, fromFile: "local/config.json")
	let handler = try D2ClientHandler(withPrefix: config?.commandPrefix ?? "%", initialPresence: args[safely: 1])
	let token = try DiskJsonSerializer().readJson(as: Token.self, fromFile: "local/discordToken.json").token
	let client = DiscordClient(token: DiscordToken(stringLiteral: "Bot \(token)"), delegate: handler, configuration: [])
	
	log.info("Connecting client")
	client.connect()
	RunLoop.current.run()
}

try main()
