import Utils

public class BuzzwordPhraseCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Generates a random buzzword phrase",
        requiredPermissionLevel: .basic
    )
    private let nouns: [String]
    private let adjectives: [String]
    private let compoundPrefixes: [String]
    private let compoundSuffixes: [String]

    public init(
        nouns: [String] = [
            "AI",
            "AR",
            "blockchain",
            "catalyst",
            "content",
            "client",
            "cloud",
            "data",
            "future",
            "game",
            "immersive",
            "web",
            "VR",
        ],
        adjectives: [String] = [
            "24/7",
            "B2B",
            "B2C",
            "best-of-breed",
            "holistic",
            "real-time",
            "on-demand",
        ],
        compoundPrefixes: [String] = [
            "cross",
            "e",
            "hyper",
            "goal",
            "quantum",
            "world",
        ],
        compoundSuffixes: [String] = [
            "adaptive",
            "based",
            "centered",
            "compatible",
            "class",
            "enabled",
            "focused",
            "proof",
            "scale",
            "infused",
            "driven",
            "changing",
            "connected",
            "oriented",
        ]
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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let phrase = "\(adjective()) \(noun()) \(noun())"
        await output.append(phrase)
    }

    private func noun() -> String {
        nouns.randomElement()!
    }

    private func compoundPrefix() -> String {
        compoundPrefixes.randomElement()!
    }

    private func compoundSuffix() -> String {
        compoundSuffixes.randomElement()!
    }

    private func compoundAdjective() -> String {
        "\(Bool.random() ? noun() : compoundPrefix())-\(compoundSuffix())"
    }

    private func adjective() -> String {
        Bool.random() ? compoundAdjective() : adjectives.randomElement()!
    }
}
