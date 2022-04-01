import D2MessageIO
import D2Permissions
import Utils

fileprivate let flagPattern = try! Regex(from: "--(\\S+)")
fileprivate let pingPattern = try! Regex(from: "<@&?.+?>")

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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        let flags = Set<String>(flagPattern.allGroups(in: input).map { $0[1] })
        let cleanedInput = flagPattern.replace(in: input, with: "").nilIfEmpty

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
                formattedResult = formattedResult.cleaningMentions(with: context.guild)
            }

            output.append(formattedResult)
        } catch {
            output.append(error, errorText: "Could not generate Markov text")
        }
    }
}
