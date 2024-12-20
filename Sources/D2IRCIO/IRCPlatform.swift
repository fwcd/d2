import D2MessageIO
import Logging
import NIO
import IRC

private let log = Logger(label: "D2IRCIO.IRCPlatform")

public struct IRCPlatform: MessagePlatform, Sendable {
    private let config: IRCConfig
    private let manager: IRCClientManager

    public let name: String

    public init(
        receiver: any Receiver,
        combinedSink: CombinedSink,
        eventLoopGroup: any EventLoopGroup,
        token config: IRCConfig
    ) async throws {
        self.config = config
        name = "IRC \(config.host):\(config.port)"

        log.info("Initializing IRC backend (\(config.host):\(config.port))...")
        manager = await IRCClientManager(
            receiver: receiver,
            combinedSink: combinedSink,
            eventLoopGroup: eventLoopGroup,
            config: config,
            name: name,
            channelsToJoin: config.autojoinedChannels ?? []
        )
    }

    public func start() throws {
        log.info("Starting IRC client (\(config.host):\(config.port))")
        Task {
            await manager.connect()
        }
    }
}
