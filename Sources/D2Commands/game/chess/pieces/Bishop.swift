import Utils

public struct Bishop: ChessPiece {
    public let pieceType: ChessPieceType = .bishop
    public let notationLetters: [Character] = ["B", "L"]
    public let blackResourcePng: String = "Resources/chess/blackBishop.png"
    public let whiteResourcePng: String = "Resources/chess/whiteBishop.png"
    public let value: Int = 3

    public func possibleMoves(from position: Vec2<Int>, board: ChessBoardModel, role: ChessRole, moved: Bool, isInCheck: Bool) -> [ChessMove] {
        return [Vec2(x: -1, y: -1), Vec2(x: 1, y: 1), Vec2(x: 1, y: -1), Vec2(x: -1, y: 1)]
            .flatMap { moves(into: $0, from: position, by: pieceType, color: role, board: board) }
    }
}
