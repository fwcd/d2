import IRC
import Logging
import D2MessageIO

fileprivate let log = Logger(label: "D2IRCIO.MessageIOClientDelegate")

public class MessageIOClientDelegate: IRCClientDelegate {
    private let inner: MessageDelegate
    private let sinkClient: any MessageClient
    private let name: String

    private var joined: Bool = false
    private var channelsToJoin: [String]

    public init(inner: MessageDelegate, sinkClient: any MessageClient, name: String, channelsToJoin: [String]) {
        log.debug("Creating delegate for \(name)")
        self.inner = inner
        self.sinkClient = sinkClient
        self.name = name
        self.channelsToJoin = channelsToJoin
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
        OverlayMessageClient(inner: sinkClient, name: name)
    }
}
