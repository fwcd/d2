import D2MessageIO
import Utils

fileprivate let argsPattern = try! LegacyRegex(from: "(\\w+)\\s+([nsh]+)")

public class SolveWordleCommand: StringCommand {
    public let info = CommandInfo(
        category: .game,
        shortDescription: "Solves a wordle",
        requiredPermissionLevel: .basic
    )
    private var boards: [ChannelID: WordleBoard] = [:]
    private let ai = WordleIntelligence()

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
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

        subscribe(to: channelId, context: context)
    }

    private func subscribe(to channelId: ChannelID, context: CommandContext) {
        boards[channelId] = WordleBoard()
        context.subscriptions.subscribe(to: channelId)
    }

    private func unsubscribe(from channelId: ChannelID, context: CommandContext) {
        boards[channelId] = nil
        context.subscriptions.unsubscribe(from: channelId)
    }

    public func onSubscriptionMessage(with content: String, output: any CommandOutput, context: CommandContext) {
        guard let channelId = context.channel?.id else {
            return
        }
        if content == "cancel" {
            output.append("Cancelled wordle solver on this channel")
            unsubscribe(from: channelId, context: context)
            return
        }
        guard var board = boards[channelId] else {
            unsubscribe(from: channelId, context: context)
            return
        }
        guard let parsedArgs = argsPattern.firstGroups(in: content), parsedArgs[1].count == parsedArgs[2].count else {
            return
        }

        let word = parsedArgs[1]
        let clues = WordleBoard.Clues(fromArray: parsedArgs[2].map { WordleBoard.Clue(fromString: String($0))! })

        board.guesses.append(WordleBoard.Guess(word: word, clues: clues))
        boards[channelId] = board

        context.channel?.triggerTyping()

        let possibleSolutions = board.possibleSolutions
        let embed: Embed

        if board.isWon {
            embed = Embed(
                title: "Congrats, you won!"
            )
            unsubscribe(from: channelId, context: context)
        } else if possibleSolutions.count == 0 {
            embed = Embed(
                title: "Impossible",
                description: "There are no solutions!"
            )
            unsubscribe(from: channelId, context: context)
        } else if possibleSolutions.count == 1 {
            embed = Embed(
                title: "Solution",
                description: possibleSolutions[0]
            )
            unsubscribe(from: channelId, context: context)
        } else {
            embed = Embed(
                title: "Top Picks",
                description: ai.entropies(on: board)
                    .reversed()
                    .prefix(5)
                    .map { "`\($0.word)`: \($0.entropy) bit(s)\($0.isPossibleSolution && possibleSolutions.count < 10 ? " (possible solution)" : "")" }
                    .joined(separator: "\n")
                    .nilIfEmpty
                    ?? "_none_"
            )
        }

        output.append(.compound([
            board.asRichValue,
            .embed(embed)
        ]))
    }
}
