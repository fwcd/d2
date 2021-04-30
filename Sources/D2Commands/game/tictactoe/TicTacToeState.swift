import Foundation
import D2MessageIO

public struct TicTacToeState: GameState, FinitePossibleMoves {
    public typealias Role = TicTacToeRole
    public typealias Board = TicTacToeBoard
    public typealias Move = TicTacToeMove

    private let playerX: GamePlayer
    private let playerO: GamePlayer
    public private(set) var board = Board()
    public private(set) var currentRole: Role = .x
    public var playersDescription: String { return "`\(playerX.username)` as :x: vs. `\(playerO.username)` as :o:" }

    public var winner: Role? { return board.winner }
    public var isDraw: Bool { return board.isDraw }

    public var possibleMoves: Set<Move> {
        return Set((0..<board.sideLength)
            .flatMap { row in (0..<board.sideLength).map { column in Move(row: row, column: column) } }
            .filter { move in board[move.row, move.column] == .empty })
    }

    public init(playerX: GamePlayer, playerO: GamePlayer) {
        self.playerX = playerX
        self.playerO = playerO
    }

    public init(players: [GamePlayer]) {
        self.init(playerX: players[0], playerO: players[1])
    }

    public mutating func perform(move: Move, by role: Role, options: GameMoveOptions) throws {
        try performMoveAt(row: move.row, col: move.column)
    }

    private mutating func performMoveAt(row: Int, col: Int) throws {
        let next = try board.with(currentRole, atRow: row, col: col)
        board = next
        currentRole = currentRole.opponent
    }

    public func playersOf(role: Role) -> [GamePlayer] {
        switch role {
            case .x: return [playerX]
            case .o: return [playerO]
            default: return []
        }
    }

    public func rolesOf(player: GamePlayer) -> [Role] {
        var roles = [Role]()

        if playerX == player { roles.append(.x) }
        if playerO == player { roles.append(.o) }

        return roles
    }
}
