import D2MessageIO
import Utils

fileprivate let argsPattern = try! Regex(from: "(\\w+)\\s+([nsh]+)")

public class SolveWordleCommand: StringCommand {
    public let info = CommandInfo(
        category: .game,
        shortDescription: "Solves a wordle",
        requiredPermissionLevel: .basic
    )
    private var boards: [ChannelID: WordleBoard] = [:]
    private let ai = WordleIntelligence()

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
            ``` e.g. 'crane nnnsn' or 'where nnhns'
            """)

        boards[channelId] = WordleBoard()
        context.subscribeToChannel()
    }

    public func onSubscriptionMessage(with content: String, output: CommandOutput, context: CommandContext) {
        guard let channelId = context.channel?.id, var board = boards[channelId] else {
            context.unsubscribeFromChannel()
            return
        }
        guard let parsedArgs = argsPattern.firstGroups(in: content), parsedArgs[1].count == parsedArgs[2].count else {
            return
        }

        let word = parsedArgs[1]
        let clues = parsedArgs[2].map { WordleBoard.Clue(fromString: String($0))! }

        board.guesses.append(WordleBoard.Guess(word: word, clues: clues))
        boards[channelId] = board

        output.append(.compound([
            board.asRichValue,
            .embed(Embed(
                title: "Top Picks",
                description: ai.entropies(on: board)
                    .reversed()
                    .prefix(5)
                    .map { "`\($0.word)`: \($0.entropy) bit(s)" }
                    .joined(separator: "\n")
                    .nilIfEmpty
                    ?? "_none_"
            ))
        ]))
    }
}
