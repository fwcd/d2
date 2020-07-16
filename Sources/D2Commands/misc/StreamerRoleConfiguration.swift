import D2MessageIO

public struct StreamerRoleConfiguration: Codable {
    public var streamerRoles: [GuildID: RoleID] = [:]

    public init() {}
}
