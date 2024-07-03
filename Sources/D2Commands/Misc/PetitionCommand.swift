import D2MessageIO

public class PetitionCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Creates an 'signable petition' using a single reaction",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter something!")
            return
        }

        await output.append(Embed(
            title: "Petition",
            description: input
        ))
    }

    public func onSuccessfullySent(context: CommandContext) async {
        guard let messageId = context.message.id, let channelId = context.message.channelId else { return }

        _ = try? await context.sink?.createReaction(for: messageId, on: channelId, emoji: "✍️")
    }
}
