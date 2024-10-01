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

    public struct Corpus {
        public var nouns: [String]
        public var adjectives: [String]
        public var compoundPrefixes: [String]
        public var compoundSuffixes: [String]

        public init(
            nouns: [String],
            adjectives: [String],
            compoundPrefixes: [String],
            compoundSuffixes: [String]
        ) {
            assert(!nouns.isEmpty)
            assert(!adjectives.isEmpty)
            assert(!compoundPrefixes.isEmpty)
            assert(!compoundSuffixes.isEmpty)

            self.nouns = nouns
            self.adjectives = adjectives
            self.compoundPrefixes = compoundPrefixes
            self.compoundSuffixes = compoundSuffixes
        }
    }

    private struct Generator {
        var corpus: Corpus

        private enum GenerationError: Error {
            case noMoreNouns
            case noMoreCompoundPrefixes
            case noMoreCompoundSuffixes
            case noMoreAdjectives
        }

        mutating func phrase(adjectives: Int = 1, nouns: Int = 2) throws -> String {
            try ((0..<adjectives).map { _ in try adjective() } + (0..<nouns).map { _ in try noun() }).joined(separator: " ")
        }

        private mutating func noun() throws -> String {
            guard let noun = corpus.nouns.removeRandomElementBySwap() else {
                throw GenerationError.noMoreNouns
            }
            return noun
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

        private mutating func compoundAdjective() throws -> String {
            try "\(Bool.random() ? noun() : compoundPrefix())-\(compoundSuffix())"
        }

        private mutating func adjective() throws -> String {
            try Bool.random() ? compoundAdjective() : primitiveAdjective()
        }
    }

    private let corpus: Corpus

    public init(
        corpus: Corpus = .init(
            nouns: [
                "AI",
                "AR",
                "blockchain",
                "catalyst",
                "content",
                "cloud",
                "e-business",
                "e-commerce",
                "expertise",
                "game",
                "web",
                "VR",
            ],
            adjectives: [
                "24/7",
                "agile",
                "B2B",
                "B2C",
                "best-of-breed",
                "holistic",
                "global",
                "real-time",
                "seamless",
                "distributed",
                "diverse",
                "dynamic",
                "on-demand",
                "immersive",
                "rapid",
                "end-to-end",
                "cutting-edge",
                "cost-effective",
                "error-free",
                "state of the art",
                "next-generation",
                "low-risk",
                "high-tech",
                "high-yield",
            ],
            compoundPrefixes: [
                "client",
                "cross",
                "data",
                "inter",
                "future",
                "hyper",
                "market",
                "goal",
                "quantum",
                "world",
            ],
            compoundSuffixes: [
                "adaptive",
                "added",
                "based",
                "centered",
                "compatible",
                "compliant",
                "class",
                "distributed",
                "elastic",
                "empowered",
                "enabled",
                "engineered",
                "focused",
                "proof",
                "ready",
                "scale",
                "infused",
                "driven",
                "changing",
                "connected",
                "oriented",
                "tailored",
            ]
        )
    ) {
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
