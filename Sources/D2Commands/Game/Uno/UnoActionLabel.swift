public enum UnoActionLabel: String, Hashable, CaseIterable {
    case skip
    case reverse
    case drawTwo
    case wild
    case wildDrawFour

    public var resourcePngPath: String {
        switch self {
            case .skip: return "Resources/Uno/skip.png"
            case .reverse: return "Resources/Uno/reverse.png"
            case .drawTwo: return "Resources/Uno/drawTwo.png"
            case .wild: return "Resources/Uno/wild.png"
            case .wildDrawFour: return "Resources/Uno/wildDrawFour.png"
        }
    }

    public var drawCardCount: Int {
        switch self {
            case .drawTwo: return 2
            case .wildDrawFour: return 4
            default: return 0
        }
    }

    public var skipDistance: Int {
        switch self {
            case .skip: return 1
            default: return 0
        }
    }

    public var canPickColor: Bool {
        return self == .wild || self == .wildDrawFour
    }
}
