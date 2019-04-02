import SwiftDiscord
import D2Utils

/**
 * Represents a mutable game state. Implementing classes are
 * required to use a value type (struct/enum/immutable class).
 * It is strongly recommended that implementors also adopt CustomStringConvertible.
 */
public protocol GameState {
	/** A role is a logical player in the game (such as "white" or "black"). */
	associatedtype Role: DiscordStringEncodable & Hashable
	/** A hand encapsulates a role's private cards/pieces/... in games with imperfect information. */
	associatedtype Hand: DiscordEncodable = EmptyDiscordEncodable
	/** A board contains the pieces/cards that are visible to all players. */
	associatedtype Board: DiscordEncodable
	/** A move encapsulates the transition to another game state. */
	associatedtype Move: Hashable
	
	var board: Board { get }
	var currentRole: Role { get }
	var hands: [Role: Hand] { get }
	var possibleMoves: Set<Move> { get }
	
	var winner: Role? { get }
	var isDraw: Bool { get }
	
	init(firstPlayer: GamePlayer, secondPlayer: GamePlayer)
	
	func rolesOf(player: GamePlayer) -> [Role]
	
	func playerOf(role: Role) -> GamePlayer?
	
	func isPossible(move: Move) -> Bool
	
	mutating func perform(move: Move) throws
}

extension GameState {
	public var hands: [Role: Hand] { return [:] }
	
	public func isPossible(move: Move) -> Bool { return possibleMoves.contains(move) }
	
	public func childState(after move: Move) throws -> Self {
		if isPossible(move: move) {
			var next = self
			try next.perform(move: move)
			return next
		} else {
			throw GameError.invalidMove("Move `\(move)` is not in `possibleMoves`")
		}
	}
}
