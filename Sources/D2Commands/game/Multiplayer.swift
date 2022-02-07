import Utils

/// A protocol that is intended for games with
/// a flexible number of players where storing two
/// players in individual fields does not make
/// sense.
public protocol Multiplayer {
    var players: [GamePlayer] { get }
}

extension GameState where Self: Multiplayer, Self.Role == Int {
    public func playersOf(role: Role) -> [GamePlayer] {
        [players[safely: role]].compactMap { $0 }
    }

    public func rolesOf(player: GamePlayer) -> [Role] {
        players.allIndices(of: player)
    }
}

extension GameState where Self: Multiplayer {
    public var playersDescription: String { return players.map { "`\($0.username)`" }.joined(separator: " vs. ") }
}
