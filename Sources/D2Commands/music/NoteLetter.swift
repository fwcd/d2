enum NoteLetter: String {
	case c = "C"
	case d = "D"
	case e = "E"
	case f = "F"
	case g = "G"
	case a = "A"
	case b = "B"
	
	private static let otherMappings: [String: NoteLetter] = [
		"H": .b
	]
	
	static func of(_ str: String) -> NoteLetter? {
		return NoteLetter(rawValue: str.uppercased())
	}
}
