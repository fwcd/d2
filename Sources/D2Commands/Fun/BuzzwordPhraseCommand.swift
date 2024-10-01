import Utils

public class BuzzwordPhraseCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Generates a random buzzword phrase",
        requiredPermissionLevel: .basic
    )
    private let nouns: [String]
    private let compoundSuffixes: [String]

    public init(
        nouns: [String] = [
            "AI",
            "AR",
            "blockchain",
            "catalyst",
            "content",
            "cloud",
            "data",
            "future",
            "game",
            "immersive",
            "hyper",
            "quantum",
            "world",
            "VR",
        ],
        compoundSuffixes: [String] = [
            "based",
            "centered",
            "class",
            "enabled",
            "focused",
            "proof",
            "infused",
            "driven",
            "changing",
            "connected",
            "oriented",
        ]
    ) {
        assert(!nouns.isEmpty)
        assert(!compoundSuffixes.isEmpty)

        self.nouns = nouns
        self.compoundSuffixes = compoundSuffixes
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let phrase = "\(compoundAdjective()) \(noun()) \(noun())"
        await output.append(phrase)
    }

    private func noun() -> String {
        nouns.randomElement()!
    }

    private func compoundSuffix() -> String {
        compoundSuffixes.randomElement()!
    }

    private func compoundAdjective() -> String {
        "\(noun())-\(compoundSuffix())"
    }
}
