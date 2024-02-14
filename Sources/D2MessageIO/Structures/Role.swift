public struct Role {
    public let id: RoleID
    public let color: Int
    public let hoist: Bool
    public let managed: Bool
    public let mentionable: Bool
    public let name: String
    public let position: Int

    public init(
        id: RoleID,
        color: Int,
        hoist: Bool,
        managed: Bool,
        mentionable: Bool,
        name: String,
        position: Int
    ) {
        self.id = id
        self.color = color
        self.hoist = hoist
        self.managed = managed
        self.mentionable = mentionable
        self.name = name
        self.position = position
    }

    public static func ==(lhs: Role, rhs: Role) -> Bool {
        return lhs.id == rhs.id
    }
}
