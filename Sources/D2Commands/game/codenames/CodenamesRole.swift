import D2Utils

public enum CodenamesRole: Hashable, CaseIterable, RichValueConvertible {
    case red
    case blue
    case spymaster

    public var asRichValue: RichValue {
        switch self {
            case .red: return .text(":red_square:")
            case .blue: return .text(":blue_square:")
            case .spymaster: return .text(":detective:")
        }
    }

    var opponent: CodenamesRole {
        switch self {
            case .red: return .blue
            case .blue: return .red
            default: fatalError("Codenames role \(self) has no opponent")
        }
    }
}
