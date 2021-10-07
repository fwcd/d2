import D2MessageIO

public struct PronounRoleConfiguration: Codable {
    public var pronounRoles: [GuildID: RoleID] = [:]

    public init() {}
}
