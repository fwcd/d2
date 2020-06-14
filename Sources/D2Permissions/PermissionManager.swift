import D2MessageIO
import Foundation
import Logging
import D2Utils

fileprivate let log = Logger(label: "D2Permissions.PermissionManager")
fileprivate let userPermissionsFilePath = "local/userPermissions.json"
fileprivate let adminWhitelistFilePath = "local/adminWhitelist.json"

public class PermissionManager: CustomStringConvertible {
	private let storage = DiskJsonSerializer()
	private var adminWhitelist: AdminWhitelist
	private var userPermissions: [String: PermissionLevel]
	private var simulatedPermissions: [String: PermissionLevel] = [:]
	public var description: String { return userPermissions.description }
	
	public init() {
		do {
			adminWhitelist = try storage.readJson(as: AdminWhitelist.self, fromFile: adminWhitelistFilePath)
		} catch {
			adminWhitelist = AdminWhitelist(users: [])
			log.debug("Could not read admin whitelist: \(error)")
		}
		
		do {
			userPermissions = try storage.readJson(as: [String: PermissionLevel].self, fromFile: userPermissionsFilePath)
		} catch {
			userPermissions = [:]
			log.debug("Could not read user permissions: \(error)")
		}
	}
	
	public func writeToDisk() {
		do {
			try storage.write(userPermissions, asJsonToFile: userPermissionsFilePath)
		} catch {
			log.error("Error while writing permissions to disk: \(error)")
		}
	}
	
	private func encode(user: User) -> String {
		return "\(user.username)#\(user.discriminator)"
	}
	
	public func user(_ theUser: User, hasPermission requiredLevel: PermissionLevel, usingSimulated: Bool = true) -> Bool {
		return nameWithTag(encode(user: theUser), hasPermission: requiredLevel, usingSimulated: usingSimulated)
	}
	
	public func nameWithTag(_ theNameWithTag: String, hasPermission requiredLevel: PermissionLevel, usingSimulated: Bool = true) -> Bool {
		return nameWithTag(theNameWithTag, hasPermission: requiredLevel.rawValue, usingSimulated: usingSimulated)
	}
	
	public func nameWithTag(_ theNameWithTag: String, hasPermission requiredLevel: Int, usingSimulated: Bool = true) -> Bool {
		let userLevel = self[simulated: theNameWithTag].filter { _ in usingSimulated } ?? self[theNameWithTag]
		return userLevel.rawValue >= requiredLevel
	}
	
	public func remove(permissionsFrom user: User) {
		remove(permissionsFrom: encode(user: user))
	}
	
	public func remove(permissionsFrom nameWithTag: String) {
		userPermissions.removeValue(forKey: nameWithTag)
	}
	
	public subscript(_ user: User) -> PermissionLevel {
		get { return self[encode(user: user)] }
		set { self[encode(user: user)] = newValue }
	}

	public subscript(simulated user: User) -> PermissionLevel? {
		get { return self[simulated: encode(user: user)] }
		set { self[simulated: encode(user: user)] = newValue }
	}
	
	public subscript(_ nameWithTag: String) -> PermissionLevel {
		get {
			if adminWhitelist.users.contains(nameWithTag) {
				return .admin
			} else {
				return userPermissions[nameWithTag] ?? .basic
			}
		}
		set { userPermissions[nameWithTag] = newValue }
	}

	public subscript(simulated nameWithTag: String) -> PermissionLevel? {
		get { simulatedPermissions[nameWithTag] }
		set { simulatedPermissions[nameWithTag] = newValue }
	}
}
