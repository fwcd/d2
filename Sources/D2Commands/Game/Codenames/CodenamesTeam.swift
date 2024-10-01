public enum CodenamesTeam: Hashable, CaseIterable, RichValueConvertible {
    case red
    case blue

    public var asRichValue: RichValue {
        switch self {
            case .red: .text(":red_square:")
            case .blue: .text(":blue_square:")
        }
    }

    public var opponent: CodenamesTeam {
        switch self {
            case .red: .blue
            case .blue: .red
        }
    }
}
