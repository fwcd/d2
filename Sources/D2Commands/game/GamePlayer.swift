import SwiftDiscord

/** An "actual" player representing a DiscordUser. */
public struct GamePlayer: Hashable {
	public let username: String
	public let id: UserID
	public let isUser: Bool
	
	public init(from user: DiscordUser) {
		self.init(username: user.username, id: user.id, isUser: !user.bot)
	}
	
	public init(username: String, id: UserID = UserID(0), isUser: Bool = true) {
		self.username = username
		self.id = id
		self.isUser = isUser
	}
}
