import D2MessageIO
import D2Permissions
import Utils

nonisolated(unsafe) private let flagPattern = #/--(\S+)/#
nonisolated(unsafe) private let pingPattern = #/<@&?.+?>/#

// TODO: Use Arg API

public class MarkovCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Generates a natural language response using a Markov chain",
        longDescription: "Uses a Markov chain with data from the current channel to generate a human-like response",
        helpText: "Syntax: markov [--all]? [--withping]?",
        presented: true,
        requiredPermissionLevel: .basic
    )
    private let messageDB: MessageDatabase
    private let maxWords = 60

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let flags = Set<String>(input.matches(of: flagPattern).map { String($0.1) })
        let cleanedInput = input.replacing(flagPattern, with: "").nilIfEmpty

        do {
            // TODO: Use proper initial distribution without sacrificing performance
            let sampleMessage = try messageDB.randomMessage()
            let initialWord = try cleanedInput ?? sampleMessage.content.split(separator: " ").map { String($0) }.first?.nilIfEmpty ?? messageDB.randomMarkovWord()
            let stateMachine = MarkovStateMachine(predictor: messageDB, initialState: [initialWord], maxLength: self.maxWords)
            var result = [String]()

            for word in stateMachine {
                result.append(word)
            }

            var formattedResult = result.joined(separator: " ").nilIfEmpty ?? ":shrug: No results"

            if !flags.contains("withpings") {
                formattedResult = await formattedResult.cleaningMentions(with: context.guild)
            }

            await output.append(formattedResult)
        } catch {
            await output.append(error, errorText: "Could not generate Markov text")
        }
    }
}
