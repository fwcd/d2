import D2MessageIO
import Utils

public class ReactCommand: RegexCommand {
    public private(set) var info = CommandInfo(
        category: .moderation,
        helpText: "Syntax: [message id] [channel id] [emoji name]",
        requiredPermissionLevel: .admin
    )

    public let inputPattern = #/(?<messageId>\d+)\s+(?<channelId>\d+)\s+:?(?<emoji>[^:\s]+):?/#

    private let temporarySeconds: Double?

    public init(temporary: Bool = false) {
        info.shortDescription = "Reacts to a message\(temporary ? " temporarily" : "")"
        info.longDescription = info.shortDescription

        if temporary {
            temporarySeconds = 5
        } else {
            temporarySeconds = nil
        }
    }

    public func invoke(with input: Input, output: CommandOutput, context: CommandContext) async {
        guard let sink = context.sink else {
            await output.append(errorText: "No client available")
            return
        }

        let messageId = MessageID(String(input.messageId), clientName: sink.name)
        let channelId = MessageID(String(input.channelId), clientName: sink.name)
        var emojiString = String(input.emoji)

        if !emojiString.unicodeScalars.contains(where: \.properties.isEmoji) {
            // Try resolving the emoji via the guilds
            let potentialMatches = await (sink.guilds ?? [])
                .flatMap { $0.emojis.values.filter { $0.name == emojiString } }
            guard let emoji = potentialMatches.first else {
                await output.append(errorText: "Could not find match for emoji \(emojiString)")
                return
            }
            emojiString = emoji.compactDescription
        }

        do {
            try await sink.createReaction(for: messageId, on: channelId, emoji: emojiString)
        } catch {
            await output.append(error, errorText: "Could not create reaction")
            return
        }

        if let temporarySeconds {
            do {
                try await Task.sleep(for: .seconds(temporarySeconds))
                try await sink.deleteOwnReaction(for: messageId, on: channelId, emoji: emojiString)
            } catch {
                await output.append(error, errorText: "Could not delete reaction")
            }
        }
    }
}
