import D2Commands
import D2Utils
import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Handlers.TwitchRoleHandler")

public struct TwitchRoleHandler: PresenceHandler {
    private let twitchRoleConfiguration: AutoSerializing<TwitchRoleConfiguration>

    public init(twitchRoleConfiguration: AutoSerializing<TwitchRoleConfiguration>) {
        self.twitchRoleConfiguration = twitchRoleConfiguration
    }

	public func handle(presenceUpdate presence: Presence, client: MessageClient) {
        log.trace("Presence activities: \(presence.activities)")
        if
            let roleId = twitchRoleConfiguration.wrappedValue.twitchRoles[presence.guildId],
            let guild = client.guild(for: presence.guildId),
            let member = guild.members[presence.user.id] {
            if presence.activities.contains(where: { $0.type == .stream }) {
                if !member.roleIds.contains(roleId) {
                    log.info("Adding streamer role to \(presence.user.username)")
                    client.addGuildMemberRole(roleId, to: presence.user.id, on: presence.guildId, reason: "Streaming")
                } else {
                    log.debug("Not adding streamer role, \(member.displayName) is already streaming!")
                }
            } else if member.roleIds.contains(roleId) {
                log.debug("Removing streamer role from \(member.displayName)")
                client.removeGuildMemberRole(roleId, from: presence.user.id, on: presence.guildId, reason: "No longer streaming")
            } else {
                log.debug("Not removing streamer role from \(member.displayName).")
            }
        }
    }
}
