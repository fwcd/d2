import SwiftDiscord

struct PermissionManager {
	private var userPermissions = [String : PermissionLevel]()
	
	private func encode(user: DiscordUser) -> String {
		return "\(user.username)#\(user.discriminator)"
	}
	
	func user(_ theUser: DiscordUser, hasPermission requiredLevel: PermissionLevel) -> Bool {
		return user(theUser, hasPermission: requiredLevel.rawValue)
	}
	
	func user(_ theUser: DiscordUser, hasPermission requiredLevel: Int) -> Bool {
		return nameWithTag(encode(user: theUser), hasPermission: requiredLevel)
	}
	
	func nameWithTag(_ theNameWithTag: String, hasPermission requiredLevel: PermissionLevel) -> Bool {
		return nameWithTag(theNameWithTag, hasPermission: requiredLevel.rawValue)
	}
	
	func nameWithTag(_ theNameWithTag: String, hasPermission requiredLevel: Int) -> Bool {
		return self[theNameWithTag].rawValue >= requiredLevel
	}
	
	subscript(user: DiscordUser) -> PermissionLevel? {
		get { return self[encode(user: user)] }
		set(newValue) { self[encode(user: user)] = newValue! }
	}
	
	subscript(nameWithTag: String) -> PermissionLevel {
		get {
			if whitelistedDiscordUsers.contains(nameWithTag) {
				return .admin
			} else {
				return userPermissions[nameWithTag] ?? .basic
			}
		}
		set(newValue) { userPermissions[nameWithTag] = newValue }
	}
}
