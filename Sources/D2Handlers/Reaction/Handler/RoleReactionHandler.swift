import D2Commands
import D2MessageIO
import Logging
import Utils

private let log = Logger(label: "D2Handlers.RoleReactionHandler")

public struct RoleReactionHandler: ReactionHandler {
    @Binding private var configuration: RoleReactionsConfiguration

    public init(@Binding configuration: RoleReactionsConfiguration) {
        self._configuration = _configuration
    }

    public func handle(createdReaction emoji: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) async {
        if
            let roleId = configuration.roleMessages[messageId]?[emoji.compactDescription],
            let guild = await sink.guildForChannel(channelId),
            let role = guild.roles[roleId],
            let member = guild.members[userId],
            !member.user.bot,
            !member.roleIds.contains(roleId) {
            log.info("Adding role \(role.name) upon reaction to \(member.displayName)")
            do {
                try await sink.addGuildMemberRole(roleId, to: userId, on: guild.id, reason: "Reaction")
            } catch {
                log.warning("Could not add role \(role.name) upon reaction to \(member.displayName)")
            }
        }
    }

    public func handle(deletedReaction emoji: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) async {
        if
            let roleId = configuration.roleMessages[messageId]?[emoji.compactDescription],
            let guild = await sink.guildForChannel(channelId),
            let role = guild.roles[roleId],
            let member = guild.members[userId],
            !member.user.bot,
            member.roleIds.contains(roleId) {
            log.info("Removing role \(role.name) upon reaction from \(member.displayName)")
            do {
                try await sink.removeGuildMemberRole(roleId, from: userId, on: guild.id, reason: "Reaction")
            } catch {
                log.warning("Could not remove role \(role.name) upon reaction from \(member.displayName)")
            }
        }
    }
}
