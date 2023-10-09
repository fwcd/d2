import D2MessageIO
import Logging
import NIO
import IRC

fileprivate let log = Logger(label: "D2IRCIO.IRCPlatform")

public struct IRCPlatform: MessagePlatform {
    private let config: IRCConfig
    private let manager: IRCClientManager

    public let name: String

    public init(
        with delegate: any MessageDelegate,
        combinedClient: CombinedSink,
        eventLoopGroup: any EventLoopGroup,
        token config: IRCConfig
    ) throws {
        self.config = config
        name = "IRC \(config.host):\(config.port)"

        log.info("Initializing IRC backend (\(config.host):\(config.port))...")
        manager = IRCClientManager(
            inner: delegate,
            combinedClient: combinedClient,
            eventLoopGroup: eventLoopGroup,
            config: config,
            name: name,
            channelsToJoin: config.autojoinedChannels ?? []
        )
    }

    public func start() throws {
        log.info("Starting IRC client (\(config.host):\(config.port))")
        manager.connect()
    }
}
