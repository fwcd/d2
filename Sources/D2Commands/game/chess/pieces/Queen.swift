import Utils

public struct Queen: ChessPiece {
    public let pieceType: ChessPieceType = .queen
    public let notationLetters: [Character] = ["Q", "D"]
    public let blackResourcePng: String = "Resources/chess/blackQueen.png"
    public let whiteResourcePng: String = "Resources/chess/whiteQueen.png"
    public let value: Int = 9

    public func possibleMoves(from position: Vec2<Int>, board: ChessBoardModel, role: ChessRole, moved: Bool, isInCheck: Bool) -> [ChessMove] {
        return neighborFields()
            .flatMap { moves(into: $0, from: position, by: pieceType, color: role, board: board) }
    }
}
