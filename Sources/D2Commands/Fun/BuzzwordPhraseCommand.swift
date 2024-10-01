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
        var nouns: [String]
        var nounSuffixes: [String]
        var adjectives: [String]
        var compoundPrefixes: [String]
        var compoundSuffixes: [String]

        public init(
            nouns: [String],
            nounSuffixes: [String],
            adjectives: [String],
            compoundPrefixes: [String],
            compoundSuffixes: [String]
        ) {
            assert(!nouns.isEmpty)
            assert(!nounSuffixes.isEmpty)
            assert(!adjectives.isEmpty)
            assert(!compoundPrefixes.isEmpty)
            assert(!compoundSuffixes.isEmpty)

            self.nouns = nouns
            self.nounSuffixes = nounSuffixes
            self.adjectives = adjectives
            self.compoundPrefixes = compoundPrefixes
            self.compoundSuffixes = compoundSuffixes
        }
    }

    private struct Generator {
        var corpus: Corpus

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

    private let corpus: Corpus

    public init(
        corpus: Corpus = .init(
            nouns: [
                "AI",
                "AR",
                "automation",
                "architecture",
                "big data",
                "business",
                "blockchain",
                "catalyst",
                "computing",
                "crypto",
                "content",
                "convergence",
                "cloud",
                "deployment",
                "e-business",
                "e-commerce",
                "expertise",
                "infrastructure",
                "IT",
                "IoT",
                "transformation",
                "thought leader",
                "paradigm",
                "roadmap",
                "security",
                "scrum",
                "single pane of glass",
                "software",
                "solution",
                "synergy",
                "game",
                "web",
                "VR",
            ],
            nounSuffixes: [
                "as-a-service",
                "shift",
            ],
            adjectives: [
                "24/7",
                "agile",
                "B2B",
                "B2C",
                "best-of-breed",
                "digital",
                "holistic",
                "global",
                "real-time",
                "seamless",
                "disruptive",
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
                "serverless",
                "high-tech",
                "high-yield",
                "battle-tested",
                "low-code",
                "no-code",
                "zero-trust",
                "full-stack",
                "turnkey",
            ],
            compoundPrefixes: [
                "charged",
                "client",
                "cross",
                "cyber",
                "data",
                "inter",
                "future",
                "hyper",
                "super",
                "market",
                "goal",
                "quantum",
                "world",
            ],
            compoundSuffixes: [
                "accelerated",
                "adaptive",
                "added",
                "based",
                "building",
                "centered",
                "compatible",
                "compliant",
                "converged",
                "class",
                "distributed",
                "grade",
                "elastic",
                "empowered",
                "enabled",
                "engineered",
                "focused",
                "powered",
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
