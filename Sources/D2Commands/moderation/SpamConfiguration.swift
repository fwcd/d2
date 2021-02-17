import Foundation
import D2MessageIO
import Utils

public struct SpamConfiguration: Codable, DefaultInitializable {
    public var interval: TimeInterval = 30.0
    public var maxSpamMessagesPerInterval: Int = 6

    /// A role that is given to spammers, e.g. for muting them.
    public var spammerRoles: [GuildID: RoleID] = [:]
    /// Clears previously obtained roles from a spammer. Only used if spammerRole is not nil.
    public var removeOtherRolesFromSpammer: Bool = true

    public init() {}
}
