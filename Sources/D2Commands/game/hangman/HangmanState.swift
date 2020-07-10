import D2MessageIO
import D2Permissions

fileprivate let initialPlayerTries: Int = 6

public struct HangmanState: GameState, Multiplayer {
    public typealias Role = Int
    public typealias Board = HangmanBoard
    public typealias Move = HangmanMove
    
	public let players: [GamePlayer]
    public private(set) var board = Board(word: "test")
    public private(set) var currentRole: Role = 0
    
    public var possibleMoves: Set<Move> {
        Set((board.word.map(String.init) + [board.word]).map(Move.init(fromString:)))
    }
    
    public private(set) var winner: Role? = nil
    public private(set) var isDraw: Bool = false
    
    public private(set) var remainingTries: [Role: Int]
    public var remainingRoleCount: Int { remainingTries.count(forWhich: { (_, v) in v > 0 }) }

    public init(players: [GamePlayer]) {
        self.players = players
        remainingTries = Dictionary(uniqueKeysWithValues: (0..<players.count).map { ($0, initialPlayerTries) })
    }
    
    public mutating func perform(move: Move, by role: Role) throws {
        try board.guess(word: move.word)
        if board.isUncovered && winner == nil {
            winner = role
        }
    }

    public func hasTriesLeft(role: Role) -> Bool {
        guard let tries = remainingTries[role] else { return false }
        return tries > 0
    }

	public func isPossible(move: Move, by role: Role) -> Bool {
        return possibleMoves.contains(move) && hasTriesLeft(role: role)
    }

    public mutating func penalize(role: Role) throws {
        guard let tries = remainingTries[role] else { throw HangmanError.invalidRole("Role \(role) cannot be penalized since it has no associated try count!") }
        remainingTries[role] = max(0, tries - 1)
        if remainingRoleCount == 0 {
            isDraw = true
        }
    }
}
