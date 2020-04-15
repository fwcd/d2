public class MessageDatabaseCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Lets the user send SQL commands to the local message database",
        helpText: "Syntax: [sql]",
        requiredPermissionLevel: .admin
    )
    private let messageDB: MessageDatabase
    
    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            output.append("```\n\(try messageDB.execute(sql: input).map { "\($0)".nilIfEmpty ?? "_no output_" }.joined(separator: "\n"))\n```")
        } catch {
            output.append(error, errorText: "Could not perform command")
        }
    }
}
