public struct Emoji: Sendable, Hashable, CustomStringConvertible {
    public let id: EmojiID?
    public let managed: Bool
    public let animated: Bool
    public let name: String
    public let requireColons: Bool
    public let roles: [RoleID]

    /// Uses the standard syntax for custom emojis on Discord.
    public var description: String { id.map { "<\(animated ? "a" : ""):\(name):\($0)>" } ?? name }
    /// Uses the alternate syntax for custom emojis on Discord that is used by the createReaction endpoint.
    public var compactDescription: String { id.map { "\(name):\($0)" } ?? name }

    public init(
        id: EmojiID? = nil,
        managed: Bool,
        animated: Bool,
        name: String,
        requireColons: Bool,
        roles: [RoleID] = []
    ) {
        self.id = id
        self.managed = managed
        self.animated = animated
        self.name = name
        self.requireColons = requireColons
        self.roles = roles
    }
}
