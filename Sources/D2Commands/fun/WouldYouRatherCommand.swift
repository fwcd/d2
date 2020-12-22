import Foundation
import Utils
import D2MessageIO
import D2NetAPIs

public class WouldYouRatherCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Asks an either/or question",
        presented: true,
        requiredPermissionLevel: .basic
    )
    private let partyGameDB: PartyGameDatabase
    private let emojiA = "🅰"
    private let emojiB = "🅱"

    public init(partyGameDB: PartyGameDatabase) {
        self.partyGameDB = partyGameDB
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        do {
            let wyr = try partyGameDB.randomWyrQuestion()
            output.append(Embed(
                title: wyr.title,
                description: """
                    \(self.emojiA) \(wyr.firstChoice)
                    \(self.emojiB) \(wyr.secondChoice)
                    """,
                color: 0x440080
            ))
        } catch {
            output.append(error, errorText: "Could not fetch question.")
        }
    }

    public func onSuccessfullySent(context: CommandContext) {
        guard let messageId = context.message.id, let channelId = context.message.channelId else { return }
        context.client?.createReaction(for: messageId, on: channelId, emoji: emojiA)
        context.client?.createReaction(for: messageId, on: channelId, emoji: emojiB)
    }
}
