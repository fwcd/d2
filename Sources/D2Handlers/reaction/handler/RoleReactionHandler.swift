import D2Commands
import D2MessageIO
import Logging
import Utils

fileprivate let log = Logger(label: "D2Handlers.RoleReactionHandler")

public struct RoleReactionHandler: ReactionHandler {
    @AutoSerializing private var configuration: RoleReactionsConfiguration

    public init(configuration: AutoSerializing<RoleReactionsConfiguration>) {
        self._configuration = configuration
    }

    public func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {
        if
            let roleId = configuration.roleMessages[messageId]?.roleMappings["\(emoji)"],
            let guild = client.guildForChannel(channelId),
            let role = guild.roles[roleId],
            let member = guild.members[userId],
            !member.roleIds.contains(roleId) {
            log.info("Adding role \(role.name) upong reaction to \(member.displayName)")
            client.addGuildMemberRole(roleId, to: userId, on: guild.id, reason: "Reaction")
        }
    }

    public func handle(deletedReaction emoji: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {
        if
            let roleId = configuration.roleMessages[messageId]?.roleMappings["\(emoji)"],
            let guild = client.guildForChannel(channelId),
            let role = guild.roles[roleId],
            let member = guild.members[userId],
            !member.roleIds.contains(roleId) {
            log.info("Removing role \(role.name) upong reaction from \(member.displayName)")
            client.removeGuildMemberRole(roleId, from: userId, on: guild.id, reason: "Reaction")
        }
    }
}
