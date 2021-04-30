import D2MessageIO

/// An "actual" player representing a User.
public struct GamePlayer: Hashable {
    public let username: String
    public let id: UserID
    public let isUser: Bool
    public let isAutomatic: Bool

    public init(from user: User, isAutomatic: Bool) {
        self.init(username: user.username, id: user.id, isUser: !user.bot, isAutomatic: isAutomatic)
    }

    public init(username: String, id: UserID = dummyId, isUser: Bool = true, isAutomatic: Bool) {
        self.username = username
        self.id = id
        self.isUser = isUser
        self.isAutomatic = isAutomatic
    }
}
