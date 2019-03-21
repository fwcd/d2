func parseUnivISBool(str: String) -> Bool? {
	switch str {
		case "ja": return true
		case "nein": return false
		default: return nil
	}
}
