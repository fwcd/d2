import D2Commands
import Utils
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

    public func handle(presenceUpdate presence: Presence, client: any MessageIOSink) {
        log.trace("Presence activities: \(presence.activities)")
        guard let guildId = presence.guildId else { return }
        if
            let roleId = streamerRoleConfiguration.streamerRoles[guildId],
            let guild = client.guild(for: guildId),
            let member = guild.members[presence.user.id] {
            if presence.activities.contains(where: { $0.type == .stream }) {
                if !member.roleIds.contains(roleId) {
                    log.info("Adding streamer role to \(member.displayName)")
                    client.addGuildMemberRole(roleId, to: presence.user.id, on: guildId, reason: "Streaming").listenOrLogError { success in
                        if !success {
                            log.warning("Adding streamer role to \(member.displayName) failed")
                        }
                    }
                } else {
                    log.debug("Not adding streamer role, \(member.displayName) already has it!")
                }
            } else if member.roleIds.contains(roleId) {
                log.info("Removing streamer role from \(member.displayName)")
                client.removeGuildMemberRole(roleId, from: presence.user.id, on: guildId, reason: "No longer streaming")
            } else {
                log.debug("Not removing streamer role from \(member.displayName).")
            }
        }
    }
}
