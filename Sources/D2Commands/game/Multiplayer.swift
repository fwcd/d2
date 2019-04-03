/**
 * A protocol that is intended for games with
 * more than two players where storing each
 * player in an individual field does not make
 * sense.
 */
public protocol Multiplayer {
	var players: [GamePlayer] { get }
}

extension GameState where Self: Multiplayer, Self.Role == Int {
	public func playerOf(role: Role) -> GamePlayer? {
		return players[safely: role]
	}
	
	public func rolesOf(player: GamePlayer) -> [Role] {
		return players.allIndices(of: player)
	}
}

extension GameState where Self: Multiplayer, Self.Role == Int {
	public var playersDescription: String { return players.map { "`\($0.username)`" }.joined(separator: " vs. ") }
}
