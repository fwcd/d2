enum PermissionLevel: Int, Codable {
	case admin = 500
	case dev = 100
	case vip = 50
	case basic = 10
	
	static func of(_ str: String) -> PermissionLevel? {
		switch str {
			case "admin": return .admin
			case "dev": return .dev
			case "vip": return .vip
			case "basic": return .basic
			default: return nil
		}
	}
}
