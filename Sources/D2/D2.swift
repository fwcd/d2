import ArgumentParser
import Dispatch
import Foundation
import Logging
import NIO
import D2Commands
import D2Handlers
import D2MessageIO
import D2DiscordIO
import D2IRCIO
import Utils

#if DEBUG
import Backtrace
#endif

@main
struct D2: AsyncParsableCommand {
    @Option(name: .shortAndLong, help: "The logging level")
    var logLevel: Logger.Level?

    @Option(name: .shortAndLong, help: "The logging level for dependencies (e.g. swift-discord)")
    var dependencyLogLevel: Logger.Level?

    @Option(name: .shortAndLong, help: "The initial activity message")
    var initialPresence: String?

    func run() async throws {
        #if DEBUG && swift(<5.9)
        Backtrace.install()
        #endif

        // Read config and logging options
        let config = try? DiskJsonSerializer().readJson(as: Config.self, fromFile: "local/config.json")
        let logLevel = self.logLevel ?? config?.log?.level ?? .info
        let dependencyLogLevel = self.dependencyLogLevel ?? config?.log?.dependencyLevel ?? .info
        let printToStdout = config?.log?.printToStdout ?? true

        // Set up logging and register default outputs
        let logBuffer = LogBuffer()
        let logOutput = LogOutput()

        if printToStdout {
            await logOutput.register {
                print($0)
            }
        }

        await logOutput.register {
            logBuffer.push($0)
        }

        LoggingSystem.bootstrap {
            let level = $0.starts(with: "D2") ? logLevel : dependencyLogLevel
            return D2LogHandler(label: $0, logOutput: logOutput, logLevel: level)
        }

        let log = Logger(label: "D2.main")

        // Set up local directory
        var localDirExists: ObjCBool = false
        if !FileManager.default.fileExists(atPath: "local", isDirectory: &localDirExists) || !localDirExists.boolValue {
            log.error("Please make sure to create a 'local' directory with e.g. the 'platformTokens.json' etc. as described in the README!")
            return
        }

        // Read D2 config
        let commandPrefix = config?.commandPrefix ?? "%"
        let hostInfo = config?.hostInfo ?? HostInfo()
        let actualInitialPresence = (config?.setPresenceInitially ?? true) ? initialPresence ?? "\(commandPrefix)help" : nil
        let tokens = try DiskJsonSerializer().readJson(as: PlatformTokens.self, fromFile: "local/platformTokens.json")

        if let config {
            log.info("\(config)")
        }

        // Bootstrap NIO event loop group
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        // Create platforms
        var combinedSink: CombinedSink! = CombinedSink(mioCommandSinkName: "Discord")
        var platforms: [any Startable] = []
        var createdAnyPlatform = false

        var receiver: D2Receiver! = try D2Receiver(
            withPrefix: commandPrefix,
            hostInfo: hostInfo,
            initialPresence: actualInitialPresence,
            useMIOCommands: config?.useMIOCommands ?? false,
            mioCommandGuildId: config?.useMIOCommandsOnlyOnGuild,
            logBuffer: logBuffer,
            eventLoopGroup: eventLoopGroup,
            sink: combinedSink
        )

        if let discordToken = tokens.discord {
            createdAnyPlatform = true
            platforms.append(DiscordPlatform(
                receiver: receiver,
                combinedSink: combinedSink,
                eventLoopGroup: eventLoopGroup,
                token: discordToken
            ))
        }

        for irc in tokens.irc ?? [] {
            do {
                createdAnyPlatform = true
                platforms.append(try IRCPlatform(
                    receiver: receiver,
                    combinedSink: combinedSink,
                    eventLoopGroup: eventLoopGroup,
                    token: irc
                ))
            } catch {
                log.warning("Could not create IRC platform: \(error)")
            }
        }

        if !createdAnyPlatform {
            log.notice("No platform was created since no tokens were provided.")
        }

        // Set up interrupt signal handler
        signal(SIGINT, SIG_IGN)
        let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
        source.setEventHandler {
            log.info("Shutting down...")
            platforms.removeAll()
            receiver = nil
            combinedSink = nil
            try! eventLoopGroup.syncShutdownGracefully()
            Self.exit()
        }
        source.resume()

        // Register channel log output if needed
        if let logChannel = config?.log?.channel {
            await logOutput.register {
                combinedSink.sendMessage($0, to: logChannel)
            }
        }

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
    }
}
