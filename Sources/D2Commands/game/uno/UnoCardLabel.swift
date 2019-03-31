public enum UnoCardLabel: Hashable {
	case number(Int)
	case skip
	case reverse
	case drawTwo
	case wild
	case wildDrawFour
	
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
