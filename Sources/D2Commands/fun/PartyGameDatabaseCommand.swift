public class PartyGameDatabaseCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Lets the user send SQL commands to the local party game database",
        helpText: "Syntax: [subcommand|sql]",
        requiredPermissionLevel: .admin
    )
    public let outputValueType: RichValueType = .table
    private let partyGameDB: PartyGameDatabase
    private var subcommands: [String: (CommandOutput, CommandContext) throws -> Void] = [:]

    public init(partyGameDB: PartyGameDatabase) {
        self.partyGameDB = partyGameDB

        subcommands = [
            "rebuild": { [unowned self] output, _ in
                self.partyGameDB.rebuild()
                    .listen {
                        do {
                            try $0.get()
                            output.append("Successfully rebuilt party game database!")
                        } catch {
                            output.append(error, errorText: "Could not rebuild party game database")
                        }
                    }
            }
        ]
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        do {
            if let subcommand = subcommands[input] {
                try subcommand(output, context)
            } else {
                guard !input.isEmpty else {
                    output.append(errorText: "Please enter an SQL statement or one of these subcommands: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
                    return
                }

                let result = try partyGameDB.prepare(input).map { $0.map { $0.map { "\($0)" } ?? "?" } }
                output.append(.table(result))
            }
        } catch {
            output.append(error, errorText: "Could not perform command")
        }
    }
}
