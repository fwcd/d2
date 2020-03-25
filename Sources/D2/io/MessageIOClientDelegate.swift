import SwiftDiscord
import Logging
import D2MessageIO

fileprivate let log = Logger(label: "MessageIOClientDelegate")

class MessageIOClientDelegate: DiscordClientDelegate {
    private let inner: MessageDelegate
    
    init(inner: MessageDelegate) {
        log.info("Creating delegate")
        self.inner = inner
    }

    func client(_ client: DiscordClient, didConnect connected: Bool) {
        log.info("Connected")
        inner.on(connect: connected, client: DiscordMessageClient(client: client))
    }
    
    func client(_ client: DiscordClient, didReceivePresenceUpdate presence: DiscordPresence) {
        log.info("Got presence update")
        inner.on(receivePresenceUpdate: presence.usingMessageIO, client: DiscordMessageClient(client: client))
    }
    
    func client(_ client: DiscordClient, didCreateMessage message: DiscordMessage) {
        log.info("Got message")
        inner.on(createMessage: message.usingMessageIO, client: DiscordMessageClient(client: client))
    }
}
