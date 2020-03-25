import D2MessageIO

/** An "actual" player representing a User. */
public struct GamePlayer: Hashable {
	public let username: String
	public let id: UserID
	public let isUser: Bool
	
	public init(from user: User) {
		self.init(username: user.username, id: user.id, isUser: !user.bot)
	}
	
	public init(username: String, id: UserID, isUser: Bool = true) {
		self.username = username
		self.id = id
		self.isUser = isUser
	}
}
