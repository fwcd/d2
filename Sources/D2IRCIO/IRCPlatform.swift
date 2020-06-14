import D2MessageIO
import Logging
import IRC

fileprivate let log = Logger(label: "D2IRCIO.IRCPlatform")

public struct IRCPlatform: MessagePlatform {
    private let config: IRCConfig
    private let ircClient: IRCClient
    public let name: String

    public init(with delegate: MessageDelegate, combinedClient: CombinedMessageClient, token config: IRCConfig) throws {
        self.config = config
        name = "IRC \(config.host):\(config.port)"

        log.info("Initializing IRC backend (\(config.host):\(config.port))...")
        ircClient = IRCClient(options: IRCClientOptions(
            port: config.port,
            host: config.host,
            password: config.password,
            nickname: IRCNickName(config.nickname)!
        ))

        combinedClient.register(client: IRCMessageClient(ircClient: ircClient, name: name))

        let channelsToJoin = (config.deferAutojoinToAfterFirstMessage ?? false) ? (config.autojoinedChannels ?? []) : []
        ircClient.delegate = MessageIOClientDelegate(inner: delegate, sinkClient: combinedClient, name: name, channelsToJoin: channelsToJoin)
    }
    
    public func start() throws {
        log.info("Starting IRC client (\(config.host):\(config.port))")
        ircClient.connect()?.whenSuccess { _ in
            if !(self.config.deferAutojoinToAfterFirstMessage ?? false), let channels = self.config.autojoinedChannels {
                log.info("Auto-joining IRC channels \(channels)...")
                self.ircClient.sendMessage(IRCMessage(command: .JOIN(channels: channels.map { IRCChannelName($0)! }, keys: nil)))
            }
        }
    }
}
