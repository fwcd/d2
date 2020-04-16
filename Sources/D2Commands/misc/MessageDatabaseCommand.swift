import D2Utils

public class MessageDatabaseCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Lets the user send SQL commands to the local message database",
        helpText: "Syntax: [subcommand|sql]",
        requiredPermissionLevel: .admin
    )
    private let messageDB: MessageDatabase
    private var subcommands: [String: (CommandOutput) throws -> Void] = [:]
    
    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
        
        subcommands = [
            "generateMarkovTransitions": { [unowned self] output throws in
                let count = try self.messageDB.generateMarkovTransitions()
                output.append("Successfully generated/updated \(count) \("transition".pluralize(with: count))")
            }
        ]
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            if let subcommand = subcommands[input] {
                try subcommand(output)
            } else {
                let result = try messageDB.prepare(sql: input)
                    .map { "(\($0.map { $0.map { "\($0)" } ?? "nil" }.joined(separator: ", ")))".nilIfEmpty ?? "no output" }
                    .joined(separator: "\n")
                output.append(.code(result, language: nil))
            }
        } catch {
            output.append(error, errorText: "Could not perform command")
        }
    }
}
