struct BuzzwordGenerator {
    private var corpus: BuzzwordCorpus

    init(corpus: BuzzwordCorpus = .standard) {
        self.corpus = corpus
    }

    enum GenerationError: Error {
        case noMoreNouns
        case noMoreNounSuffixes
        case noMoreCompoundPrefixes
        case noMoreCompoundSuffixes
        case noMoreAdjectives
        case noMoreWords
    }

    mutating func phrase(adjectives: Int = 1, nouns: Int = 2) throws -> String {
        try ((0..<adjectives).map { _ in try adjective() } + (0..<nouns).map { _ in try noun() }).joined(separator: " ")
    }

    mutating func word() throws -> String {
        let generators: [(inout Self) throws -> String] = [
            { try $0.noun() },
            { try $0.adjective() },
        ]

        let probability = 1.0 / Double(generators.count)
        var random = Double.random(in: 0...1)

        for (i, generator) in generators.enumerated() {
            if i == generators.count - 1 {
                return try generator(&self)
            } else if random < probability, let word = try? generator(&self) {
                return word
            }
            random -= probability
        }

        fatalError("Unreachable")
    }

    mutating func primitiveNoun() throws -> String {
        guard let noun = corpus.nouns.removeRandomElementBySwap() else {
            throw GenerationError.noMoreNouns
        }
        return noun
    }

    mutating func nounSuffix() throws -> String {
        guard let nounSuffix = corpus.nounSuffixes.removeRandomElementBySwap() else {
            throw GenerationError.noMoreNounSuffixes
        }
        return nounSuffix
    }

    mutating func compoundPrefix() throws -> String {
        guard let compoundPrefix = corpus.compoundPrefixes.removeRandomElementBySwap() else {
            throw GenerationError.noMoreCompoundPrefixes
        }
        return compoundPrefix
    }

    mutating func compoundSuffix() throws -> String {
        guard let compoundSuffix = corpus.compoundSuffixes.removeRandomElementBySwap() else {
            throw GenerationError.noMoreCompoundSuffixes
        }
        return compoundSuffix
    }

    mutating func primitiveAdjective() throws -> String {
        guard let adjective = corpus.adjectives.removeRandomElementBySwap() else {
            throw GenerationError.noMoreAdjectives
        }
        return adjective
    }

    mutating func noun() throws -> String {
        var noun = try primitiveNoun()
        if Double.random(in: 0...1) < 0.2, let suffix = try? nounSuffix() {
            noun += "-\(suffix)"
        }
        return noun
    }

    mutating func compoundAdjective() throws -> String {
        let prefix: String
        if Bool.random(), let noun = try? noun() {
            prefix = noun
        } else {
            prefix = try compoundPrefix()
        }
        return try "\(prefix)-\(compoundSuffix())"
    }

    mutating func adjective() throws -> String {
        if Bool.random(), let adjective = try? compoundAdjective() {
            return adjective
        } else {
            return try primitiveAdjective()
        }
    }
}
