import IRC
import Logging
import D2MessageIO

fileprivate let log = Logger(label: "D2IRCIO.MessageIOClientDelegate")

public class MessageIOClientDelegate: IRCClientDelegate {
    private let inner: MessageDelegate
    private let sinkClient: MessageClient

    private var joined: Bool = false
    private var channelsToJoin: [String]
    
    public init(inner: MessageDelegate, sinkClient: MessageClient, channelsToJoin: [String]) {
        log.debug("Creating delegate")
        self.inner = inner
        self.sinkClient = sinkClient
        self.channelsToJoin = channelsToJoin
    }

    public func clientFailedToRegister(_ ircClient: IRCClient) {
        log.warning("Client failed to register")
    }

    public func client(_ ircClient: IRCClient, registered nick: IRCNickName, with userInfo: IRCUserInfo) {
        log.info("Registered \(nick) with \(userInfo)")
    }

    public func client(_ ircClient: IRCClient, user: IRCUserID, joined channels: [ IRCChannelName ]) {
        log.info("\(user) joined \(channels)")
        ircClient.send(.PRIVMSG(channels.map { .channel($0) }, "Hi"))
    }

    public func client(_ ircClient: IRCClient, user: IRCUserID, left channels: [ IRCChannelName ]) {
        log.info("\(user) left \(channels)")
    }

    public func client(_ client: IRCClient, messageOfTheDay: String) {
        log.info("Message of the day: \(messageOfTheDay)")
    }

    public func client(_ ircClient: IRCClient, received message: IRCMessage) {
        log.info("Received message from IRC: \(message)")

        if !joined && !channelsToJoin.isEmpty {
            joined = true
            log.info("Auto-joining channels \(channelsToJoin)...")
            ircClient.sendMessage(IRCMessage(command: .JOIN(channels: channelsToJoin.map { IRCChannelName($0)! }, keys: nil)))
        }

        if let m = message.usingMessageIO {
            inner.on(createMessage: m, client: overlayClient(with: ircClient))
        }
    }

    public func client(_ ircClient: IRCClient, message: String, from sender: IRCUserID, for recipients: [ IRCMessageRecipient ]) {
        log.info("Received text message from IRC: \(message)")

        // TODO: Improve the message conversion here
        if let m = IRCMessage(origin: sender.stringValue, command: .PRIVMSG(recipients, message)).usingMessageIO {
            inner.on(createMessage: m, client: overlayClient(with: ircClient))
        }
    }

    private func overlayClient(with ircClient: IRCClient) -> MessageClient {
        OverlayMessageClient(inner: sinkClient, name: ircClientName)
    }
}
