import SwiftDiscord
import D2MessageIO

class MessageIOClientDelegate<D>: DiscordClientDelegate where D: MessageDelegate {
    private let inner: D
    
    init(inner: D) {
        self.inner = inner
    }

    func client(_ client: DiscordClient, didConnect connected: Bool) {
        inner.on(connect: connected, client: DiscordMessageClient(client: client))
    }
    
    func client(_ client: DiscordClient, didReceivePresenceUpdate presence: DiscordPresence) {
        inner.on(receivePresenceUpdate: presence.usingMessageIO, client: DiscordMessageClient(client: client))
    }
    
    func client(_ client: DiscordClient, didCreateMessage message: DiscordMessage) {
        inner.on(createMessage: message.usingMessageIO, client: DiscordMessageClient(client: client))
    }
}
