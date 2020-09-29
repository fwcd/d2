import Utils

public struct Pawn: ChessPiece {
    public let pieceType: ChessPieceType = .pawn
    public let notationLetters: [Character] = []
    public let blackResourcePng: String = "Resources/chess/blackPawn.png"
    public let whiteResourcePng: String = "Resources/chess/whitePawn.png"

    public func possibleMoves(from position: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole, moved: Bool, isInCheck: Bool) -> [ChessMove] {
        let direction: Int = moveYDirection(for: role)
        let captureMoves: [Vec2<Int>] = [position + Vec2(x: -1, y: direction), position + Vec2(x: 1, y: direction)]
        var forwardMoves: [Vec2<Int>] = [position + Vec2(y: direction)]

        if !moved {
            forwardMoves.append(position + Vec2(y: 2 * direction))
        }

        return forwardMoves.filter { board.piece(at: $0) == nil }.flatMap {
            // Create forward moves
            movesWithPromotions(from: position, to: $0, board: board, role: role)
        } + captureMoves.filter { canCapture($0, board: board, role: role) }.flatMap { destination -> [ChessMove] in
            // Create capturing moves
            let isEnPassant = canPerformEnPassant(at: destination, board: board, role: role)
            if isEnPassant {
                return [ChessMove(
                    pieceType: pieceType,
                    color: role,
                    originX: position.x,
                    originY: position.y,
                    isCapture: true,
                    destinationX: destination.x,
                    destinationY: destination.y,
                    isEnPassant: isEnPassant,
                    associatedCaptures: isEnPassant ? [destination + Vec2(y: -direction)] : []
                )]
            } else {
                return movesWithPromotions(from: position, to: destination, board: board, role: role)
            }
        }
    }

    private func movesWithPromotions(from position: Vec2<Int>, to destination: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole) -> [ChessMove] {
        let isPromotion = isFinalRank(y: destination.y, for: role, totalRanks: board.count)
        let promotionPieceTypes: [ChessPieceType?] = isPromotion ? ChessPieceType.allCases : [nil]
        return promotionPieceTypes
            .map { ChessMove(
                pieceType: pieceType,
                color: role,
                originX: position.x,
                originY: position.y,
                isCapture: false,
                destinationX: destination.x,
                destinationY: destination.y,
                promotionPieceType: $0,
                isEnPassant: false
            ) }
    }

    private func isFinalRank(y: Int, for role: ChessRole, totalRanks: Int) -> Bool {
        return ((y == 0) && (role == .white)) || ((y == (totalRanks - 1)) && (role == .black))
    }

    private func moveYDirection(for role: ChessRole) -> Int {
        return (role == .black) ? 1 : -1
    }

    private func canCapture(_ destination: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole) -> Bool {
        return (board.piece(at: destination)?.color == role.opponent) || canPerformEnPassant(at: destination, board: board, role: role)
    }

    private func canPerformEnPassant(at destination: Vec2<Int>, board: [[BoardPieceType?]], role: ChessRole) -> Bool {
        let enPassantPos = destination + Vec2(y: moveYDirection(for: role.opponent))
        guard enPassantPos.y == 3 || enPassantPos.y == 4 else { return false }

        let captured = board.piece(at: enPassantPos)
        return captured?.pieceType == .pawn && captured?.color == role.opponent && captured?.moveCount == 1
    }
}
