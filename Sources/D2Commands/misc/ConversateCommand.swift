import D2Utils

public class ConversateCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Uses a Markov chain to 'conversate' with the user",
        helpText: "Invoke without argument, then send any message. Type 'stop' to stop the bot from replying.",
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true,
        userOnly: false
    )
    private let conversator: Conversator
    private let maxWords = 60

    public init(conversator: Conversator) {
        self.conversator = conversator
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        context.subscribeToChannel()
        output.append("Subscribed to this channel. Type anything to talk to me.")
    }

    public func onSubscriptionMessage(with content: String, output: CommandOutput, context: CommandContext) {
        guard context.author?.id != context.client?.me?.id, let guildId = context.guild?.id else { return }
        if content == "stop" {
            context.unsubscribeFromChannel()
            output.append("Unsubscribed from this channel.")
        } else {
            do {
                if let answer = try conversator.answer(input: content, on: guildId) {
                    output.append(answer.cleaningMentions(with: context.guild))
                }
            } catch {
                output.append(error, errorText: "Could not provide answer")
            }
        }
    }

}
