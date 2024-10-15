import Utils

public class BuzzwordPhraseCommand: RegexCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Generates a random buzzword phrase",
        helpText: "Syntax: [adjective count] [noun count]",
        requiredPermissionLevel: .basic
    )

    public let outputValueType: RichValueType = .text
    public let inputPattern = #/(?:(?<adjectives>\d+)(?:\s+(?<nouns>\d+))?)?/#

    private let corpus: BuzzwordCorpus

    public init(corpus: BuzzwordCorpus = .standard) {
        self.corpus = corpus
    }

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        let adjectives = input.adjectives.flatMap { Int($0) } ?? 1
        let nouns = input.nouns.flatMap { Int($0) } ?? 2

        var generator = BuzzwordGenerator(corpus: corpus)

        do {
            let phrase = try generator.phrase(adjectives: adjectives, nouns: nouns)
            await output.append(phrase)
        } catch {
            await output.append(error, errorText: "Could not generate phrase: \(error)")
        }
    }
}
