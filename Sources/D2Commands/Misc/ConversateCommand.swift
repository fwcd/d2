import Utils

public class ConversateCommand<C>: StringCommand where C: Conversator {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Uses a Markov chain to 'conversate' with the user",
        helpText: "Invoke without argument, then send any message. Type 'stop' to stop the bot from replying.",
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true,
        userOnly: false
    )
    private let conversator: C
    private let maxWords = 60

    public init(conversator: C) {
        self.conversator = conversator
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        context.subscribeToChannel()
        await output.append("Subscribed to this channel. Type anything to talk to me.")
    }

    public func onSubscriptionMessage(with content: String, output: any CommandOutput, context: CommandContext) async {
        guard context.author?.id != context.sink?.me?.id, let guildId = context.guild?.id else { return }
        if content == "stop" {
            context.unsubscribeFromChannel()
            await output.append("Unsubscribed from this channel.")
        } else {
            do {
                if let answer = try conversator.answer(input: content, on: guildId) {
                    await output.append(answer.cleaningMentions(with: context.guild))
                }
            } catch {
                await output.append(error, errorText: "Could not provide answer")
            }
        }
    }

}
