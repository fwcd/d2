public struct BoardPieceType: Codable {
    public let color: ChessRole
    public let pieceType: ChessPieceType
    public let moveCount: Int
    public var moved: Bool { return moveCount > 0 }

    public init(_ color: ChessRole, _ pieceType: ChessPieceType, moveCount: Int) {
        self.color = color
        self.pieceType = pieceType
        self.moveCount = moveCount
    }

    public enum CodingKeys: String, CodingKey {
        case color = "c"
        case pieceType = "p"
        case moveCount = "m"
    }
}
