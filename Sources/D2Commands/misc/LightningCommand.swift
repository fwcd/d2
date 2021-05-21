import D2MessageIO
import Foundation

public class LightningCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Measures the distance to a lightning strike",
        requiredPermissionLevel: .basic
    )
    private let thunderKeywords: [String]
    private let stopKeyword: String
    private var lightnings: [ChannelID: [Thunder]]

    private struct Thunder {
        let userId: UserID
        let timestamp: Date
    }

    public init(thunderKeywords: [String] = ["l", "lightning", "strike"], stopKeyword: String = "stop") {
        self.thunderKeywords = thunderKeywords
        self.stopKeyword = stopKeyword

        info.helpText = """
            Invoke the command to register a lightning. Any number
            of users may then send one of the following keywords
            to register that they heard thunder:

            \(thunderKeywords.map { "`\($0)`" }.joined(separator: ", "))

            Finally, invoke `\(stopKeyword)` to get a summary of the
            distances.
            """
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        addThunder(from: context)
        context.subscribeToChannel()
    }

    public func onSubscriptionMessage(with content: String, output: CommandOutput, context: CommandContext) {
        if thunderKeywords.contains(content) {
            addThunder(from: context)
        } else if stopKeyword == content {
            context.unsubscribeFromChannel()
        }
    }

    private func addThunder(from context: CommandContext) {
        guard
            let channelId = context.channel?.id,
            let userId = context.author?.id,
            let timestamp = context.timestamp else { return }

        lightnings[channelId] = (lightnings[channelId] ?? []) + [Thunder(userId: userId, timestamp: timestamp)]
    }
}
