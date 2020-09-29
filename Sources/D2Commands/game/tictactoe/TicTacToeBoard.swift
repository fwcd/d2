import Utils

/** An immutable tic-tac-toe board. */
public struct TicTacToeBoard: RichValueConvertible {
    public typealias Role = TicTacToeRole

    let fields: [[TicTacToeRole]]

    public var asRichValue: RichValue {
        return .text(fields.map { row in
            row.compactMap { $0.asRichValue.asText }.joined()
        }.joined(separator: "\n"))
    }

    var sideLength: Int { return fields.count }

    /** The winner of this board if there is one. A draw is represented as TicTacToeRole.empty. */
    public var winner: Role? { return (horizontalWinner ?? verticalWinner) ?? diagonalWinner }
    public var isDraw: Bool { return boardFilled && (winner == nil) }
    private var boardFilled: Bool { return fields.allSatisfy { row in row.allSatisfy { $0 != .empty } } }
    private var horizontalWinner: Role? { return (0..<sideLength).compactMap { winnerIn(row: $0) }.first }
    private var verticalWinner: Role? { return (0..<sideLength).compactMap { winnerIn(column: $0) }.first }
    private var diagonalWinner: Role? { return risingDiagonalWinner ?? fallingDiagonalWinner }
    private var risingDiagonalWinner: Role? { return Role.allPlayerCases.first { role in (0..<sideLength).allSatisfy { fields[$0][$0] == role } } }
    private var fallingDiagonalWinner: Role? { return Role.allPlayerCases.first { role in (0..<sideLength).allSatisfy { fields[(sideLength - 1) - $0][$0] == role } } }

    /** Creates an empty board of the given (square-shaped) size. */
    init(sideLength: Int = 3) {
        fields = Array(repeating: Array(repeating: .empty, count: sideLength), count: sideLength)
    }

    /** Initializes the board using the given fields. */
    init(fields: [[Role]]) {
        self.fields = fields
    }

    /** Fetches a field from the board. */
    subscript(row: Int, col: Int) -> Role {
        get { return fields[row][col] }
    }

    /** Creates a new board applying the given move or returns nil if the move is invalid. */
    func with(_ field: Role, atRow row: Int, col: Int) throws -> TicTacToeBoard {
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

    private func winnerIn(row: Int) -> Role? {
        return Role.allPlayerCases.first { role in fields[row].allSatisfy { $0 == role } }
    }

    private func winnerIn(column: Int) -> Role? {
        return Role.allPlayerCases.first { role in (0..<sideLength).allSatisfy { fields[$0][column] == role } }
    }
}
