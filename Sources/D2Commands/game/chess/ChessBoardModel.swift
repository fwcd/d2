import D2Utils

fileprivate let defaultSideLength = 8

public struct ChessBoardModel {
    public typealias Piece = BoardPiece

    public private(set) var pieces: [[Piece?]]
    public var ranks: Int { return pieces.count }
    public var files: Int { return pieces[0].count }

    public var positions: [Vec2<Int>] { return (0..<ranks).flatMap { y in (0..<files).map { Vec2(x: $0, y: y) } } }

    public var pieceTypes: [[BoardPieceType?]] {
        return pieces.map { row in row.map { $0?.asPieceType } }
    }

    public init() {
        pieces = [
            [Piece(.black, Rook()), Piece(.black, Knight()), Piece(.black, Bishop()), Piece(.black, Queen()), Piece(.black, King()), Piece(.black, Bishop()), Piece(.black, Knight()), Piece(.black, Rook())],
            Array(repeating: Piece(.black, Pawn()), count: defaultSideLength),
            Array(repeating: nil, count: defaultSideLength),
            Array(repeating: nil, count: defaultSideLength),
            Array(repeating: nil, count: defaultSideLength),
            Array(repeating: nil, count: defaultSideLength),
            Array(repeating: Piece(.white, Pawn()), count: defaultSideLength),
            [Piece(.white, Rook()), Piece(.white, Knight()), Piece(.white, Bishop()), Piece(.white, Queen()), Piece(.white, King()), Piece(.white, Bishop()), Piece(.white, Knight()), Piece(.white, Rook())]
        ]
    }

    public init(pieces: [[Piece?]]) {
        self.pieces = pieces
    }

    public static func empty() -> ChessBoardModel {
        return ChessBoardModel(pieces: Array(repeating: Array<Piece?>(repeating: nil, count: defaultSideLength), count: defaultSideLength))
    }

    public subscript(position: Vec2<Int>) -> Piece? {
        get { return pieces[position.y][position.x] }
        set(newValue) { pieces[position.y][position.x] = newValue }
    }

    /** Performs a disambiguated move. */
    mutating func perform(move: ChessMove) throws {
        guard let originX = move.originX else { throw GameError.incompleteMove("ChessBoard.perform(move:) requires the move to have an origin file: `\(move)`") }
        guard let originY = move.originY else { throw GameError.incompleteMove("ChessBoard.perform(move:) requires the move to have an origin rank: `\(move)`") }
        guard let destinationX = move.destinationX else { throw GameError.incompleteMove("ChessBoard.perform(move:) requires the move to have a destination file: `\(move)`") }
        guard let destinationY = move.destinationY else { throw GameError.incompleteMove("ChessBoard.perform(move:) requires the move to have a destination rank: `\(move)`") }

        guard destinationX >= 0 && destinationX < files else { throw GameError.moveOutOfBounds("Destination x (\(destinationX)) is out of bounds: `\(move)`") }
        guard destinationY >= 0 && destinationY < ranks else { throw GameError.moveOutOfBounds("Destination y (\(destinationY)) is out of bounds: `\(move)`") }
        guard originX >= 0 && originX < files else { throw GameError.moveOutOfBounds("Origin x (\(originX)) is out of bounds: `\(move)`") }
        guard originY >= 0 && originY < ranks else { throw GameError.moveOutOfBounds("Origin y (\(originY)) is out of bounds: `\(move)`") }

        var piece = pieces[originY][originX]
        piece?.moveCount += 1

        if let promotionPieceType = move.promotionPieceType {
            piece?.piece = createPiece(promotionPieceType)
        }

        pieces[destinationY][destinationX] = piece
        pieces[originY][originX] = nil

        for associatedCapture in move.associatedCaptures {
            self[associatedCapture] = nil
        }

        for associatedMove in move.associatedMoves {
            try perform(move: associatedMove)
        }
    }
}
