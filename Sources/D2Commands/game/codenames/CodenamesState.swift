import D2MessageIO
import D2Permissions

public struct CodenamesState: GameState, Multiplayer {
    private static let minPlayerCount = 4

    public typealias Role = CodenamesRole
    public typealias Board = CodenamesBoard
    public typealias Move = CodenamesMove

    private let rolePlayers: [Role: [GamePlayer]]
    public var players: [GamePlayer] { rolePlayers.values.flatMap { $0 } }
    public private(set) var board = Board()
    public private(set) var currentRole: Role = .team(.red)

    public var possibleMoves: Set<Move> {
        return [] // TODO
    }

    public var winner: Role? { nil } // TODO
    public var isDraw: Bool { false }

    public init(players: [GamePlayer]) throws {
        guard players.count >= Self.minPlayerCount else { throw GameError.invalidPlayerCount("Too few players for Codenames, requires at least \(Self.minPlayerCount) (preferably an even number of players for fairness).") }

        // The first player in each team is assigned the spymaster
        // For more details, see the helpText in CodenamesGame
        let half = players.count / 2
        rolePlayers = [
            .team(.red): Array(players[..<half]),
            .team(.blue): Array(players[half...]),
            .spymaster: [players[0], players[half]]
        ]
    }

    public mutating func perform(move: Move, by role: Role) throws {
        // TODO
    }

    public func playerOf(role: Role) -> GamePlayer? {
        // TODO
        rolePlayers[role]?.first
    }

    public func rolesOf(player: GamePlayer) -> [Role] {
        rolePlayers.filter { $0.value.contains(player) }.map(\.key)
    }
}
