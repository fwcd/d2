import D2MessageIO
import Utils

private let stopCommand = "stop"

public class ConversateCommand<C>: StringCommand where C: Conversator {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Uses some fancy magic to chat with the user",
        helpText: "Invoke without argument, then send any message. Type 'stop' to stop the bot from replying.",
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true,
        userOnly: false
    )
    private let makeConversator: () throws -> C
    private let maxWords = 60

    private var conversators: [ChannelID: C] = [:]

    public init(_ makeConversator: @escaping () throws -> C) {
        self.makeConversator = makeConversator
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let channelId = context.channel?.id else {
            await output.append(errorText: "No channel id available")
            return
        }
        do {
            conversators[channelId] = try makeConversator()
            context.subscribeToChannel()
            await output.append("Subscribed to this channel. Type anything to talk to me, or `\(stopCommand)` to end the conversation.")
        } catch {
            await output.append(error, errorText: "Could not create conversator")
        }
    }

    public func onSubscriptionMessage(with content: String, output: any CommandOutput, context: CommandContext) async {
        guard context.author?.id != context.sink?.me?.id,
              let guildId = await context.guild?.id,
              let channelId = context.channel?.id,
              let conversator = conversators[channelId] else { return }
        if content == stopCommand {
            conversators[channelId] = nil
            context.unsubscribeFromChannel()
            await output.append("Unsubscribed from this channel.")
        } else {
            do {
                if let answer = try await conversator.answer(input: content, on: guildId) {
                    await output.append(answer.cleaningMentions(with: context.guild))
                }
            } catch {
                await output.append(error, errorText: "Could not provide answer")
            }
        }
    }

}
