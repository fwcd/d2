import Utils
import D2MessageIO
import D2NetAPIs

public class NeverHaveIEverCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "The party game 'Never Have I Ever'",
        helpText: "Syntax: [category]?",
        presented: true,
        requiredPermissionLevel: .basic
    )
    private let partyGameDB: PartyGameDatabase

    public init(partyGameDB: PartyGameDatabase) {
        self.partyGameDB = partyGameDB
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let nhie = try partyGameDB.randomNhieStatement(category: input.nilIfEmpty)
            await output.append(Embed(
                description: "**\(nhie.statement)**",
                footer: nhie.category.map { Embed.Footer(text: "Category: \($0)") }
            ))
        } catch {
            await output.append(error, errorText: "Could not fetch statement")
        }
    }

    public func onSuccessfullySent(context: CommandContext) async {
        guard let messageId = context.message.id, let channelId = context.message.channelId else { return }

        for emoji in ["🍹", "❌"] {
            _ = try? await context.sink?.createReaction(for: messageId, on: channelId, emoji: emoji)
        }
    }
}
