import D2MessageIO
import D2Permissions

public struct CodenamesState: GameState, Multiplayer {
    public typealias Role = CodenamesRole
    public typealias Board = CodenamesBoard
    public typealias Move = CodenamesMove

    public let players: [GamePlayer]
    public private(set) var board = Board()
    public private(set) var currentRole: Role = .red

    public var possibleMoves: Set<Move> {
        return [] // TODO
    }

    public var winner: Role? { nil } // TODO
    public var isDraw: Bool { false }

    public init(players: [GamePlayer]) {
        // The first player in each team is assigned the spymaster
        self.players = players
    }

    public mutating func perform(move: Move, by role: Role) throws {
        // TODO
    }

    public func playerOf(role: Role) -> GamePlayer? {
        nil // TODO
    }

    public func rolesOf(player: GamePlayer) -> [Role] {
        [] // TODO
    }
}
