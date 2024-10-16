import Utils

public struct ChessBoardModel: Sendable {
    public static let ranks: Int = 8
    public static let files: Int = 8
    public static let positions: [Vec2<Int>] = (0..<Self.ranks).flatMap { y in (0..<Self.files).map { Vec2(x: $0, y: y) } }
    private static let defaultPieces: [Piece?] = [
        [Piece(.black, Rook()), Piece(.black, Knight()), Piece(.black, Bishop()), Piece(.black, Queen()), Piece(.black, King()), Piece(.black, Bishop()), Piece(.black, Knight()), Piece(.black, Rook())],
        [Piece?](repeating: Piece(.black, Pawn()), count: Self.files),
        [Piece?](repeating: nil, count: Self.files),
        [Piece?](repeating: nil, count: Self.files),
        [Piece?](repeating: nil, count: Self.files),
        [Piece?](repeating: nil, count: Self.files),
        [Piece?](repeating: Piece(.white, Pawn()), count: Self.files),
        [Piece(.white, Rook()), Piece(.white, Knight()), Piece(.white, Bishop()), Piece(.white, Queen()), Piece(.white, King()), Piece(.white, Bishop()), Piece(.white, Knight()), Piece(.white, Rook())]
    ].flatMap { $0 }

    public typealias Piece = BoardPiece
    public private(set) var pieces: [Piece?]

    public init() {
        self.init(pieces: Self.defaultPieces)
    }

    public init(pieces: [Piece?]) {
        assert(pieces.count == Self.files * Self.ranks)
        self.pieces = pieces
    }

    public static func empty() -> ChessBoardModel {
        ChessBoardModel(pieces: Array(repeating: nil, count: Self.files * Self.ranks))
    }

    public func totalValue(for role: ChessRole) -> Int {
        pieces.filter { $0?.color == role }.compactMap(\.?.piece.value).reduce(0, +)
    }

    public subscript(_ position: Vec2<Int>) -> Piece? {
        get { self[position.y, position.x] }
        set { self[position.y, position.x] = newValue }
    }

    public subscript(_ y: Int, _ x: Int) -> Piece? {
        get {
            guard isInBounds(y, x) else { return nil }
            return pieces[(y * Self.files) + x]
        }
        set {
            guard isInBounds(y, x) else { fatalError("Tried to assign \(newValue.map { "\($0)" } ?? "?") to out-of-bounds position: y = \(y), x = \(x)") }
            pieces[(y * Self.files) + x] = newValue
        }
    }

    func isInBounds(_ position: Vec2<Int>) -> Bool {
        isInBounds(position.y, position.x)
    }

    func isInBounds(_ y: Int, _ x: Int) -> Bool {
        x >= 0 && y >= 0 && x < Self.files && y < Self.ranks
    }
}
