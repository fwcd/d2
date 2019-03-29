import SwiftDiscord
import D2Utils

/**
 * Represents a mutable game state. It is strongly recommended
 * for implementors to also adopt CustomStringConvertible.
 */
protocol GameMatch {
	/** A role is a logical player in the game (such as "white" or "black"). */
	associatedtype Role
	/** A hand encapsulates a role's private cards/pieces/... in games with imperfect information. */
	associatedtype Hand: DiscordEncodable = EmptyDiscordEncodable
	/** A board contains the pieces/cards that are visible to all players. */
	associatedtype Board: GameBoard where Board.Role == Role
	/** A move encapsulates the transition to another game state. */
	associatedtype Move: GameMove
	
	var board: Board { get }
	var currentRole: Role { get }
	var hands: [Role: Hand] { get }
	
	init(firstPlayer: DiscordUser, secondPlayer: DiscordUser)
	
	func rolesOf(player: DiscordUser) -> [Role]
	
	func playerOf(role: Role) -> DiscordUser?
	
	func perform(move: Move) throws
}

extension GameMatch {
	var hands: [Role: Hand] { return [:] }
}
