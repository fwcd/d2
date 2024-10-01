import Utils

public enum TicTacToeRole: String, CaseIterable, RichValueConvertible {
    case x = "x"
    case o = "o"
    case empty = " "

    static var allPlayerCases: [TicTacToeRole] { return allCases.filter { $0.isPlayerRole } }

    public var asRichValue: RichValue {
        switch self {
            case .x: .text(":x:")
            case .o: .text(":o:")
            case .empty: .text(":white_large_square:")
        }
    }

    var isPlayerRole: Bool { return self != .empty }
    var opponent: TicTacToeRole {
        switch self {
            case .x: .o
            case .o: .x
            default: self
        }
    }
}
