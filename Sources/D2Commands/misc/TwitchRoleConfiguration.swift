import D2MessageIO

public struct TwitchRoleConfiguration: Codable {
    public var twitchRoles: [GuildID: RoleID] = [:]

    public init() {}
}
