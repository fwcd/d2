import D2Utils

public enum CodenamesRole: Hashable, CaseIterable, RichValueConvertible {
    case red
    case blue

    public var asRichValue: RichValue {
        switch self {
            case .red: return .text(":red_square:")
            case .blue: return .text(":blue_square:")
        }
    }

    var opponent: CodenamesRole {
        switch self {
            case .red: return .blue
            case .blue: return .red
        }
    }
}
