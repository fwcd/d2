import D2Commands
import D2Utils
import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Handlers.StreamerRoleHandler")

// TODO: Note that the Discord API currently (as of July 2020) does not emit
//       presence updates/activities for Twitch streams (possibly only for
//       Discord's Go Live streams.)

public struct StreamerRoleHandler: PresenceHandler {
    @AutoSerializing private var streamerRoleConfiguration: StreamerRoleConfiguration

    public init(streamerRoleConfiguration: AutoSerializing<StreamerRoleConfiguration>) {
        self._streamerRoleConfiguration = streamerRoleConfiguration
    }

	public func handle(presenceUpdate presence: Presence, client: MessageClient) {
        log.trace("Presence activities: \(presence.activities)")
        if
            let roleId = streamerRoleConfiguration.streamerRoles[presence.guildId],
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
