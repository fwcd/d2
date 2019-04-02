import D2Utils
import D2Graphics

fileprivate let defaultSideLength = 8

public struct ChessBoard: DiscordImageEncodable {
	public typealias Piece = ColoredPiece
	
	public var pieces: [[Piece?]]
	public var ranks: Int { return pieces.count }
	public var files: Int { return pieces[0].count }
	public var discordImageEncoded: Image? { return createImage() }
	
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
		get { return pieces[position.y][position.x] }
		set(newValue) { pieces[position.y][position.x] = newValue }
	}
	
	/** Performs a disambiguated move. */
	mutating func perform(move: ChessMove) throws {
		guard let originX = move.originX else { throw ChessError.incompleteMove("ChessBoard.perform(move:) requires the move to have an origin file", move) }
		guard let originY = move.originY else { throw ChessError.incompleteMove("ChessBoard.perform(move:) requires the move to have an origin rank", move) }
		guard let destinationX = move.destinationX else { throw ChessError.incompleteMove("ChessBoard.perform(move:) requires the move to have a destination file", move) }
		guard let destinationY = move.destinationY else { throw ChessError.incompleteMove("ChessBoard.perform(move:) requires the move to have a destination rank", move) }
		
		guard destinationX >= 0 && destinationX < files else { throw ChessError.moveOutOfBounds("Destination x (\(destinationX)) is out of bounds", move) }
		guard destinationY >= 0 && destinationY < ranks else { throw ChessError.moveOutOfBounds("Destination y (\(destinationY)) is out of bounds", move) }
		guard originX >= 0 && originX < files else { throw ChessError.moveOutOfBounds("Origin x (\(originX)) is out of bounds", move) }
		guard originY >= 0 && originY < ranks else { throw ChessError.moveOutOfBounds("Origin y (\(originY)) is out of bounds", move) }
		
		pieces[destinationY][destinationX] = pieces[originY][originX]
		pieces[originY][originX] = nil
		
		for associatedMove in move.associatedMoves {
			try perform(move: associatedMove)
		}
	}
	
	private func createImage() -> Image? {
		do {
			let fieldSize = 30.0
			let padding = 20.0
			let intSize = Vec2<Int>(x: (Int(fieldSize) * files) + (Int(padding) * 2), y: (Int(fieldSize) * ranks) + (Int(padding) * 2))
			let img = try Image(fromSize: intSize)
			var graphics = CairoGraphics(fromImage: img)
			var blackField = false
			
			for row in 0..<ranks {
				for col in 0..<files {
					let color = blackField ? Color(rgb: 0xefa84a) : Color(rgb: 0xffcc7a)
					let x = (Double(row) * fieldSize) + padding
					let y = (Double(col) * fieldSize) + padding
					graphics.draw(Rectangle(fromX: x, y: y, width: fieldSize, height: fieldSize, color: color))
					blackField = !blackField
				}
			}
			
			return img
		} catch {
			print("Error while creating chess board image")
			return nil
		}
	}
}
