import D2MessageIO
import Utils

public class BuzzwordBingoCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Generates a buzzword bingo matrix",
        requiredPermissionLevel: .basic
    )

    public let outputValueType: RichValueType = .components

    private let corpus: BuzzwordCorpus

    public init(corpus: BuzzwordCorpus = .standard) {
        self.corpus = corpus
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let rows = 5
        let cols = 5

        var generator = BuzzwordGenerator(corpus: corpus)

        do {
            try await output.append(.components((0..<rows).map { _ in
                try .actionRow(.init(components: (0..<cols).map { _ in try generator.primitiveWord() }.map { word in
                    .button(.init(
                        customId: "buzzwordbingo:\(word)",
                        label: word
                    ))
                }))
            }))
        } catch {
            await output.append(error, errorText: "Could not generate buzzwords: \(error)")
        }
    }
}
