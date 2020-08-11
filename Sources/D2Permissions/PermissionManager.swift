import D2MessageIO
import Foundation
import Logging
import D2Utils

fileprivate let log = Logger(label: "D2Permissions.PermissionManager")
fileprivate let userPermissionsFilePath = "local/userPermissions.json"
fileprivate let adminWhitelistFilePath = "local/adminWhitelist.json"

fileprivate let nameWithTagPattern = try! Regex(from: "([^#]+)#(\\d+)")

public class PermissionManager: CustomStringConvertible {
    private let storage = DiskJsonSerializer()
    private var adminWhitelist: AdminWhitelist
    private var userPermissions: [String: PermissionLevel]
    private var simulatedPermissions: [String: PermissionLevel] = [:]
    public var description: String { return userPermissions.description }

    private var adminNamesWithTags: [String] { adminWhitelist.users + userPermissions.filter { $0.value == .admin }.map(\.key) }

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

    public func admins(in guild: Guild) -> Set<User> {
        Set(adminNamesWithTags.compactMap { decode(nameWithTag: $0, in: guild) })
    }

    private func encode(user: User) -> String {
        "\(user.username)#\(user.discriminator)"
    }

    private func decode(nameWithTag: String, in guild: Guild) -> User? {
        guard let parsed = nameWithTagPattern.firstGroups(in: nameWithTag) else { return nil }
        let users: [User] = guild.members.map(\.1.user)
        return users.first(where: { (user: User) -> Bool in user.username == parsed[1] && String(user.discriminator) == parsed[2] })
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
