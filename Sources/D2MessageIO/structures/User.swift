public struct User: Hashable {
    public let avatar: String // Base64-encoded
    public let bot: Bool
    public let discriminator: String
    public let email: String
    public let id: UserID
    public let mfaEnabled: Bool
    public let username: String
    public let verified: Bool

    public init(
        avatar: String = "",
        bot: Bool = false,
        discriminator: String = "",
        email: String = "",
        id: UserID,
        mfaEnabled: Bool = false,
        username: String = "",
        verified: Bool = false
    ) {
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
