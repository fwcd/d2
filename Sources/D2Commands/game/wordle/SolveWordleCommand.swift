import D2MessageIO

public class SolveWordleCommand: StringCommand {
    public let info = CommandInfo(
        category: .game,
        shortDescription: "Solves a wordle",
        requiredPermissionLevel: .basic
    )
    private var boards: [ChannelID: WordleBoard] = [:]

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let channelId = context.channel?.id else {
            output.append(errorText: "Not on a channel")
            return
        }

        output.append("""
            Submit your guesses as messages with the syntax: [word] [clues]

            where clues is a string of ```
            n = nowhere (gray)
            s = somewhere (yellow)
            h = here (green)
            ```

            e.g. 'crane nnnsn' or 'where nnhns'
            """)

        boards[channelId] = WordleBoard()
        context.subscribeToChannel()
    }

    public func onSubscriptionMessage(with content: String, output: CommandOutput, context: CommandContext) {
        guard let channelId = context.channel?.id, let board = boards[channelId] else {
            context.unsubscribeFromChannel()
            return
        }

        // TODO
    }
}
