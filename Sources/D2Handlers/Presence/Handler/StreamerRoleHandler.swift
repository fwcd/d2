import D2Commands
import Utils
import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Handlers.StreamerRoleHandler")

// TODO: Note that the Discord API currently (as of July 2020) does not emit
//       presence updates/activities for Twitch streams (possibly only for
//       Discord's Go Live streams.)

public struct StreamerRoleHandler: PresenceHandler {
    @Binding private var streamerRoleConfiguration: StreamerRoleConfiguration

    public init(@Binding streamerRoleConfiguration: StreamerRoleConfiguration) {
        self._streamerRoleConfiguration = _streamerRoleConfiguration
    }

    public func handle(presenceUpdate presence: Presence, sink: any Sink) async {
        log.trace("Presence activities: \(presence.activities)")
        guard let guildId = presence.guildId else { return }
        if
            let roleId = streamerRoleConfiguration.streamerRoles[guildId],
            let guild = await sink.guild(for: guildId),
            let member = guild.members[presence.user.id] {
            if presence.activities.contains(where: { $0.type == .stream }) {
                guard !member.roleIds.contains(roleId) else {
                    log.debug("Not adding streamer role, \(member.displayName) already has it!")
                    return
                }

                log.info("Adding streamer role to \(member.displayName)")
                do {
                    try await sink.addGuildMemberRole(roleId, to: presence.user.id, on: guildId, reason: "Streaming")
                } catch {
                    log.warning("Adding streamer role to \(member.displayName) failed: \(error)")
                }
            } else if member.roleIds.contains(roleId) {
                log.info("Removing streamer role from \(member.displayName)")
                do {
                    try await sink.removeGuildMemberRole(roleId, from: presence.user.id, on: guildId, reason: "No longer streaming")
                } catch {
                    log.warning("Removing streamer role from \(member.displayName) failed: \(error)")
                }
            } else {
                log.debug("Not removing streamer role from \(member.displayName).")
            }
        }
    }
}
