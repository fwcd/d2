import SwiftDiscord
import Foundation

fileprivate let defaultStorageURL = URL(fileURLWithPath: "local/discordUserPermissions.json")

class PermissionManager: CustomStringConvertible {
	private var userPermissions = [String: PermissionLevel]()
	var description: String { return userPermissions.description }
	
	init() {
		tryReadingFromDisk()
	}
	
	private func encode(user: DiscordUser) -> String {
		return "\(user.username)#\(user.discriminator)"
	}
	
	func writeToDisk(url: URL = defaultStorageURL) {
		do {
			let fileManager = FileManager.default
			let data = try JSONEncoder().encode(userPermissions)
			
			if fileManager.fileExists(atPath: url.path) {
				try fileManager.removeItem(at: url)
			}
			
			fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
		} catch {
			print(error)
		}
	}
	
	func tryReadingFromDisk(url: URL = defaultStorageURL) {
		do {
			let fileManager = FileManager.default
			guard fileManager.fileExists(atPath: url.path) else { return }
			
			if let data = fileManager.contents(atPath: url.path) {
				userPermissions = try JSONDecoder().decode([String: PermissionLevel].self, from: data)
			}
		} catch {
			print(String(describing: error))
		}
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
	
	func remove(permissionsFrom user: DiscordUser) {
		remove(permissionsFrom: encode(user: user))
	}
	
	func remove(permissionsFrom nameWithTag: String) {
		userPermissions.removeValue(forKey: nameWithTag)
	}
	
	subscript(user: DiscordUser) -> PermissionLevel {
		get { return self[encode(user: user)] }
		set(newValue) { self[encode(user: user)] = newValue }
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
