import Foundation
import SwiftDiscord

public struct TicTacToeState: GameState, CustomStringConvertible {
	public typealias Role = TicTacToeRole
	public typealias Board = TicTacToeBoard
	public typealias Move = TicTacToeMove
	
	private let playerX: DiscordUser?
	private let playerO: DiscordUser?
	public private(set) var board = Board()
	public private(set) var currentRole: Role = .x
	public var description: String { return "`\(playerX?.username ?? "?")` as :x: vs. `\(playerO?.username ?? "?")` as :o:" }
	
	public init(firstPlayer: DiscordUser?, secondPlayer: DiscordUser?) {
		playerX = firstPlayer
		playerO = secondPlayer
	}
	
	public mutating func perform(move: Move) throws {
		try performMoveAt(row: move.row, col: move.column)
	}
	
	private mutating func performMoveAt(row: Int, col: Int) throws {
		let next = try board.with(currentRole, atRow: row, col: col)
		board = next
		currentRole = currentRole.opponent
	}
	
	public func playerOf(role: Role) -> DiscordUser? {
		switch role {
			case .x: return playerX
			case .o: return playerO
			default: return nil
		}
	}
	
	public func rolesOf(player: DiscordUser) -> [Role] {
		var roles = [Role]()
		
		if playerX?.id == player.id { roles.append(.x) }
		if playerO?.id == player.id { roles.append(.o) }
		
		return roles
	}
}
