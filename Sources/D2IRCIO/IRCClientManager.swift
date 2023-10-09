import IRC
import Logging
import D2MessageIO

fileprivate let log = Logger(label: "D2IRCIO.IRCClientManager")

public class IRCClientManager: IRCClientDelegate {
    private let inner: any MessageDelegate
    private let combinedClient: any MessageClient
    private let name: String

    private var joined: Bool = false
    private var channelsToJoin: [String]

    private var ircClient: IRCClient

    public init(
        inner: any MessageDelegate,
        combinedClient: CombinedMessageClient,
        eventLoopGroup: any EventLoopGroup,
        config: IRCConfig,
        name: String,
        channelsToJoin: [String]
    ) {
        self.inner = inner
        self.combinedClient = combinedClient
        self.name = name
        self.channelsToJoin = channelsToJoin

        ircClient = IRCClient(options: IRCClientOptions(
            port: config.port,
            host: config.host,
            password: config.password,
            nickname: IRCNickName(config.nickname)!,
            eventLoopGroup: eventLoopGroup
        ))
        ircClient.delegate = self

        combinedClient.register(client: IRCMessageClient(ircClient: ircClient, name: name))
    }

    public func connect() {
        ircClient.connect()
    }

    public func clientFailedToRegister(_ ircClient: IRCClient) {
        log.warning("Client failed to register")
    }

    public func client(_ ircClient: IRCClient, registered nick: IRCNickName, with userInfo: IRCUserInfo) {
        log.info("Registered \(nick) with \(userInfo)")

        if !joined && !channelsToJoin.isEmpty {
            joined = true
            log.info("Auto-joining channels \(channelsToJoin)...")
            ircClient.sendMessage(IRCMessage(command: .JOIN(channels: channelsToJoin.map { IRCChannelName($0)! }, keys: nil)))
        }
    }

    public func client(_ ircClient: IRCClient, user: IRCUserID, joined channels: [ IRCChannelName ]) {
        log.info("\(user) joined \(channels)")
    }

    public func client(_ ircClient: IRCClient, user: IRCUserID, left channels: [ IRCChannelName ]) {
        log.info("\(user) left \(channels)")
    }

    public func client(_ client: IRCClient, messageOfTheDay: String) {
        log.info("Message of the day: \(messageOfTheDay)")
    }

    public func client(_ ircClient: IRCClient, received message: IRCMessage) {
        log.info("Received: \(message)")
    }

    public func client(_ ircClient: IRCClient, message: String, from sender: IRCUserID, for recipients: [ IRCMessageRecipient ]) {
        log.debug("Received: \(message) (recipients: \(recipients))")
        guard case let .channel(channelName)? = recipients.first else { return }

        // TODO: Support chats with multiple recipients and .nickname()
        let m = D2MessageIO.Message(
            content: message,
            // TODO: Proper user IDs
            author: User(id: dummyId, username: sender.nick.stringValue),
            channelId: ID(channelName.stringValue, clientName: name)
        )

        inner.on(createMessage: m, client: overlayClient(with: ircClient))
    }

    private func overlayClient(with ircClient: IRCClient) -> MessageClient {
        OverlayMessageClient(inner: combinedClient, name: name)
    }
}
