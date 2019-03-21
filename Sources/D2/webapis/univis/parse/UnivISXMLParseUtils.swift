func parse(univISBool: String) -> Bool? {
	switch univISBool {
		case "ja": return true
		case "nein": return false
		default: return nil
	}
}
