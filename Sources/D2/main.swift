import Commander
import Dispatch
import Foundation
import Logging
import D2Handlers
import D2MessageIO
import D2DiscordIO
import D2TelegramIO
import D2Utils

#if DEBUG
import Backtrace
#endif

private func async(_ task: @escaping () -> Void) {
	DispatchQueue.global().async(execute: task)
}

func main(rawLogLevel: String, initialPresence: String?) throws {
	#if DEBUG
	Backtrace.install()
	#endif
	
	let logLevel = Logger.Level(rawValue: rawLogLevel) ?? .info
	LoggingSystem.bootstrap {
		let level = $0.starts(with: "D2") ? logLevel : .notice
		return D2LogHandler(label: $0, logLevel: level)
	}
	
	let log = Logger(label: "D2.main")
	let config = try? DiskJsonSerializer().readJson(as: Config.self, fromFile: "local/config.json")
	let handler = try D2Delegate(withPrefix: config?.commandPrefix ?? "%", initialPresence: initialPresence)
	let tokens = try DiskJsonSerializer().readJson(as: IOBackendTokens.self, fromFile: "local/ioBackendTokens.json")
	
	var combinedClient: CombinedMessageClient! = CombinedMessageClient()
	var disposables: [Any] = []
	var launchedAnyBackend = false
	
	if let discordToken = tokens.discord {
		log.info("Launching Discord backend")
		launchedAnyBackend = true
		async {
			runDiscordIO(with: handler, combinedClient: combinedClient, token: discordToken, disposables: &disposables)
		}
	}
	
	if let telegramToken = tokens.telegram {
		log.info("Launching Telegram backend")
		launchedAnyBackend = true
		async {
			runTelegramIO(with: handler, combinedClient: combinedClient, token: telegramToken)
		}
	}
	
	if !launchedAnyBackend {
		log.notice("No backend was launched since no tokens were provided.")
	}
	
	// Handle interrupt signals
	signal(SIGINT, SIG_IGN)
	let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
	source.setEventHandler {
		log.info("Shutting down...")
		disposables.removeAll()
		combinedClient = nil
		exit(0)
	}
	source.resume()
	
	dispatchMain()
}

command(
	Option("level", default: "info", flag: "l", description: "The global logging level"),
	Option("initialPresence", default: nil, description: "The initial activity message"),
	main
).run()
