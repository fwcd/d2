import D2MessageIO
import Utils

fileprivate let argsPattern = try! Regex(from: "(\\d+)\\s+(\\d+)\\s+:?(\\S+):?")

public class ReactCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Reacts to a message",
        helpText: "Syntax: [message id] [channel id] [emoji name]",
        requiredPermissionLevel: .admin
    )
    private let timer: RepeatingTimer?

    public init(temporary: Bool = false) {
        if temporary {
            timer = RepeatingTimer(interval: .seconds(5))
        } else {
            timer = nil
        }
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let client = context.client else {
            output.append(errorText: "No client available")
            return
        }
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }

        let messageId = MessageID(parsedArgs[1], clientName: client.name)
        let channelId = MessageID(parsedArgs[2], clientName: client.name)
        var emojiString = parsedArgs[3]

        if !emojiString.unicodeScalars.contains(where: \.properties.isEmoji) {
            // Try resolving the emoji via the guilds
            let potentialMatches = (client.guilds ?? [])
                .flatMap { $0.emojis.values.filter { $0.name == emojiString } }
            guard let emoji = potentialMatches.first else {
                output.append(errorText: "Could not find match for emoji \(emojiString)")
                return
            }
            emojiString = emoji.compactDescription
        }

        client.createReaction(for: messageId, on: channelId, emoji: emojiString)

        timer?.schedule(beginImmediately: false) { (_, _) in
            client.deleteOwnReaction(for: messageId, on: channelId, emoji: emojiString)
        }
    }
}
