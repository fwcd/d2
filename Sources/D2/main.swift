import Commander
import Dispatch
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
	
	let runner = DispatchQueue(label: "IO backend", attributes: .concurrent)
	var launchedAnyBackend = false
	
	if let discordToken = tokens.discord {
		log.info("Launching Discord backend")
		launchedAnyBackend = true
		runner.async { runDiscordIOBackend(with: handler, token: discordToken) }
	}
	
	if !launchedAnyBackend {
		log.notice("No backend was launched since no tokens were provided. The application will thus now quit.")
	}
}

command(
	Option("level", default: "info", flag: "l", description: "The global logging level"),
	Option("initialPresence", default: nil, description: "The initial activity message"),
	main
).run()
