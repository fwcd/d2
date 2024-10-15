import D2MessageIO

public struct PronounRoleConfiguration: Sendable, Codable {
    public var pronounRoles: [GuildID: [String: RoleID]] = [:]

    public init() {}
}
