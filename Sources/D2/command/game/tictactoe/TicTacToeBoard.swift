/** An immutable tic-tac-toe board. */
struct TicTacToeBoard: GameBoard {
	typealias Role = TicTacToeRole
	
	let fields: [[TicTacToeRole]]
	
	var discordEncoded: String {
		return fields.map { row in
			row.map { $0.discordEncoded }.joined()
		}.joined(separator: "\n")
	}
	
	var sideLength: Int { return fields.count }
	
	/** The winner of this board if there is one. A draw is represented as TicTacToeRole.empty. */
	var winner: TicTacToeRole? { return (horizontalWinner ?? verticalWinner) ?? diagonalWinner }
	var isDraw: Bool { return boardFilled && (winner == nil) }
	private var boardFilled: Bool { return fields.allSatisfy { row in row.allSatisfy { $0 != .empty } } }
	private var horizontalWinner: TicTacToeRole? { return (0..<sideLength).compactMap { winnerIn(row: $0) }.first }
	private var verticalWinner: TicTacToeRole? { return (0..<sideLength).compactMap { winnerIn(column: $0) }.first }
	private var diagonalWinner: TicTacToeRole? { return risingDiagonalWinner ?? fallingDiagonalWinner }
	private var risingDiagonalWinner: TicTacToeRole? { return TicTacToeRole.allPlayerCases.first { role in (0..<sideLength).allSatisfy { fields[$0][$0] == role } } }
	private var fallingDiagonalWinner: TicTacToeRole? { return TicTacToeRole.allPlayerCases.first { role in (0..<sideLength).allSatisfy { fields[(sideLength - 1) - $0][$0] == role } } }
	
	/** Creates an empty board of the given (square-shaped) size. */
	init(sideLength: Int = 3) {
		fields = Array(repeating: Array(repeating: .empty, count: sideLength), count: sideLength)
	}
	
	/** Initializes the board using the given fields. */
	init(fields: [[TicTacToeRole]]) {
		self.fields = fields
	}
	
	/** Fetches a field from the board. */
	subscript(row: Int, col: Int) -> TicTacToeRole {
		get { return fields[row][col] }
	}
	
	/** Creates a new board applying the given move or returns nil if the move is invalid. */
	func with(_ field: TicTacToeRole, atRow row: Int, col: Int) throws -> TicTacToeBoard {
		var newFields = fields
		
		if row < 0 || row >= sideLength || col < 0 || col >= sideLength {
			throw TicTacToeError.outOfBounds(row, col)
		} else if newFields[row][col] != .empty {
			throw TicTacToeError.invalidMove(field, row, col)
		} else {
			newFields[row][col] = field
			return TicTacToeBoard(fields: newFields)
		}
	}
	
	private func winnerIn(row: Int) -> TicTacToeRole? {
		return TicTacToeRole.allPlayerCases.first { role in fields[row].allSatisfy { $0 == role } }
	}
	
	private func winnerIn(column: Int) -> TicTacToeRole? {
		return TicTacToeRole.allPlayerCases.first { role in (0..<sideLength).allSatisfy { fields[$0][column] == role } }
	}
}
