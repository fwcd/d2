import IRC
import Logging
import D2MessageIO

fileprivate let log = Logger(label: "D2IRCIO.MessageIOClientDelegate")

public class MessageIOClientDelegate: IRCClientDelegate {
    private let inner: MessageDelegate
    private let sinkClient: MessageClient
    
    public init(inner: MessageDelegate, sinkClient: MessageClient) {
        log.debug("Creating delegate")
        self.inner = inner
        self.sinkClient = sinkClient
    }

    public func client(_ ircClient: IRCClient, received message: IRCMessage) {
        log.info("Received message from IRC: \(message)")
        if let m = message.usingMessageIO {
            inner.on(createMessage: m, client: overlayClient(with: ircClient))
        }
    }

    private func overlayClient(with ircClient: IRCClient) -> MessageClient {
        OverlayMessageClient(inner: sinkClient, name: ircClientName)
    }
}
