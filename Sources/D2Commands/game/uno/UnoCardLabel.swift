public enum UnoCardLabel: Hashable {
	case number(Int)
	case skip
	case reverse
	case drawTwo
	case wild
	case wildDrawFour
	
	public var resourcePath: String? {
		switch self {
			case .skip: return "Resources/uno/skip.png"
			case .reverse: return "Resources/uno/reverse.png"
			case .drawTwo: return "Resources/uno/drawTwo.png"
			case .wild: return "Resources/uno/wild.png"
			case .wildDrawFour: return "Resources/uno/wildDrawFour.png"
			default: return nil
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
