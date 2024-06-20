import D2MessageIO
import Utils

fileprivate let argsPattern = #/(?<messageId>\d+)\s+(?<channelId>\d+)\s+:?(?<emoji>[^:\s]+):?/#

public class ReactCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .moderation,
        helpText: "Syntax: [message id] [channel id] [emoji name]",
        requiredPermissionLevel: .admin
    )
    private let timer: RepeatingTimer?

    public init(temporary: Bool = false) {
        info.shortDescription = "Reacts to a message\(temporary ? " temporarily" : "")"
        info.longDescription = info.shortDescription

        if temporary {
            timer = RepeatingTimer(interval: .seconds(5))
        } else {
            timer = nil
        }
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let sink = context.sink else {
            output.append(errorText: "No client available")
            return
        }
        guard let parsedArgs = try? argsPattern.firstMatch(in: input) else {
            output.append(errorText: info.helpText!)
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
                output.append(errorText: "Could not find match for emoji \(emojiString)")
                return
            }
            emojiString = emoji.compactDescription
        }

        sink.createReaction(for: messageId, on: channelId, emoji: emojiString)

        timer?.schedule(beginImmediately: false) { (_, _) in
            sink.deleteOwnReaction(for: messageId, on: channelId, emoji: emojiString)
        }
    }
}
