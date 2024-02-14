public struct WordleState: GameState, Multiplayer, FinitePossibleMoves {
    public typealias Role = Int
    public typealias Board = WordleBoard
    public typealias Move = WordleMove

    public let players: [GamePlayer]
    private let solution: String = Words.wordlePossible.randomElement() ?? "error"
    public private(set) var board = Board()
    public private(set) var currentRole: Role = 0
    public private(set) var winner: Role? = nil

    public var isDraw: Bool { false }

    public var possibleMoves: Set<Move> {
        Set(Words.wordleAllowed.map(Move.init(fromString:)))
    }

    public init(players: [GamePlayer]) {
        self.players = players
    }

    public mutating func perform(move: Move, by role: Role, options: GameMoveOptions) throws {
        try board.guess(word: move.word, solution: solution)
        if board.isWon {
            winner = role
        }
    }
}
