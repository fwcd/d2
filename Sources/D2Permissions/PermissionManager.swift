import SwiftDiscord
import Foundation
import Logging
import D2Utils

fileprivate let log = Logger(label: "PermissionManager")
fileprivate let userPermissionsFilePath = "local/discordUserPermissions.json"
fileprivate let adminWhitelistFilePath = "local/adminWhitelist.json"

public class PermissionManager: CustomStringConvertible {
	private let storage = DiskJsonSerializer()
	private var adminWhitelist: AdminWhitelist
	private var userPermissions: [String: PermissionLevel]
	public var description: String { return userPermissions.description }
	
	public init() {
		do {
			adminWhitelist = try storage.readJson(as: AdminWhitelist.self, fromFile: adminWhitelistFilePath)
		} catch {
			adminWhitelist = AdminWhitelist(users: [])
			// TODO: Log error at a debug level
		}
		
		do {
			userPermissions = try storage.readJson(as: [String: PermissionLevel].self, fromFile: userPermissionsFilePath)
		} catch {
			userPermissions = [:]
			// TODO: Log error at a debug level
		}
	}
	
	public func writeToDisk() {
		do {
			try storage.write(userPermissions, asJsonToFile: userPermissionsFilePath)
		} catch {
			log.error("Error while writing permissions to disk: \(error)")
		}
	}
	
	private func encode(user: DiscordUser) -> String {
		return "\(user.username)#\(user.discriminator)"
	}
	
	public func user(_ theUser: DiscordUser, hasPermission requiredLevel: PermissionLevel) -> Bool {
		return user(theUser, hasPermission: requiredLevel.rawValue)
	}
	
	public func user(_ theUser: DiscordUser, hasPermission requiredLevel: Int) -> Bool {
		return nameWithTag(encode(user: theUser), hasPermission: requiredLevel)
	}
	
	public func nameWithTag(_ theNameWithTag: String, hasPermission requiredLevel: PermissionLevel) -> Bool {
		return nameWithTag(theNameWithTag, hasPermission: requiredLevel.rawValue)
	}
	
	public func nameWithTag(_ theNameWithTag: String, hasPermission requiredLevel: Int) -> Bool {
		return self[theNameWithTag].rawValue >= requiredLevel
	}
	
	public func remove(permissionsFrom user: DiscordUser) {
		remove(permissionsFrom: encode(user: user))
	}
	
	public func remove(permissionsFrom nameWithTag: String) {
		userPermissions.removeValue(forKey: nameWithTag)
	}
	
	public subscript(user: DiscordUser) -> PermissionLevel {
		get { return self[encode(user: user)] }
		set(newValue) { self[encode(user: user)] = newValue }
	}
	
	public subscript(nameWithTag: String) -> PermissionLevel {
		get {
			if adminWhitelist.users.contains(nameWithTag) {
				return .admin
			} else {
				return userPermissions[nameWithTag] ?? .basic
			}
		}
		set(newValue) { userPermissions[nameWithTag] = newValue }
	}
}
