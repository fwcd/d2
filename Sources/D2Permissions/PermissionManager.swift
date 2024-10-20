import D2MessageIO
import Foundation
import Logging
import Utils

private let log = Logger(label: "D2Permissions.PermissionManager")
private let userPermissionsFilePath = "local/userPermissions.json"
private let adminWhitelistFilePath = "local/adminWhitelist.json"

public actor PermissionManager {
    private let storage = DiskJsonSerializer()
    private var adminWhitelist: AdminWhitelist
    private var userPermissions: [UserID: PermissionLevel]
    private var simulatedPermissions: [UserID: PermissionLevel] = [:]

    private var adminUserIDs: [UserID] { adminWhitelist.users + userPermissions.filter { $0.value == .admin }.map(\.key) }

    public init() {
        do {
            adminWhitelist = try storage.readJson(as: AdminWhitelist.self, fromFile: adminWhitelistFilePath)
        } catch {
            adminWhitelist = AdminWhitelist(users: [])
            log.debug("Could not read admin whitelist: \(error)")
        }

        do {
            userPermissions = try storage.readJson(as: [UserID: PermissionLevel].self, fromFile: userPermissionsFilePath)
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
        Set(adminUserIDs.compactMap { decode(id: $0, in: guild) })
    }

    private func decode(id: UserID, in guild: Guild) -> User? {
        guild.members.map(\.1.user).first(where: { $0.id == id })
    }

    public func user(_ theUser: User, hasPermission requiredLevel: PermissionLevel, usingSimulated: Bool = true) -> Bool {
        userID(theUser.id, hasPermission: requiredLevel, usingSimulated: usingSimulated)
    }

    public func userID(_ id: UserID, hasPermission requiredLevel: PermissionLevel, usingSimulated: Bool = true) -> Bool {
        userID(id, hasPermission: requiredLevel.rawValue, usingSimulated: usingSimulated)
    }

    public func userID(_ id: UserID, hasPermission requiredLevel: Int, usingSimulated: Bool = true) -> Bool {
        let userLevel = permissionLevel(for: id, usingSimulated: usingSimulated)
        return userLevel.rawValue >= requiredLevel
    }

    public func permissionLevel(for user: User, usingSimulated: Bool = true) -> PermissionLevel {
        permissionLevel(for: user.id, usingSimulated: usingSimulated)
    }

    public func permissionLevel(for id: UserID, usingSimulated: Bool = true) -> PermissionLevel {
        self[simulated: id].filter { _ in usingSimulated } ?? self[id]
    }

    public func remove(permissionsFrom user: User) {
        remove(permissionsFrom: user.id)
    }

    public func remove(permissionsFrom userID: UserID) {
        userPermissions.removeValue(forKey: userID)
    }

    public subscript(_ user: User) -> PermissionLevel {
        get { return self[user.id] }
        set { self[user.id] = newValue }
    }

    public subscript(simulated user: User) -> PermissionLevel? {
        get { return self[simulated: user.id] }
        set { self[simulated: user.id] = newValue }
    }

    public subscript(_ userID: UserID) -> PermissionLevel {
        get {
            if adminWhitelist.users.contains(userID) {
                return .admin
            } else {
                return userPermissions[userID] ?? .basic
            }
        }
        set { userPermissions[userID] = newValue }
    }

    public subscript(simulated userID: UserID) -> PermissionLevel? {
        get { simulatedPermissions[userID] }
        set { simulatedPermissions[userID] = newValue }
    }

    public func update(_ user: User, to level: PermissionLevel) {
        self[user] = level
    }

    public func update(simulated user: User, to level: PermissionLevel?) {
        self[simulated: user] = level
    }

    public func update(_ userID: UserID, to level: PermissionLevel) {
        self[userID] = level
    }

    public func update(simulated userID: UserID, to level: PermissionLevel?) {
        self[simulated: userID] = level
    }
}
