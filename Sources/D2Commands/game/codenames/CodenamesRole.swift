import D2Utils

public enum CodenamesRole: Hashable, RichValueConvertible {
    case team(CodenamesTeam)
    case spymaster

    public var asRichValue: RichValue {
        switch self {
            case .team(let team): return team.asRichValue
            case .spymaster: return .text(":detective:")
        }
    }

    var opponent: CodenamesRole? {
        switch self {
            case .team(let team): return .team(team.opponent)
            default: return nil
        }
    }
}
