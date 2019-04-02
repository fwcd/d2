public protocol Multiplayer {
	var players: [GamePlayer] { get }
	
	init(players: [GamePlayer])
}

extension GameState where Self: Multiplayer, Self.Role == Int {
	public init(firstPlayer: GamePlayer, secondPlayer: GamePlayer) {
		self.init(players: [firstPlayer, secondPlayer])
	}
	
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
