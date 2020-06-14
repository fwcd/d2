import D2MessageIO
import Logging
import IRC

fileprivate let log = Logger(label: "D2IRCIO.IRCPlatform")

public struct IRCPlatform: MessagePlatform {
    private let config: IRCConfig
    private let ircClient: IRCClient
    
    // TODO: This currently assumes that only a single
    // IRC client is present. It would be better to
    // use a combination of ircClientName and host:port
    // to identify the client uniquely.
    //
    // See also: IRCChannelNameConverter
    public var name: String { ircClientName }

    public init(with delegate: MessageDelegate, combinedClient: CombinedMessageClient, token config: IRCConfig) throws {
        self.config = config

        log.info("Initializing IRC backend (\(config.host):\(config.port))...")
        ircClient = IRCClient(options: IRCClientOptions(
            port: config.port,
            host: config.host,
            password: config.password,
            nickname: IRCNickName(config.nickname)!
        ))
        ircClient.delegate = MessageIOClientDelegate(inner: delegate, sinkClient: combinedClient)
    }
    
    public func start() throws {
        log.info("Starting IRC client (\(config.host):\(config.port))")
        ircClient.connect()?.whenSuccess { _ in
            if let channels = self.config.autojoinedChannels {
                log.info("Auto-joining IRC channels...")
                self.ircClient.sendMessage(IRCMessage(command: .JOIN(channels: channels.map { IRCChannelName($0)! }, keys: nil)))
            }
        }
    }
}
