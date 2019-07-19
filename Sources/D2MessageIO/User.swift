public struct User: Codable {
	public let avatar: String // Base64-encoded
	public let bot: Bool
	public let discriminator: String
	public let email: String
	public let id: UserID
	public let mfaEnabled: Bool
	public let username: String
	public let verified: Bool
	
	public init(avatar: String, bot: Bool, discriminator: String, email: String, id: UserID, mfaEnabled: Bool, username: String, verified: Bool) {
		self.avatar = avatar
		self.bot = bot
		self.discriminator = discriminator
		self.email = email
		self.id = id
		self.mfaEnabled = mfaEnabled
		self.username = username
		self.verified = verified
	}
}
