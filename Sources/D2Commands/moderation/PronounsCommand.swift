import Foundation
import D2MessageIO

public class PronounsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Lets the user pick pronouns to be displayed as a role",
        requiredPermissionLevel: .basic
    )

    public enum Pronoun: String, CaseIterable {
        case theyThem = "They/Them"
        case sheHer = "She/Her"
        case heHim = "He/Him"
        case other = "Other"
    }

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        output.append(.compound([.text("Please pick your pronouns:")] + Pronoun.allCases.map {
            .component(.button(.init(customId: $0.rawValue, label: $0.rawValue)))
        }))
        context.subscribeToChannel()
    }

    public func onSubscriptionInteraction(with customId: String, by user: User, output: CommandOutput, context: CommandContext) {
        // TODO
        output.append("Interacted with \(customId)")
    }
}
