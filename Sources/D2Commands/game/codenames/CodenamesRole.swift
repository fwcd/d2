import D2Utils

public enum CodenamesRole: Hashable, RichValueConvertible {
    case team(CodenamesTeam)
    case spymaster(CodenamesTeam)

    public var asRichValue: RichValue {
        switch self {
            case .team(let team): return team.asRichValue
            case .spymaster(let team): return .compound([.text(":detective:"), team.asRichValue])
        }
    }

    public var team: CodenamesTeam {
        switch self {
            case .team(let team): return team
            case .spymaster(let team): return team
        }
    }

    var opponent: CodenamesRole {
        switch self {
            case .team(let team): return .team(team.opponent)
            case .spymaster(let team): return .spymaster(team.opponent)
        }
    }
}
