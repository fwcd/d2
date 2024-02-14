public enum CodenamesTeam: Hashable, CaseIterable, RichValueConvertible {
    case red
    case blue

    public var asRichValue: RichValue {
        switch self {
            case .red: return .text(":red_square:")
            case .blue: return .text(":blue_square:")
        }
    }

    public var opponent: CodenamesTeam {
        switch self {
            case .red: return .blue
            case .blue: return .red
        }
    }
}
