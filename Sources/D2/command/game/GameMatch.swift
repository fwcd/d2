import SwiftDiscord
import D2Utils

/**
 * Represents a game match. It is strongly recommended
 * for implementors to also adopt CustomStringConvertible.
 */
protocol GameMatch {
	associatedtype Role
	associatedtype Board: GameBoard where Board.Role == Role
	associatedtype Move: GameMove
	
	var board: Board { get }
	var currentRole: Role { get set }
	
	init(firstPlayer: DiscordUser, secondPlayer: DiscordUser)
	
	func rolesOf(player: DiscordUser) -> [Role]
	
	func playerOf(role: Role) -> DiscordUser?
	
	func perform(move: Move) throws
}
