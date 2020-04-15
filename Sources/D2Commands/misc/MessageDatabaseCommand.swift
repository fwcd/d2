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
            let result = try messageDB.prepare(sql: input)
                .map { "(\($0.map { $0.map { "\($0)" } ?? "nil" }.joined(separator: ", ")))".nilIfEmpty ?? "_no output_" }
                .joined(separator: "\n")
            output.append(.code(result, language: nil))
        } catch {
            output.append(error, errorText: "Could not perform command")
        }
    }
}
