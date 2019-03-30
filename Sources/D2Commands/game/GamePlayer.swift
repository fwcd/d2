import SwiftDiscord

/** An "actual" player representing a DiscordUser. */
public struct GamePlayer: Hashable {
	public let username: String
	public let id: UserID
	
	public init(from user: DiscordUser) {
		self.init(username: user.username, id: user.id)
	}
	
	public init(username: String, id: UserID = UserID(0)) {
		self.username = username
		self.id = id
	}
}
