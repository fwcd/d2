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

    private struct Generator {
        var corpus: BuzzwordCorpus

        private enum GenerationError: Error {
            case noMoreNouns
            case noMoreNounSuffixes
            case noMoreCompoundPrefixes
            case noMoreCompoundSuffixes
            case noMoreAdjectives
        }

        mutating func phrase(adjectives: Int = 1, nouns: Int = 2) throws -> String {
            try ((0..<adjectives).map { _ in try adjective() } + (0..<nouns).map { _ in try noun() }).joined(separator: " ")
        }

        private mutating func primitiveNoun() throws -> String {
            guard let noun = corpus.nouns.removeRandomElementBySwap() else {
                throw GenerationError.noMoreNouns
            }
            return noun
        }

        private mutating func nounSuffix() throws -> String {
            guard let nounSuffix = corpus.nounSuffixes.removeRandomElementBySwap() else {
                throw GenerationError.noMoreNounSuffixes
            }
            return nounSuffix
        }

        private mutating func compoundPrefix() throws -> String {
            guard let compoundPrefix = corpus.compoundPrefixes.removeRandomElementBySwap() else {
                throw GenerationError.noMoreCompoundPrefixes
            }
            return compoundPrefix
        }

        private mutating func compoundSuffix() throws -> String {
            guard let compoundSuffix = corpus.compoundSuffixes.removeRandomElementBySwap() else {
                throw GenerationError.noMoreCompoundSuffixes
            }
            return compoundSuffix
        }

        private mutating func primitiveAdjective() throws -> String {
            guard let adjective = corpus.adjectives.removeRandomElementBySwap() else {
                throw GenerationError.noMoreAdjectives
            }
            return adjective
        }

        private mutating func noun() throws -> String {
            var noun = try primitiveNoun()
            if Double.random(in: 0...1) < 0.2, let suffix = try? nounSuffix() {
                noun += "-\(suffix)"
            }
            return noun
        }

        private mutating func compoundAdjective() throws -> String {
            let prefix: String
            if Bool.random(), let noun = try? noun() {
                prefix = noun
            } else {
                prefix = try compoundPrefix()
            }
            return try "\(prefix)-\(compoundSuffix())"
        }

        private mutating func adjective() throws -> String {
            if Bool.random(), let adjective = try? compoundAdjective() {
                return adjective
            } else {
                return try primitiveAdjective()
            }
        }
    }

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

        var generator = Generator(corpus: corpus)

        do {
            let phrase = try generator.phrase(adjectives: adjectives, nouns: nouns)
            await output.append(phrase)
        } catch {
            await output.append(error, errorText: "Could not generate phrase: \(error)")
        }
    }
}
