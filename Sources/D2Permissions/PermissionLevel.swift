public enum PermissionLevel: Int, Codable, Comparable, Sendable {
    case admin = 500
    case dev = 100
    case vip = 50
    case mod = 30
    case basic = 10

    public static func of(_ str: String) -> PermissionLevel? {
        switch str {
            case "admin": .admin
            case "dev": .dev
            case "vip": .vip
            case "mod": .mod
            case "basic": .basic
            default: nil
        }
    }

    public static func <(lhs: PermissionLevel, rhs: PermissionLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
