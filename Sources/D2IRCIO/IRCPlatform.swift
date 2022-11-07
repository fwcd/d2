import D2MessageIO
import Logging
import NIO
import IRC

fileprivate let log = Logger(label: "D2IRCIO.IRCPlatform")

public struct IRCPlatform: MessagePlatform {
    private let config: IRCConfig
    private let ircClient: IRCClient
    public let name: String

    public init(
        with delegate: any MessageDelegate,
        combinedClient: CombinedMessageClient,
        eventLoopGroup: any EventLoopGroup,
        token config: IRCConfig
    ) throws {
        self.config = config
        name = "IRC \(config.host):\(config.port)"

        log.info("Initializing IRC backend (\(config.host):\(config.port))...")
        ircClient = IRCClient(options: IRCClientOptions(
            port: config.port,
            host: config.host,
            password: config.password,
            nickname: IRCNickName(config.nickname)!,
            eventLoopGroup: eventLoopGroup
        ))

        combinedClient.register(client: IRCMessageClient(ircClient: ircClient, name: name))

        ircClient.delegate = MessageIOClientDelegate(inner: delegate, sinkClient: combinedClient, name: name, channelsToJoin: config.autojoinedChannels ?? [])
    }

    public func start() throws {
        log.info("Starting IRC client (\(config.host):\(config.port))")
        ircClient.connect()
    }
}
