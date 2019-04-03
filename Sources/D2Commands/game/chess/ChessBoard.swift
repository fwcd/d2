import D2Utils
import D2Graphics

public struct ChessBoard: DiscordImageEncodable {
	public var model: ChessBoardModel
	public var discordImageEncoded: Image? { return ChessBoardView(model: model).image }
	
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
