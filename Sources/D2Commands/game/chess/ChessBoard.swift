import Utils
import Graphics

public struct ChessBoard: RichValueConvertible {
    public var model: ChessBoardModel
    public var asRichValue: RichValue { return ChessBoardView(model: model).image.map { RichValue.image($0) } ?? .none }

    public init(model: ChessBoardModel = ChessBoardModel()) {
        self.model = model
    }

    public init(pieces: [ChessBoardModel.Piece?]) {
        self.init(model: ChessBoardModel(pieces: pieces))
    }

    public static func empty() -> ChessBoard {
        ChessBoard(model: ChessBoardModel.empty())
    }

    /// Performs a disambiguated move.
    mutating func perform(move: ChessMove) throws {
        guard let originX = move.originX else { throw GameError.incompleteMove("ChessBoard.perform(move:) requires the move to have an origin file: `\(move)`") }
        guard let originY = move.originY else { throw GameError.incompleteMove("ChessBoard.perform(move:) requires the move to have an origin rank: `\(move)`") }
        guard let destinationX = move.destinationX else { throw GameError.incompleteMove("ChessBoard.perform(move:) requires the move to have a destination file: `\(move)`") }
        guard let destinationY = move.destinationY else { throw GameError.incompleteMove("ChessBoard.perform(move:) requires the move to have a destination rank: `\(move)`") }

        guard destinationX >= 0 && destinationX < ChessBoardModel.files else { throw GameError.moveOutOfBounds("Destination x (\(destinationX)) is out of bounds: `\(move)`") }
        guard destinationY >= 0 && destinationY < ChessBoardModel.ranks else { throw GameError.moveOutOfBounds("Destination y (\(destinationY)) is out of bounds: `\(move)`") }
        guard originX >= 0 && originX < ChessBoardModel.files else { throw GameError.moveOutOfBounds("Origin x (\(originX)) is out of bounds: `\(move)`") }
        guard originY >= 0 && originY < ChessBoardModel.ranks else { throw GameError.moveOutOfBounds("Origin y (\(originY)) is out of bounds: `\(move)`") }

        var piece = model[originY, originX]
        piece?.moveCount += 1

        if let promotionPieceType = move.promotionPieceType {
            piece?.piece = createPiece(promotionPieceType)
        }

        model[destinationY, destinationX] = piece
        model[originY, originX] = nil

        for associatedCapture in move.associatedCaptures {
            model[associatedCapture] = nil
        }

        for associatedMove in move.associatedMoves {
            try perform(move: associatedMove)
        }
    }
}
