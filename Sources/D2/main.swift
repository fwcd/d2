import Commander
import Dispatch
import Foundation
import Logging
import D2Handlers
import D2MessageIO
import D2DiscordIO
import D2TelegramIO
import D2IRCIO
import Utils

#if DEBUG
import Backtrace
#endif

func main(rawLogLevel: String, initialPresence: String?) {
    #if DEBUG
    Backtrace.install()
    #endif

    let logLevel = Logger.Level(rawValue: rawLogLevel) ?? .info
    LoggingSystem.bootstrap {
        let level = $0.starts(with: "D2") ? logLevel : .notice
        return StoringLogHandler(label: $0, logLevel: level)
    }

    let log = Logger(label: "D2.main")

    do {
        let config = try? DiskJsonSerializer().readJson(as: Config.self, fromFile: "local/config.json")
        let handler = try D2Delegate(withPrefix: config?.commandPrefix ?? "%", initialPresence: initialPresence.filter { _ in config?.setPresenceInitially ?? true })
        let tokens = try DiskJsonSerializer().readJson(as: PlatformTokens.self, fromFile: "local/platformTokens.json")

        // Create platforms
        var combinedClient: CombinedMessageClient! = CombinedMessageClient()
        var platforms: [Startable] = []
        var createdAnyPlatform = false

        if let discordToken = tokens.discord {
            createdAnyPlatform = true
            platforms.append(DiscordPlatform(with: handler, combinedClient: combinedClient, token: discordToken))
        }

        if let telegramToken = tokens.telegram {
            do {
                createdAnyPlatform = true
                platforms.append(try TelegramPlatform(with: handler, combinedClient: combinedClient, token: telegramToken))
            } catch {
                log.warning("Could not create Telegram platform: \(error)")
            }
        }

        for irc in tokens.irc ?? [] {
            do {
                createdAnyPlatform = true
                platforms.append(try IRCPlatform(with: handler, combinedClient: combinedClient, token: irc))
            } catch {
                log.warning("Could not create IRC platform: \(error)")
            }
        }

        if !createdAnyPlatform {
            log.notice("No platform was created since no tokens were provided.")
        }

        // Setup interrupt signal handler
        signal(SIGINT, SIG_IGN)
        let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
        source.setEventHandler {
            log.info("Shutting down...")
            platforms.removeAll()
            combinedClient = nil
            exit(0)
        }
        source.resume()

        // Start the platforms
        for platform in platforms {
            do {
                try platform.start()
            } catch {
                log.warning("Could not start platform: \(error)")
            }
        }

        // Block the thread
        log.info("Blocking the main thread")
        dispatchMain()
    } catch {
        log.error("An error occurred while starting D2: \(error)")
    }
}

command(
    Option("level", default: "info", flag: "l", description: "The global logging level"),
    Option("initialPresence", default: nil, description: "The initial activity message"),
    main
).run()
