import D2MessageIO

public class RickrollCommand: Command {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Rickrolls someone",
        helpText: "Syntax: [user id]",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let messageId = context.message.id, let channelId = context.message.channelId else {
            await output.append(errorText: "No message/channel id available")
            return
        }
        guard let sink = context.sink else {
            await output.append(errorText: "No client available")
            return
        }
        guard let mentions = input.asMentions else {
            await output.append(errorText: "Mention someone to start!")
            return
        }

        let keepMessage = input.asText?.contains("--keep") ?? false

        if keepMessage {
            await rickroll(output: output, mentions: mentions)
        } else {
            do {
                try await sink.deleteMessage(messageId, on: channelId)
                await rickroll(output: output, mentions: mentions)
            } catch {
                await output.append(error, errorText: "Could not delete message")
            }
        }
    }

    private func rickroll(output: any CommandOutput, mentions: [User]) async {
        let what = ["cool video", "meme compilation", "awesome remix", "great song", "tutorial", "nice trailer", "movie"].randomElement()!
        await output.append("Hey, \(mentions.map { "<@\($0.id)>" }.joined(separator: " and ")), check out this \(what): <https://www.youtube.com/watch?v=dQw4w9WgXcQ>")
    }
}
