import Utils

/** Encapsulates an unpositioned chess piece. */
public protocol ChessPiece {
    var pieceType: ChessPieceType { get }
    var blackResourcePng: String { get }
    var whiteResourcePng: String { get }

    /**
    * Contains possible notation letters. The preferred letter
    * (which is used for encoding) should be at the first position,
    * if present.
    */
    var notationLetters: [Character] { get }

    /**
    * Fetches the possible moves of this piece.
    *
    * Each move is *required* to contain at least pieceType, color,
    * originX, originY, destinationX and destinationY.
    *
    * The implementor neither has to check if all moves are
    * in the bounds of the board, nor whether
    * the given move would result in a check. He is not
    * required to check for captures either, though the
    * 'isCapture' option can be overridden if specified.
    */
    func possibleMoves(from position: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole, moved: Bool, isInCheck: Bool) -> [ChessMove]
}
