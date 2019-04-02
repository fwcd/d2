import D2Utils
import D2Graphics

fileprivate let defaultSideLength = 8

public struct ChessBoard: DiscordImageEncodable {
	public typealias Piece = ColoredPiece
	
	public var pieces: [[Piece?]]
	public var ranks: Int { return pieces.count }
	public var files: Int { return pieces[0].count }
	public var discordImageEncoded: Image? { return nil /* TODO */ }
	
	public var pieceTypes: [[ColoredPieceType?]] {
		return pieces.map { row in row.map { $0?.asPieceType } }
	}
	
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
	
	public subscript(position: Vec2<Int>) -> Piece? {
		get { return pieces[position.x][position.x] }
		set(newValue) { pieces[position.y][position.x] = newValue }
	}
	
	/** Performs a disambiguated move. */
	mutating func perform(move: ChessMove) throws {
		guard let originX = move.originX else { throw ChessError.incompleteMove("ChessBoard.perform(move:) requires the move to have an origin file", move) }
		guard let originY = move.originY else { throw ChessError.incompleteMove("ChessBoard.perform(move:) requires the move to have an origin rank", move) }
		guard let destinationX = move.destinationX else { throw ChessError.incompleteMove("ChessBoard.perform(move:) requires the move to have a destination file", move) }
		guard let destinationY = move.destinationY else { throw ChessError.incompleteMove("ChessBoard.perform(move:) requires the move to have a destination rank", move) }
		guard let associatedMoves = move.associatedMoves else { throw ChessError.incompleteMove("ChessBoard.perform(move:) requires the move to have specified associatedMoves", move) }
		
		guard destinationX >= 0 && destinationX < files else { throw ChessError.moveOutOfBounds("Destination x (\(destinationX)) is out of bounds", move) }
		guard destinationY >= 0 && destinationY < ranks else { throw ChessError.moveOutOfBounds("Destination y (\(destinationY)) is out of bounds", move) }
		guard originX >= 0 && originX < files else { throw ChessError.moveOutOfBounds("Origin x (\(originX)) is out of bounds", move) }
		guard originY >= 0 && originY < ranks else { throw ChessError.moveOutOfBounds("Origin y (\(originY)) is out of bounds", move) }
		
		pieces[destinationY][destinationX] = pieces[originY][originX]
		pieces[originY][originX] = nil
		
		for associatedMove in associatedMoves {
			try perform(move: associatedMove)
		}
	}
}
