import Dispatch
import Discord
import Logging
import NIO
import D2MessageIO

fileprivate let log = Logger(label: "D2DiscordIO.DiscordClientManager")

public class DiscordClientManager: DiscordClientDelegate {
    private let receiver: any Receiver
    private let combinedSink: CombinedSink

    private let queue: DispatchQueue
    private var discordClient: DiscordClient!

    public init(
        receiver: any Receiver,
        combinedSink: CombinedSink,
        eventLoopGroup: any EventLoopGroup,
        token: String
    ) async {
        self.receiver = receiver
        self.combinedSink = combinedSink

        queue = DispatchQueue(label: "Discord handle queue")
        discordClient = DiscordClient(token: DiscordToken(rawValue: "Bot \(token)"), delegate: self, configuration: [
            .handleQueue(queue),
            .intents(.allIntents),
            .eventLoopGroup(eventLoopGroup),
        ])

        await combinedSink.register(sink: DiscordSink(client: discordClient))
    }

    public func connect() {
        discordClient.connect()
    }

    public func client(_ discordClient: DiscordClient, didConnect connected: Bool) {
        log.info("Connected")
        Task {
            await receiver.on(connect: connected, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ client: DiscordClient, didDisconnectWithReason reason: DiscordGatewayCloseReason, closed: Bool) {
        log.info("Got disconnect with reason \(reason)")
        Task {
            await receiver.on(disconnectWithReason: String(describing: reason), sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didCreateChannel channel: DiscordChannel) {
        log.debug("Got channel create: \(channel.id)")
        Task {
            await receiver.on(createChannel: channel.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didDeleteChannel channel: DiscordChannel) {
        log.debug("Got channel delete: \(channel.id)")
        Task {
            await receiver.on(deleteChannel: channel.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didUpdateChannel channel: DiscordChannel) {
        log.debug("Got channel update: \(channel.id)")
        Task {
            await receiver.on(updateChannel: channel.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didCreateThread thread: DiscordChannel) {
        log.debug("Got thread create: \(thread.id)")
        Task {
            await receiver.on(createThread: thread.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didDeleteThread thread: DiscordChannel) {
        log.debug("Got thread delete: \(thread.id)")
        Task {
            await receiver.on(deleteThread: thread.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didUpdateThread thread: DiscordChannel) {
        log.debug("Got thread update: \(thread.id)")
        Task {
            await receiver.on(updateThread: thread.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didCreateGuild guild: DiscordGuild) {
        log.debug("Created guild")
        Task {
            await receiver.on(createGuild: guild.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didDeleteGuild guild: DiscordGuild) {
        log.debug("Deleted guild")
        Task {
            await receiver.on(deleteGuild: guild.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didUpdateGuild guild: DiscordGuild) {
        log.debug("Updated guild")
        Task {
            await receiver.on(updateGuild: guild.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didAddGuildMember member: DiscordGuildMember) {
        log.debug("Added guild member: \(member.user.username ?? "?")")
        guard let guildId = member.guildId?.usingMessageIO else {
            log.error("Guild member \(member.user.username ?? "?") has no guild id")
            return
        }
        Task {
            await receiver.on(addGuildMember: member.usingMessageIO(in: guildId), sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didRemoveGuildMember member: DiscordGuildMember) {
        log.debug("Removed guild member: \(member.user.username ?? "?")")
        guard let guildId = member.guildId?.usingMessageIO else {
            log.error("Guild member \(member.user.username ?? "?") has no guild id")
            return
        }
        Task {
            await receiver.on(removeGuildMember: member.usingMessageIO(in: guildId), sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didUpdateGuildMember member: DiscordGuildMember) {
        log.debug("Updated guild member: \(member.user.username ?? "?")")
        guard let guildId = member.guildId?.usingMessageIO else {
            log.error("Guild member \(member.user.username ?? "?") has no guild id")
            return
        }
        Task {
            await receiver.on(updateGuildMember: member.usingMessageIO(in: guildId), sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didUpdateMessage message: DiscordMessage) {
        log.debug("Got message update")
        let sink = overlaySink(with: discordClient)
        Task {
            await receiver.on(updateMessage: message.usingMessageIO(with: sink), sink: sink)
        }
    }

    public func client(_ discordClient: DiscordClient, didCreateMessage message: DiscordMessage) {
        log.debug("Got message")
        let sink = overlaySink(with: discordClient)
        Task {
            await receiver.on(createMessage: message.usingMessageIO(with: sink), sink: sink)
        }
    }

    public func client(_ discordClient: DiscordClient, didAddReaction reaction: DiscordEmoji, toMessage messageID: Discord.MessageID, onChannel channel: DiscordChannel, user userID: Discord.UserID) {
        log.debug("Did add reaction")
        Task {
            await receiver.on(addReaction: reaction.usingMessageIO, to: messageID.usingMessageIO, on: channel.id.usingMessageIO, by: userID.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didRemoveReaction reaction: DiscordEmoji, fromMessage messageID: Discord.MessageID, onChannel channel: DiscordChannel, user userID: Discord.UserID) {
        log.debug("Did remove reaction")
        Task {
            await receiver.on(removeReaction: reaction.usingMessageIO, from: messageID.usingMessageIO, on: channel.id.usingMessageIO, by: userID.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didRemoveAllReactionsFrom messageID: Discord.MessageID, onChannel channel: DiscordChannel) {
        log.debug("Did remove all reactions")
        Task {
            await receiver.on(removeAllReactionsFrom: messageID.usingMessageIO, on: channel.id.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didCreateRole role: DiscordRole, onGuild guild: DiscordGuild) {
        log.debug("Got role create: \(role.name) on guild \(guild.name ?? "?")")
        Task {
            await receiver.on(createRole: role.usingMessageIO, on: guild.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didDeleteRole role: DiscordRole, onGuild guild: DiscordGuild) {
        log.debug("Got role delete: \(role.name) on guild \(guild.name ?? "?")")
        Task {
            await receiver.on(deleteRole: role.usingMessageIO, from: guild.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didUpdateRole role: DiscordRole, onGuild guild: DiscordGuild) {
        log.debug("Got role update: \(role.name) on guild \(guild.name ?? "?")")
        Task {
            await receiver.on(updateRole: role.usingMessageIO, on: guild.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didReceivePresenceUpdate presence: DiscordPresence) {
        log.debug("Got presence update")
        Task {
            await receiver.on(receivePresenceUpdate: presence.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didReceiveReady ready: DiscordReadyEvent) {
        log.debug("Received ready")
        // TODO: Add a strongly-typed ReadyEvent in D2MessageIO
        Task {
            await receiver.on(receiveReady: [
                "gatewayVersion": ready.gatewayVersion as Any,
                "shard": ready.shard as Any
            ], sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didCreateInteraction interaction: DiscordInteraction) {
        log.debug("Created interaction")
        let sink = overlaySink(with: discordClient)
        Task {
            await receiver.on(createInteraction: interaction.usingMessageIO(with: sink), sink: sink)
        }
    }

    public func client(_ discordClient: DiscordClient, didReceiveVoiceStateUpdate voiceState: DiscordVoiceState) {
        log.debug("Got voice state update")
        Task {
            await receiver.on(receiveVoiceStateUpdate: voiceState.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didHandleGuildMemberChunk chunk: [DiscordGuildMember], forGuild guild: DiscordGuild) {
        log.debug("Handling guild member chunk")
        let newChunk = Dictionary(uniqueKeysWithValues: chunk.map { ($0.id.usingMessageIO, $0.usingMessageIO(in: guild.id.usingMessageIO)) })
        Task {
            await receiver.on(handleGuildMemberChunk: newChunk, for: guild.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    public func client(_ discordClient: DiscordClient, didUpdateEmojis emojis: [DiscordEmoji], onGuild guild: DiscordGuild) {
        log.debug("Got updated emojis")
        let newEmojis = Dictionary(uniqueKeysWithValues: emojis.compactMap { e in e.id.map { ($0.usingMessageIO, e.usingMessageIO) } })
        Task {
            await receiver.on(updateEmojis: newEmojis, on: guild.usingMessageIO, sink: overlaySink(with: discordClient))
        }
    }

    private func overlaySink(with discordClient: DiscordClient) -> Sink {
        OverlaySink(inner: combinedSink, name: discordClientName, me: discordClient.user?.usingMessageIO)
    }
}
