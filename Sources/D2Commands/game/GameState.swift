import SwiftDiscord
import D2Utils

/**
 * Represents a mutable game state. Implementing classes are
 * required to use a value type (struct/enum/immutable class).
 * It is strongly recommended that implementors also adopt CustomStringConvertible.
 */
public protocol GameState {
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
	
	init(firstPlayer: DiscordUser?, secondPlayer: DiscordUser?)
	
	func rolesOf(player: DiscordUser) -> [Role]
	
	func playerOf(role: Role) -> DiscordUser?
	
	mutating func perform(move: Move) throws
}

extension GameState {
	public var hands: [Role: Hand] { return [:] }
	
	public func childState(after move: Move) throws -> Self {
		var next = self
		try next.perform(move: move)
		return next
	}
}
