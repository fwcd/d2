public protocol Multiplayer {
	var players: [GamePlayer] { get }
}

extension Multiplayer where Self: GameState, Self.Role == Int {
	public func playerOf(role: Role) -> GamePlayer? {
		return players[safely: role]
	}
	
	public func rolesOf(player: GamePlayer) -> [Role] {
		return players.allIndices(of: player)
	}
}
