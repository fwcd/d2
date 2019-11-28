import SwiftDiscord

public class SpamConfiguration {
    /** A role that is given to spammers, e.g. for muting them. */
    public var spammerRole: RoleID? = nil
    /** Clears previously obtained roles from a spammer. Only used if spammerRole is not nil. */
    public var removeOtherRolesFromSpammer: Bool = true
    
    public init() {}
}
