import D2MessageIO
import D2Permissions

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
    
    public var winner: Role? = nil
    public let isDraw: Bool = false
    
    public init(players: [GamePlayer]) {
        self.players = players
    }
    
    public mutating func perform(move: Move, by role: Role) throws {
        try board.guess(word: move.word)
        if board.isUncovered && winner == nil {
            winner = role
        }
    }
}
