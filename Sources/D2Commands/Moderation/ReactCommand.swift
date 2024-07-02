import D2MessageIO
import Utils

fileprivate let argsPattern = #/(?<messageId>\d+)\s+(?<channelId>\d+)\s+:?(?<emoji>[^:\s]+):?/#

public class ReactCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .moderation,
        helpText: "Syntax: [message id] [channel id] [emoji name]",
        requiredPermissionLevel: .admin
    )
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

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) async {
        guard let sink = context.sink else {
            await output.append(errorText: "No client available")
            return
        }
        guard let parsedArgs = try? argsPattern.firstMatch(in: input) else {
            await output.append(errorText: info.helpText!)
            return
        }

        let messageId = MessageID(String(parsedArgs.messageId), clientName: sink.name)
        let channelId = MessageID(String(parsedArgs.channelId), clientName: sink.name)
        var emojiString = String(parsedArgs.emoji)

        if !emojiString.unicodeScalars.contains(where: \.properties.isEmoji) {
            // Try resolving the emoji via the guilds
            let potentialMatches = (sink.guilds ?? [])
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
