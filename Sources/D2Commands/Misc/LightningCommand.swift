import D2MessageIO
import Foundation

private let soundMetersPerSec: Double = 343.0

public class LightningCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Measures the distance to a lightning strike",
        requiredPermissionLevel: .basic
    )
    private let thunderKeywords: [String]
    private let stopKeyword: String
    private var lightnings: [ChannelID: Lightning] = [:]

    private struct Thunder {
        let user: User
        let timestamp: Date
    }

    private struct Observation {
        let user: User
        let distanceMeters: Double
    }

    private struct Lightning {
        let timestamp: Date
        var thunders: [Thunder] = []

        var observations: [Observation] {
            thunders.map { Observation(user: $0.user, distanceMeters: $0.timestamp.timeIntervalSince(timestamp) * soundMetersPerSec) }
        }
    }

    public init(thunderKeywords: [String] = ["t", "thunder"], stopKeyword: String = "stop") {
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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let channelId = context.channel?.id, let timestamp = context.timestamp else { return }

        await output.append(":zap: Type `\(thunderKeywords[0])` immediately after hearing thunder! Type `\(stopKeyword)` to stop.")
        context.subscribeToChannel()
        lightnings[channelId] = Lightning(timestamp: timestamp)
    }

    public func onSubscriptionMessage(with content: String, output: any CommandOutput, context: CommandContext) async {
        if thunderKeywords.contains(content) {
            addThunder(from: context)
        } else if stopKeyword == content {
            context.unsubscribeFromChannel()

            if let channelId = context.channel?.id, let lightning = lightnings.removeValue(forKey: channelId) {
                let observations = lightning.observations
                await output.append(Embed(
                    title: ":zap: Lightning Summary",
                    description: observations.map {
                        String(format: "`%@` was **%.2fm** away from the strike", $0.user.username, $0.distanceMeters)
                    }.joined(separator: "\n").nilIfEmpty ?? "_none_"
                ))
            }
        }
    }

    private func addThunder(from context: CommandContext) {
        guard
            let channelId = context.channel?.id,
            let user = context.author,
            let timestamp = context.timestamp else { return }

        let thunder = Thunder(user: user, timestamp: timestamp)
        lightnings[channelId]?.thunders.append(thunder)
    }
}
