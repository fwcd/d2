import Discord
import Logging
import D2MessageIO

fileprivate let log = Logger(label: "D2DiscordIO.MessageIOClientDelegate")

public class MessageIOClientDelegate: DiscordClientDelegate {
    private let inner: any MessageDelegate
    private let sinkClient: any MessageClient

    public init(inner: any MessageDelegate, sinkClient: any MessageClient) {
        log.debug("Creating delegate")
        self.inner = inner
        self.sinkClient = sinkClient
    }

    public func client(_ discordClient: DiscordClient, didConnect connected: Bool) {
        log.debug("Connected")
        inner.on(connect: connected, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didDisconnectWithReason reason: String) {
        log.debug("Got disconnect with reason \(reason)")
        inner.on(disconnectWithReason: reason, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didCreateChannel channel: DiscordChannel) {
        log.debug("Got channel create: \(channel.id)")
        inner.on(createChannel: channel.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didDeleteChannel channel: DiscordChannel) {
        log.debug("Got channel delete: \(channel.id)")
        inner.on(deleteChannel: channel.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didUpdateChannel channel: DiscordChannel) {
        log.debug("Got channel update: \(channel.id)")
        inner.on(updateChannel: channel.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didCreateThread thread: DiscordChannel) {
        log.debug("Got thread create: \(thread.id)")
        inner.on(createThread: thread.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didDeleteThread thread: DiscordChannel) {
        log.debug("Got thread delete: \(thread.id)")
        inner.on(deleteThread: thread.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didUpdateThread thread: DiscordChannel) {
        log.debug("Got thread update: \(thread.id)")
        inner.on(updateThread: thread.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didCreateGuild guild: DiscordGuild) {
        log.debug("Created guild")
        inner.on(createGuild: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didDeleteGuild guild: DiscordGuild) {
        log.debug("Deleted guild")
        inner.on(deleteGuild: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didUpdateGuild guild: DiscordGuild) {
        log.debug("Updated guild")
        inner.on(updateGuild: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didAddGuildMember member: DiscordGuildMember) {
        log.debug("Added guild member: \(member.user.username ?? "?")")
        guard let guildId = member.guildId?.usingMessageIO else {
            log.error("Guild member \(member.user.username ?? "?") has no guild id")
            return
        }
        inner.on(addGuildMember: member.usingMessageIO(in: guildId), client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didRemoveGuildMember member: DiscordGuildMember) {
        log.debug("Removed guild member: \(member.user.username ?? "?")")
        guard let guildId = member.guildId?.usingMessageIO else {
            log.error("Guild member \(member.user.username ?? "?") has no guild id")
            return
        }
        inner.on(removeGuildMember: member.usingMessageIO(in: guildId), client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didUpdateGuildMember member: DiscordGuildMember) {
        log.debug("Updated guild member: \(member.user.username ?? "?")")
        guard let guildId = member.guildId?.usingMessageIO else {
            log.error("Guild member \(member.user.username ?? "?") has no guild id")
            return
        }
        inner.on(updateGuildMember: member.usingMessageIO(in: guildId), client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didUpdateMessage message: DiscordMessage) {
        log.debug("Got message update")
        let client = overlayClient(with: discordClient)
        inner.on(updateMessage: message.usingMessageIO(with: client), client: client)
    }

    public func client(_ discordClient: DiscordClient, didCreateMessage message: DiscordMessage) {
        log.debug("Got message")
        let client = overlayClient(with: discordClient)
        inner.on(createMessage: message.usingMessageIO(with: client), client: client)
    }

    public func client(_ discordClient: DiscordClient, didAddReaction reaction: DiscordEmoji, toMessage messageID: Discord.MessageID, onChannel channel: DiscordChannel, user userID: Discord.UserID) {
        log.debug("Did add reaction")
        inner.on(addReaction: reaction.usingMessageIO, to: messageID.usingMessageIO, on: channel.id.usingMessageIO, by: userID.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didRemoveReaction reaction: DiscordEmoji, fromMessage messageID: Discord.MessageID, onChannel channel: DiscordChannel, user userID: Discord.UserID) {
        log.debug("Did remove reaction")
        inner.on(removeReaction: reaction.usingMessageIO, from: messageID.usingMessageIO, on: channel.id.usingMessageIO, by: userID.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didRemoveAllReactionsFrom messageID: Discord.MessageID, onChannel channel: DiscordChannel) {
        log.debug("Did remove all reactions")
        inner.on(removeAllReactionsFrom: messageID.usingMessageIO, on: channel.id.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didCreateRole role: DiscordRole, onGuild guild: DiscordGuild) {
        log.debug("Got role create: \(role.name) on guild \(guild.name ?? "?")")
        inner.on(createRole: role.usingMessageIO, on: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didDeleteRole role: DiscordRole, onGuild guild: DiscordGuild) {
        log.debug("Got role delete: \(role.name) on guild \(guild.name ?? "?")")
        inner.on(deleteRole: role.usingMessageIO, from: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didUpdateRole role: DiscordRole, onGuild guild: DiscordGuild) {
        log.debug("Got role update: \(role.name) on guild \(guild.name ?? "?")")
        inner.on(updateRole: role.usingMessageIO, on: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didReceivePresenceUpdate presence: DiscordPresence) {
        log.debug("Got presence update")
        inner.on(receivePresenceUpdate: presence.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didReceiveReady ready: DiscordReadyEvent) {
        log.debug("Received ready")
        // TODO: Add a strongly-typed ReadyEvent in D2MessageIO
        inner.on(receiveReady: [
            "gatewayVersion": ready.gatewayVersion as Any,
            "shard": ready.shard as Any
        ], client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didCreateInteraction interaction: DiscordInteraction) {
        log.debug("Created interaction")
        let client = overlayClient(with: discordClient)
        inner.on(createInteraction: interaction.usingMessageIO(with: client), client: client)
    }

    public func client(_ discordClient: DiscordClient, didReceiveVoiceStateUpdate voiceState: DiscordVoiceState) {
        log.debug("Got voice state update")
        inner.on(receiveVoiceStateUpdate: voiceState.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didHandleGuildMemberChunk chunk: [DiscordGuildMember], forGuild guild: DiscordGuild) {
        log.debug("Handling guild member chunk")
        let newChunk = Dictionary(uniqueKeysWithValues: chunk.map { ($0.id.usingMessageIO, $0.usingMessageIO(in: guild.id.usingMessageIO)) })
        inner.on(handleGuildMemberChunk: newChunk, for: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }

    public func client(_ discordClient: DiscordClient, didUpdateEmojis emojis: [DiscordEmoji], onGuild guild: DiscordGuild) {
        log.debug("Got updated emojis")
        let newEmojis = Dictionary(uniqueKeysWithValues: emojis.compactMap { e in e.id.map { ($0.usingMessageIO, e.usingMessageIO) } })
        inner.on(updateEmojis: newEmojis, on: guild.usingMessageIO, client: overlayClient(with: discordClient))
    }

    private func overlayClient(with discordClient: DiscordClient) -> MessageClient {
        OverlayMessageClient(inner: sinkClient, name: discordClientName, me: discordClient.user?.usingMessageIO)
    }
}
