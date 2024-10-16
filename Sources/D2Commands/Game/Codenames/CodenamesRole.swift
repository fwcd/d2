import Utils

public enum CodenamesRole: Hashable, CaseIterable, RichValueConvertible, Sendable {
    case team(CodenamesTeam)
    case spymaster(CodenamesTeam)

    // Order matters
    public static let allCases: [CodenamesRole] = CodenamesTeam.allCases.flatMap { [.spymaster($0), .team($0)] }

    public var asRichValue: RichValue {
        switch self {
            case .team(let team): team.asRichValue
            case .spymaster(let team): .compound([.text(":detective:"), team.asRichValue])
        }
    }

    public var next: CodenamesRole {
        Self.allCases[(Self.allCases.firstIndex(of: self)! + 1) %% Self.allCases.count]
    }

    public var team: CodenamesTeam {
        switch self {
            case .team(let team): team
            case .spymaster(let team): team
        }
    }

    var opponent: CodenamesRole {
        switch self {
            case .team(let team): .team(team.opponent)
            case .spymaster(let team): .spymaster(team.opponent)
        }
    }
}
