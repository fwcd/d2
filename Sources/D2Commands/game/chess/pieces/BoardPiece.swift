public struct BoardPiece {
    public let color: ChessRole
    public var piece: any ChessPiece
    public var moveCount: Int
    public var moved: Bool { moveCount > 0 }

    public var resourcePng: String { (color == .white) ? piece.whiteResourcePng : piece.blackResourcePng }

    public init(_ color: ChessRole, _ piece: any ChessPiece, moveCount: Int = 0) {
        self.color = color
        self.piece = piece
        self.moveCount = moveCount
    }
}
