import D2MessageIO

public class PetitionCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Creates an 'signable petition' using a single reaction",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter something!")
            return
        }

        output.append(Embed(
            title: "Petition",
            description: input
        ))
    }

    public func onSuccessfullySent(context: CommandContext) {
        guard let messageId = context.message.id, let channelId = context.message.channelId else { return }

        context.client?.createReaction(for: messageId, on: channelId, emoji: "✍️")
    }
}
