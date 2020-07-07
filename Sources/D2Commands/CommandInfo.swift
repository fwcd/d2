import D2Permissions

/** A collection of metadata about a command. */
public struct CommandInfo {
    /** The command's category in the help framework. */
    public var category: CommandCategory
    /** A short/one-lined description of the command. */
    public var shortDescription: String
    /** A long description/help text for the command. */
    public var longDescription: String
    /** Additional help/usage information about a command. */
    public var helpText: String?
    /** The command's permission level. */
    public var requiredPermissionLevel: PermissionLevel
    /** Whether the command is should use a simulated permission level, if available. Should be true for almost every command. */
    public var usesSimulatedPermissionLevel: Bool
    /** Whether the commands should be hidden in lists. */
    public var hidden: Bool
    /** Whether the command will set up/handle subscriptions. Only for documentary purposes.. */
    public var subscribesToNextMessages: Bool
    /** Whether the command can only be invoked by users (not bots). */
    public var userOnly: Bool
    /** Whether the command can receive subscription messages only by users (not bots). Overrides userOnly. */
    public var subscriptionsUserOnly: Bool
    /** The source file in which the command is located. */
    public var sourceFile: String
    /** If present, the only platforms on which this command is allowed to run. */
    public var platformAvailability: Set<String>?
    
    public init(
        category: CommandCategory,
        shortDescription: String = "No description",
        longDescription: String? = nil,
        helpText: String? = nil,
        requiredPermissionLevel: PermissionLevel = .admin,
        usesSimulatedPermissionLevel: Bool = true,
        hidden: Bool = false,
        subscribesToNextMessages: Bool = false,
        userOnly: Bool = true,
        subscriptionsUserOnly: Bool? = nil,
        sourceFile: String = #file,
        platformAvailability: Set<String>? = nil
    ) {
        self.category = category
        self.shortDescription = shortDescription
        self.longDescription = longDescription ?? shortDescription
        self.helpText = helpText
        self.requiredPermissionLevel = requiredPermissionLevel
        self.usesSimulatedPermissionLevel = usesSimulatedPermissionLevel
        self.hidden = hidden
        self.subscribesToNextMessages = subscribesToNextMessages
        self.userOnly = userOnly
        self.subscriptionsUserOnly = subscriptionsUserOnly ?? userOnly
        self.sourceFile = sourceFile
        self.platformAvailability = platformAvailability
    }
}
