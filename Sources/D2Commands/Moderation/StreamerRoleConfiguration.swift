import D2MessageIO

public struct StreamerRoleConfiguration: Sendable, Codable {
    public var streamerRoles: [GuildID: RoleID] = [:]

    public init() {}
}
