import Utils

func createPiece(_ pieceType: ChessPieceType) -> ChessPiece {
    switch pieceType {
        case .pawn: return Pawn()
        case .knight: return Knight()
        case .bishop: return Bishop()
        case .queen: return Queen()
        case .king: return King()
        case .rook: return Rook()
    }
}

func pieceOf(letter: Character) -> ChessPiece? {
    guard let (piece, _) = (ChessPieceType.allCases
        .map { createPiece($0) }
        .map { ($0, $0.notationLetters.firstIndex(of: letter)) }
        .filter { $0.1 != nil }
        .min { $0.1! < $1.1! }) else { return nil }
    return piece
}

func neighborFields() -> [Vec2<Int>] {
    return (-1...1)
        .flatMap { row in (-1...1).map { Vec2(x: $0, y: row) } }
        .filter { $0.x != 0 || $0.y != 0 }
}

func moves(into direction: Vec2<Int>, from position: Vec2<Int>, by pieceType: ChessPieceType, color: ChessRole, board: ChessBoardModel) -> [ChessMove] {
    var moves = [ChessMove]()
    var current = position + direction

    while board.isInBounds(current) && board[current] == nil {
        moves.append(ChessMove(
            pieceType: pieceType,
            color: color,
            originX: position.x,
            originY: position.y,
            isCapture: false,
            destinationX: current.x,
            destinationY: current.y,
            isEnPassant: false
        ))
        current = current + direction
    }

    if board[current] != nil {
        moves.append(ChessMove(
            pieceType: pieceType,
            color: color,
            originX: position.x,
            originY: position.y,
            destinationX: current.x,
            destinationY: current.y,
            isEnPassant: false
        ))
    }

    return moves
}
