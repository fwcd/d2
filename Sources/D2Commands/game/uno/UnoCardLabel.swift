public enum UnoCardLabel: Hashable {
	case number(Int)
	case skip
	case reverse
	case drawTwo
	case wild
	case wildDrawFour
	
	public var resourcePngPath: String? {
		switch self {
			case .skip: return "Resources/uno/skip.png"
			case .reverse: return "Resources/uno/reverse.png"
			case .drawTwo: return "Resources/uno/drawTwo.png"
			case .wild: return "Resources/uno/wild.png"
			case .wildDrawFour: return "Resources/uno/wildDrawFour.png"
			default: return nil
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
	
	public static func of(actionLabel: String) -> UnoCardLabel? {
		switch actionLabel {
			case "skip": return .skip
			case "reverse": return .reverse
			case "drawTwo": return .drawTwo
			case "wild": return .wild
			case "wildDrawFour": return .wildDrawFour
			default: return nil
		}
	}
}
