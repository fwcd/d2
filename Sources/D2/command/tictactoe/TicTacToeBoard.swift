/** An immutable tic-tac-toe board. */
struct TicTacToeBoard {
	let fields: [[TicTacToeRole]]
	
	/** Creates an empty board of the given size. */
	init(rows: Int = 3, cols: Int = 3) {
		fields = Array(repeating: Array(repeating: .empty, count: cols), count: rows)
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
	func with(_ field: TicTacToeRole, atRow row: Int, col: Int) -> TicTacToeBoard? {
		var newFields = fields
		if newFields[row][col] == .empty {
			return nil
		} else {
			newFields[row][col] = field
			return TicTacToeBoard(fields: newFields)
		}
	}
}
