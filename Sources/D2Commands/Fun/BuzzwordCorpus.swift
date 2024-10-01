/// A collection of buzzwords.
public struct BuzzwordCorpus {
    public var nouns: [String]
    public var nounSuffixes: [String]
    public var adjectives: [String]
    public var compoundPrefixes: [String]
    public var compoundSuffixes: [String]

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
