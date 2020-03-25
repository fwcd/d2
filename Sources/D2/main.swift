import Commander
import Logging
import D2Handlers
import D2DiscordIO
import D2Utils

func main(rawLogLevel: String, initialPresence: String?) throws {
	let logLevel = Logger.Level(rawValue: rawLogLevel) ?? .info
	LoggingSystem.bootstrap { D2LogHandler(label: $0, logLevel: logLevel) }

	let log = Logger(label: "main")
	let config = try? DiskJsonSerializer().readJson(as: Config.self, fromFile: "local/config.json")
	let handler = try D2Delegate(withPrefix: config?.commandPrefix ?? "%", initialPresence: initialPresence)
	let tokens = try DiskJsonSerializer().readJson(as: IOBackendTokens.self, fromFile: "local/ioBackendTokens.json")
	
	if let discordToken = tokens.discord {
		log.info("Launching Discord backend")
		runDiscordIOBackend(with: handler, token: discordToken)
	}
}

command(
	Option("level", default: "info", flag: "l", description: "The global logging level"),
	Option("initialPresence", default: nil, description: "The initial activity message"),
	main
).run()
