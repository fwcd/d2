import D2Utils
import D2Graphics

public struct ChessBoard: RichValueConvertible {
    public var model: ChessBoardModel
    public var asRichValue: RichValue { return ChessBoardView(model: model).image.map { RichValue.image($0) } ?? .none }

    public init(model: ChessBoardModel = ChessBoardModel()) {
        self.model = model
    }

    public init(pieces: [[ChessBoardModel.Piece?]]) {
        self.init(model: ChessBoardModel(pieces: pieces))
    }

    public static func empty() -> ChessBoard {
        return ChessBoard(model: ChessBoardModel.empty())
    }
}
