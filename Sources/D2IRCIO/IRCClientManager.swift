@preconcurrency import IRC
import NIO
import Logging
import D2MessageIO

private let log = Logger(label: "D2IRCIO.IRCClientManager")

public actor IRCClientManager: IRCClientDelegate {
    private let receiver: any Receiver
    private let combinedSink: CombinedSink
    private let name: String

    private var joined: Bool = false
    private var channelsToJoin: [String]

    private var ircClient: IRCClient

    public init(
        receiver: any Receiver,
        combinedSink: CombinedSink,
        eventLoopGroup: any EventLoopGroup,
        config: IRCConfig,
        name: String,
        channelsToJoin: [String]
    ) async {
        self.receiver = receiver
        self.combinedSink = combinedSink
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

        await combinedSink.register(sink: IRCSink(client: ircClient, name: name))
    }

    public func connect() {
        ircClient.connect()
    }

    private func autojoin() {
        if !joined && !channelsToJoin.isEmpty {
            joined = true
            log.info("Auto-joining channels \(channelsToJoin)...")
            ircClient.sendMessage(IRCMessage(command: .JOIN(channels: channelsToJoin.map { IRCChannelName($0)! }, keys: nil)))
        }
    }

    public nonisolated func clientFailedToRegister(_ ircClient: IRCClient) {
        log.warning("Client failed to register")
    }

    public nonisolated func client(_ ircClient: IRCClient, registered nick: IRCNickName, with userInfo: IRCUserInfo) {
        log.info("Registered \(nick) with \(userInfo)")

        Task {
            await autojoin()
        }
    }

    public nonisolated func client(_ ircClient: IRCClient, user: IRCUserID, joined channels: [ IRCChannelName ]) {
        log.info("\(user) joined \(channels)")
    }

    public nonisolated func client(_ ircClient: IRCClient, user: IRCUserID, left channels: [ IRCChannelName ]) {
        log.info("\(user) left \(channels)")
    }

    public nonisolated func client(_ client: IRCClient, messageOfTheDay: String) {
        log.info("Message of the day: \(messageOfTheDay)")
    }

    public nonisolated func client(_ ircClient: IRCClient, received message: IRCMessage) {
        log.info("Received: \(message)")
    }

    public nonisolated func client(_ ircClient: IRCClient, message: String, from sender: IRCUserID, for recipients: [ IRCMessageRecipient ]) {
        log.debug("Received: \(message) (recipients: \(recipients))")
        guard case let .channel(channelName)? = recipients.first else { return }

        // TODO: Support chats with multiple recipients and .nickname()
        let m = D2MessageIO.Message(
            content: message,
            // TODO: Proper user IDs
            author: User(id: dummyId, username: sender.nick.stringValue),
            channelId: ID(channelName.stringValue, clientName: name)
        )

        Task { @Sendable in
            await receiver.on(createMessage: m, sink: overlaySink(with: ircClient))
        }
    }

    private func overlaySink(with ircClient: IRCClient) -> some Sink {
        OverlaySink(inner: combinedSink, name: name)
    }
}
