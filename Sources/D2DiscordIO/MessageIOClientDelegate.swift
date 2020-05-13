import SwiftDiscord
import Logging
import D2MessageIO

fileprivate let log = Logger(label: "D2DiscordIO.MessageIOClientDelegate")

public class MessageIOClientDelegate: DiscordClientDelegate {
    private let inner: MessageDelegate
    private let sinkClient: MessageClient
    
    public init(inner: MessageDelegate, sinkClient: MessageClient) {
        log.debug("Creating delegate")
        self.inner = inner
        self.sinkClient = sinkClient
    }

    public func client(_ discordClient: DiscordClient, didConnect connected: Bool) {
        log.debug("Connected")
        inner.on(connect: connected, client: overlayClient(with: discordClient))
    }
    
    public func client(_ discordClient: DiscordClient, didReceivePresenceUpdate presence: DiscordPresence) {
        log.debug("Got presence update")
        inner.on(receivePresenceUpdate: presence.usingMessageIO, client: overlayClient(with: discordClient))
    }
    
    public func client(_ discordClient: DiscordClient, didCreateMessage message: DiscordMessage) {
        log.debug("Got message")
        inner.on(createMessage: message.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didCreateGuild guild: DiscordGuild) {
        log.debug("Created guild")
        inner.on(createGuild: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }
    
    private func overlayClient(with discordClient: DiscordClient) -> MessageClient {
        OverlayMessageClient(inner: sinkClient, name: discordClientName, me: discordClient.user?.usingMessageIO)
    }
}
