import D2Commands
import D2Utils
import D2MessageIO

public struct TwitchRoleHandler: PresenceHandler {
    private let twitchRoleConfiguration: AutoSerializing<TwitchRoleConfiguration>

    public init(twitchRoleConfiguration: AutoSerializing<TwitchRoleConfiguration>) {
        self.twitchRoleConfiguration = twitchRoleConfiguration
    }

	public func handle(presenceUpdate presence: Presence, client: MessageClient) {
        if presence.game?.type == .stream, let roleId = twitchRoleConfiguration.wrappedValue.twitchRoles[presence.guildId] {
            client.addGuildMemberRole(roleId, to: presence.user.id, on: presence.guildId, reason: "Streaming")
        }
    }
}
