public class NeverHaveIEverCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "The party game 'Never Have I Ever'",
        requiredPermissionLevel: .basic
    )
    private let partyGameDB: PartyGameDatabase

    public init(partyGameDB: PartyGameDatabase) {
        self.partyGameDB = partyGameDB
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            let nhie = try partyGameDB.randomNhieStatement()
            output.append(nhie.statement)
        } catch {
            output.append(error, errorText: "Could not fetch statement")
        }
    }

    public func onSuccessfullySent(context: CommandContext) {
        guard let messageId = context.message.id, let channelId = context.message.channelId else { return }

        for emoji in ["🍹", "❌"] {
            context.client?.createReaction(for: messageId, on: channelId, emoji: emoji)
        }
    }
}
