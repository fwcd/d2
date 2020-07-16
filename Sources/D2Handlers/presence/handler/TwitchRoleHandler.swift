import D2Commands
import D2Utils
import D2MessageIO

public struct TwitchRoleHandler: PresenceHandler {
    private let twitchRoleConfiguration: AutoSerializing<TwitchRoleConfiguration>

    public init(twitchRoleConfiguration: AutoSerializing<TwitchRoleConfiguration>) {
        self.twitchRoleConfiguration = twitchRoleConfiguration
    }

	public func handle(presenceUpdate presence: Presence, client: MessageClient) {
        if
            let roleId = twitchRoleConfiguration.wrappedValue.twitchRoles[presence.guildId],
            let guild = client.guild(for: presence.guildId),
            let member = guild.members[presence.user.id] {
            if presence.game?.type == .stream {
                if !member.roleIds.contains(roleId) {
                    client.addGuildMemberRole(roleId, to: presence.user.id, on: presence.guildId, reason: "Streaming")
                }
            } else if member.roleIds.contains(roleId) {
                client.removeGuildMemberRole(roleId, from: presence.user.id, on: presence.guildId, reason: "No longer streaming")
            }
        }
    }
}
