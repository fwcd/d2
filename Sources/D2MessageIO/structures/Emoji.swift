public struct Emoji: Hashable {
	public let id: EmojiID?
	public let managed: Bool
	public let animated: Bool
	public let name: String
	public let requireColons: Bool
	public let roles: [RoleID]
	
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
