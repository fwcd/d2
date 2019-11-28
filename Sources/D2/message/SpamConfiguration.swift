import SwiftDiscord

class SpamConfiguration {
    /** A role that is given to spammers, e.g. for muting them. */
    private var spammerRole: RoleID? = nil
    /** Clears previously obtained roles from a spammer. Only used if spammerRole is not nil. */
    private var removeOtherRolesFromSpammer: Bool = true
}
