import D2Utils
import D2Graphics

fileprivate let defaultSideLength = 8

public struct ChessBoard: DiscordImageEncodable {
	public typealias Piece = ColoredPiece
	
	public let pieces: [[Piece?]]
	public var discordImageEncoded: Image? { return nil /* TODO */ }
	
	public init() {
		pieces = [
			[Piece(.black, Rook()), Piece(.black, Knight()), Piece(.black, Bishop()), Piece(.black, Queen()), Piece(.black, King()), Piece(.black, Bishop()), Piece(.black, Knight()), Piece(.black, Rook())],
			Array(repeating: Piece(.black, Pawn()), count: defaultSideLength),
			Array(repeating: nil, count: defaultSideLength),
			Array(repeating: nil, count: defaultSideLength),
			Array(repeating: nil, count: defaultSideLength),
			Array(repeating: nil, count: defaultSideLength),
			Array(repeating: Piece(.white, Pawn()), count: defaultSideLength),
			[Piece(.white, Rook()), Piece(.white, Knight()), Piece(.white, Bishop()), Piece(.white, Queen()), Piece(.white, King()), Piece(.white, Bishop()), Piece(.white, Knight()), Piece(.white, Rook())]
		]
	}
	
	public init(pieces: [[Piece?]]) {
		self.pieces = pieces
	}
	
	public static func empty() -> ChessBoard {
		return ChessBoard(pieces: Array(repeating: Array<Piece?>(repeating: nil, count: defaultSideLength), count: defaultSideLength))
	}
}
