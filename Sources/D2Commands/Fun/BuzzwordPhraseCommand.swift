import Utils

fileprivate let argsPattern = #/(?:(?<adjectives>\d+)(?:\s+(?<nouns>\d+))?)?/#

public class BuzzwordPhraseCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Generates a random buzzword phrase",
        helpText: "Syntax: [adjective count] [noun count]",
        requiredPermissionLevel: .basic
    )

    public let outputValueType: RichValueType = .text



    private let corpus: BuzzwordCorpus

    public init(corpus: BuzzwordCorpus = .standard) {
        self.corpus = corpus
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let parsedArgs = try? argsPattern.firstMatch(in: input) else {
            await output.append(errorText: info.helpText!)
            return
        }

        let adjectives = parsedArgs.output.adjectives.flatMap { Int($0) } ?? 1
        let nouns = parsedArgs.output.nouns.flatMap { Int($0) } ?? 2

        var generator = BuzzwordGenerator(corpus: corpus)

        do {
            let phrase = try generator.phrase(adjectives: adjectives, nouns: nouns)
            await output.append(phrase)
        } catch {
            await output.append(error, errorText: "Could not generate phrase: \(error)")
        }
    }
}
