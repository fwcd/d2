public enum UnoActionLabel: String, Hashable, CaseIterable {
    case skip
    case reverse
    case drawTwo
    case wild
    case wildDrawFour

    public var resourcePngPath: String {
        switch self {
            case .skip: "Resources/Uno/skip.png"
            case .reverse: "Resources/Uno/reverse.png"
            case .drawTwo: "Resources/Uno/drawTwo.png"
            case .wild: "Resources/Uno/wild.png"
            case .wildDrawFour: "Resources/Uno/wildDrawFour.png"
        }
    }

    public var drawCardCount: Int {
        switch self {
            case .drawTwo: 2
            case .wildDrawFour: 4
            default: 0
        }
    }

    public var skipDistance: Int {
        switch self {
            case .skip: 1
            default: 0
        }
    }

    public var canPickColor: Bool {
        return self == .wild || self == .wildDrawFour
    }
}
