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

    public func client(_ client: IRCClient, user: IRCUserID, joined channels: [ IRCChannelName ]) {
        log.info("IRC: \(user) joined \(channels)")
    }

    public func client(_ client: IRCClient, user: IRCUserID, left channels: [ IRCChannelName ]) {
        log.info("IRC: \(user) left \(channels)")
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

    private func overlayClient(with ircClient: IRCClient) -> MessageClient {
        OverlayMessageClient(inner: sinkClient, name: ircClientName)
    }
}
