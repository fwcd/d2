import Foundation
import D2MessageIO
import Utils

public struct SpamConfiguration: Codable, DefaultInitializable {
    /// The limits depending on how many days a user is already on the guild.
    public var limitsByDaysOnGuild: [Int: Limits] = [
        0: Limits(interval: 60.0, maxSpamMessagesPerInterval: 1),
        14: Limits(interval: 30.0, maxSpamMessagesPerInterval: 2),
        30: Limits(interval: 20.0, maxSpamMessagesPerInterval: 4),
        60: Limits(interval: 20.0, maxSpamMessagesPerInterval: 6)
    ]

    /// A role that is given to spammers, e.g. for muting them.
    public var spammerRoles: [GuildID: RoleID] = [:]
    /// Clears previously obtained roles from a spammer. Only used if spammerRole is not nil.
    public var removeOtherRolesFromSpammer: Bool = true

    public init() {}

    public struct Limits: Codable {
        /// The length of the time window
        public var interval: TimeInterval
        /// The maximum number of messages classified as spam that are allowed in the time window
        public var maxSpamMessagesPerInterval: Int
    }
}
