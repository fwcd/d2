import Utils

public class MessageDatabaseChannelActivityCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Queries the messages from a channel on the current guild",
        requiredPermissionLevel: .vip
    )
    public let outputValueType: RichValueType = .ndArrays
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter a channel name!")
            return
        }
        guard let guildId = await context.guild?.id else {
            await output.append(errorText: "Not on a guild")
            return
        }

        do {
            let sql = """
                select count(*)
                from messages natural join channels
                where guild_id == ?
                  and channel_name == ?
                group by strftime("%d-%m-%Y", timestamp)
                order by timestamp desc
                """
            let result = try messageDB.prepare(sql, String(guildId), input)
                .map { $0.map { $0.flatMap { Rational("\($0)") } ?? 0 } }
            let matrix = Matrix(result)
            await output.append(.ndArrays([matrix.asNDArray]))
        } catch {
            await output.append(error, errorText: "Could not query message database")
        }
    }
}
