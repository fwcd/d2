import Utils

public enum ChessRole: String, Hashable, CaseIterable, Codable, RichValueConvertible, Sendable {
    case white
    case black

    public var asRichValue: RichValue {
        switch self {
            case .white: .text(":white_circle:")
            case .black: .text(":black_circle:")
        }
    }

    var opponent: ChessRole {
        switch self {
            case .white: .black
            case .black: .white
        }
    }
}
