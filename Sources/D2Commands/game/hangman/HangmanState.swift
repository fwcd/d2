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
        Set()
    }
    
    public private(set) var winner: Role? = nil
    public private(set) var isDraw: Bool = false
    
    public init(players: [GamePlayer]) {
        self.players = players
    }
    
    public mutating func perform(move: Move) throws {
        try board.guess(word: move.word)
    }
}
