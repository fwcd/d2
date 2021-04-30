import Utils

fileprivate let defaultSideLength = 8

public struct ChessBoardModel {
    public typealias Piece = BoardPiece

    public private(set) var pieces: [[Piece?]]
    public var ranks: Int { pieces.count }
    public var files: Int { pieces[0].count }
    public var positions: [Vec2<Int>] { (0..<ranks).flatMap { y in (0..<files).map { Vec2(x: $0, y: y) } } }

    public var pieceTypes: [[BoardPieceType?]] {
        pieces.map { row in row.map { $0?.asPieceType } }
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
        ChessBoardModel(pieces: Array(repeating: Array<Piece?>(repeating: nil, count: defaultSideLength), count: defaultSideLength))
    }

    public func totalValue(for role: ChessRole) -> Int {
        pieces.map { $0.filter { $0?.color == role }.compactMap(\.?.piece.value).reduce(0, +) }.reduce(0, +)
    }

    public subscript(_ position: Vec2<Int>) -> Piece? {
        get { pieces[position.y][position.x] }
        set { pieces[position.y][position.x] = newValue }
    }

    public subscript(_ y: Int, _ x: Int) -> Piece? {
        get { pieces[y][x] }
        set { pieces[y][x] = newValue }
    }
}
