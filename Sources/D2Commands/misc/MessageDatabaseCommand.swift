import D2Utils
import D2MessageIO

public class MessageDatabaseCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Lets the user send SQL commands to the local message database",
        helpText: "Syntax: [subcommand|sql]",
        requiredPermissionLevel: .admin
    )
    private let messageDB: MessageDatabase
    private var subcommands: [String: (CommandOutput, CommandContext) throws -> Void] = [:]
    
    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
        
        subcommands = [
            "generateMarkovTransitions": { [unowned self] output, _ throws in
                let count = try self.messageDB.generateMarkovTransitions()
                output.append("Successfully generated/updated \(count) \("transition".pluralize(with: count))")
            },
            "track": { [unowned self] output, context throws in
                guard let guild = context.guild else { return }
                try self.messageDB.setTracked(true, guildId: guild.id)
                output.append("Successfully started to track messages in `\(guild.name)`")
            },
            "untrack": { [unowned self] output, context throws in
                guard let guild = context.guild else { return }
                try self.messageDB.setTracked(false, guildId: guild.id)
                output.append("Successfully stopped to track messages in `\(guild.name)`")
            }
        ]
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            if let subcommand = subcommands[input] {
                try subcommand(output, context)
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
