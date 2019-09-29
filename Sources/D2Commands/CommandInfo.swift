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
    /** Whether the commands should be hidden in lists. */
    public var hidden: Bool
    /** Whether the commands should continue to receive messages from the same channel. */
    public var subscribesToNextMessages: Bool
    /** Whether the command can only be invoked by users (not bots). */
    public var userOnly: Bool
    /** The source file in which the command is located. */
    public var sourceFile: String
    
    public init(
        category: CommandCategory,
        shortDescription: String,
        longDescription: String,
        helpText: String? = nil,
        requiredPermissionLevel: PermissionLevel = .admin,
        hidden: Bool = false,
        subscribesToNextMessages: Bool = false,
        userOnly: Bool = true,
        sourceFile: String = #file
    ) {
        self.sourceFile = sourceFile
        self.shortDescription = shortDescription
        self.longDescription = longDescription
        self.helpText = helpText
        self.requiredPermissionLevel = requiredPermissionLevel
        self.hidden = hidden
        self.subscribesToNextMessages = subscribesToNextMessages
        self.userOnly = userOnly
    }
}
