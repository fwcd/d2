import Commander
import Foundation
import Logging
import SwiftDiscord
import D2Handlers
import D2DiscordIO
import D2Utils

func main(rawLogLevel: String, initialPresence: String?) throws {
	let logLevel = Logger.Level(rawValue: rawLogLevel) ?? .info
	LoggingSystem.bootstrap { D2LogHandler(label: $0, logLevel: logLevel) }

	let log = Logger(label: "main")
	let config = try? DiskJsonSerializer().readJson(as: Config.self, fromFile: "local/config.json")
	let handler = try D2ClientHandler(withPrefix: config?.commandPrefix ?? "%", initialPresence: initialPresence)
	let token = try DiskJsonSerializer().readJson(as: Token.self, fromFile: "local/discordToken.json").token
	let delegate = MessageIOClientDelegate(inner: handler) // Needs to be declared separately since DiscordClient only holds a weak reference to it
	let discordClient = DiscordClient(token: DiscordToken(stringLiteral: "Bot \(token)"), delegate: delegate, configuration: [])
	
	log.info("Connecting client")
	discordClient.connect()
	RunLoop.current.run()
}

command(
	Option("level", default: "info", flag: "l", description: "The global logging level"),
	Option("initialPresence", default: nil, description: "The initial activity message"),
	main
).run()
