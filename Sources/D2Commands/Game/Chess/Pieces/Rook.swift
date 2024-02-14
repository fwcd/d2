import Utils

public struct Rook: ChessPiece {
    public let pieceType: ChessPieceType = .rook
    public let notationLetters: [Character] = ["R", "T"]
    public let blackResourcePng: String = "Resources/Chess/blackRook.png"
    public let whiteResourcePng: String = "Resources/Chess/whiteRook.png"
    public let value: Int = 5

    public func possibleMoves(from position: Vec2<Int>, board: ChessBoardModel, role: ChessRole, moved: Bool, isInCheck: Bool) -> [ChessMove] {
        return [Vec2(x: -1), Vec2(x: 1), Vec2(y: -1), Vec2(y: 1)]
            .flatMap { moves(into: $0, from: position, by: pieceType, color: role, board: board) }
    }
}
