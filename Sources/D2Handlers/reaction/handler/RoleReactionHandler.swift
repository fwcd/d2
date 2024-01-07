import D2Commands
import D2MessageIO
import Logging
import Utils

fileprivate let log = Logger(label: "D2Handlers.RoleReactionHandler")

public struct RoleReactionHandler: ReactionHandler {
    @Binding private var configuration: RoleReactionsConfiguration

    public init(configuration: Binding<RoleReactionsConfiguration>) {
        self._configuration = configuration
    }

    public func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) {
        if
            let roleId = configuration.roleMessages[messageId]?[emoji.compactDescription],
            let guild = sink.guildForChannel(channelId),
            let role = guild.roles[roleId],
            let member = guild.members[userId],
            !member.user.bot,
            !member.roleIds.contains(roleId) {
            log.info("Adding role \(role.name) upong reaction to \(member.displayName)")
            sink.addGuildMemberRole(roleId, to: userId, on: guild.id, reason: "Reaction")
        }
    }

    public func handle(deletedReaction emoji: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) {
        if
            let roleId = configuration.roleMessages[messageId]?[emoji.compactDescription],
            let guild = sink.guildForChannel(channelId),
            let role = guild.roles[roleId],
            let member = guild.members[userId],
            !member.user.bot,
            member.roleIds.contains(roleId) {
            log.info("Removing role \(role.name) upong reaction from \(member.displayName)")
            sink.removeGuildMemberRole(roleId, from: userId, on: guild.id, reason: "Reaction")
        }
    }
}
