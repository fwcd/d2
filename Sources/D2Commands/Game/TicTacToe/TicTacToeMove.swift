import Utils

nonisolated(unsafe) private let argsRegex = #/(\S+)\s+(\S+)/#

public struct TicTacToeMove: Hashable {
    let row: Int
    let column: Int

    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }

    public init(fromString str: String) throws {
        if let parsedArgs = try? argsRegex.firstMatch(in: str) {
            if let row = Row(rawValue: String(parsedArgs.1)), let column = Column(rawValue: String(parsedArgs.2)) {
                self.row = row.index
                self.column = column.index
            } else if let row = Row(rawValue: String(parsedArgs.2)), let column = Column(rawValue: String(parsedArgs.1)) {
                self.row = row.index
                self.column = column.index
            } else if let row = Int(parsedArgs.1), let column = Int(parsedArgs.2) {
                self.row = row
                self.column = column
            } else {
                throw GameError.invalidMove("Invalid coordinates, try a combination of `\(Row.allCases.map { $0.rawValue })` and `\(Column.allCases.map { $0.rawValue })` with the syntax: `set [row] [column]` or `set [column] [row]`")
            }
        } else {
            throw GameError.invalidMove("Your move `\(str)` needs to follow the syntax `[row] [column]` or `[column] [row]` where `row in \(Row.allCases.map { $0.rawValue }) and column in \(Column.allCases.map { $0.rawValue }) or both row and column are numeric`")
        }
    }

    private enum Row: String, CaseIterable {
        case top
        case center
        case bottom

        var index: Int {
            switch self {
                case .top: 0
                case .center: 1
                case .bottom: 2
            }
        }
    }

    private enum Column: String, CaseIterable {
        case left
        case center
        case right

        var index: Int {
            switch self {
                case .left: 0
                case .center: 1
                case .right: 2
            }
        }
    }
}
