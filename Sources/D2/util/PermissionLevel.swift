enum PermissionLevel: Int {
	case admin = 500
	case vip = 50
	case basic = 10
	
	static func of(_ str: String) -> PermissionLevel? {
		switch str {
			case "admin": return .admin
			case "vip": return .vip
			case "basic": return .basic
			default: return nil
		}
	}
}
