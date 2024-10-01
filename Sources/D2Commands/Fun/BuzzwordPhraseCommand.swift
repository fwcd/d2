import Utils

public class BuzzwordPhraseCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Generates a random buzzword phrase",
        requiredPermissionLevel: .basic
    )

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

        mutating func phrase() -> String {
            "\(adjective()) \(noun()) \(noun())"
        }

        private mutating func noun() -> String {
            corpus.nouns.removeRandomElementBySwap() ?? ""
        }

        private mutating func compoundPrefix() -> String {
            corpus.compoundPrefixes.removeRandomElementBySwap() ?? ""
        }

        private mutating func compoundSuffix() -> String {
            corpus.compoundSuffixes.removeRandomElementBySwap() ?? ""
        }

        private mutating func compoundAdjective() -> String {
            "\(Bool.random() ? noun() : compoundPrefix())-\(compoundSuffix())"
        }

        private mutating func adjective() -> String {
            Bool.random() ? compoundAdjective() : corpus.adjectives.removeRandomElementBySwap()!
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
        var generator = Generator(corpus: corpus)
        let phrase = generator.phrase()
        await output.append(phrase)
    }
}
