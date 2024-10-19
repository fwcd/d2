import Utils
import Logging
import D2MessageIO

fileprivate let log = Logger(label: "D2Commands.MessageDatabaseCommand")

public class MessageDatabaseCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Lets the user send SQL commands to the local message database",
        helpText: "Syntax: [subcommand|sql]",
        requiredPermissionLevel: .admin
    )
    public let outputValueType: RichValueType = .table
    private let messageDB: MessageDatabase
    private var subcommands: [String: (any CommandOutput, CommandContext) async throws -> Void] = [:]

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB

        subcommands = [
            "generateMarkovTransitions": { [unowned self] output, _ async throws in
                let count = try self.messageDB.generateMarkovTransitions()
                await output.append("Successfully generated/updated \(count) \("transition".pluralized(with: count))")
            },
            "debugRebuild": { [unowned self] output, context in
                guard let sink = context.sink, let guildId = await context.guild?.id else {
                    await output.append(errorText: "Debug-rebuilding the message database requires a client and a guild")
                    return
                }
                await output.append("Debug-rebuilding database...")
                do {
                    try await self.messageDB.rebuildMessages(with: sink, from: guildId, debugMode: true) {
                        await output.append("Querying channel `\($0)`...")
                    }
                    await output.append("Done debug-rebuilding database!")
                } catch {
                    await output.append(error, errorText: "Error while debug-rebuilding database: \(error)")
                }
            },
            "rebuild": { [unowned self] output, context in
                guard let sink = context.sink, let guildId = await context.guild?.id else {
                    await output.append(errorText: "Rebuilding the message database requires a client and a guild")
                    return
                }
                await output.append("Rebuilding database...")
                do {
                    try await self.messageDB.rebuildMessages(with: sink, from: guildId) {
                        log.info("Querying channel `\($0)`...")
                    }
                    await output.append("Done rebuilding database!")
                } catch {
                    await output.append(error, errorText: "Error while rebuilding database: \(error)")
                }
            },
            "track": { [unowned self] output, context async throws in
                guard let guild = await context.guild else { return }
                try self.messageDB.setTracked(true, guildId: guild.id)
                await output.append("Successfully started to track messages in `\(guild.name)`")
            },
            "untrack": { [unowned self] output, context async throws in
                guard let guild = await context.guild else { return }
                try self.messageDB.setTracked(false, guildId: guild.id)
                await output.append("Successfully stopped to track messages in `\(guild.name)`")
            }
        ]
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            if let subcommand = subcommands[input] {
                try await subcommand(output, context)
            } else {
                guard !input.isEmpty else {
                    await output.append(errorText: "Please enter an SQL statement or one of these subcommands: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
                    return
                }

                let result = try messageDB.prepare(input).map { $0.map { $0.map { "\($0)" } ?? "?" } }
                await output.append(.table(result))
            }
        } catch {
            await output.append(error, errorText: "Could not perform command")
        }
    }
}
