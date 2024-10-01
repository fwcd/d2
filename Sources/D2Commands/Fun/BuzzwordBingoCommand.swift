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

    private struct Board {
        var fields: [[Field]]

        struct Field {
            let word: String
            var enabled = false
        }
    }

    public init(corpus: BuzzwordCorpus = .standard) {
        self.corpus = corpus
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let board = try generateBoard()
            await output.append(.components(components(for: board)))
        } catch {
            await output.append(error, errorText: "Could not generate buzzwords: \(error)")
        }
    }

    private func generateBoard(rows: Int = 4, cols: Int = 4) throws -> Board {
        var generator = BuzzwordGenerator(corpus: corpus)
        return Board(
            fields: try (0..<rows).map { _ in
                try (0..<cols).map { _ in
                    .init(word: try generator.primitiveWord())
                }
            }
        )
    }

    private func components(for board: Board) -> [Message.Component] {
        board.fields.map { row in
            .actionRow(.init(components: row.map { field in
                .button(.init(
                    customId: "buzzwordbingo:\(field.word)",
                    label: convertToFixedWidth(field.word),
                    disabled: true // TODO: Make the buttons interactive
                ))
            }))
        }
    }

    // TODO: Remove this workaround once the Discord API lets us align buttons properly
    // https://github.com/discord/discord-api-docs/discussions/3333
    // https://github.com/discord/discord-api-docs/discussions/4972

    private func convertToFixedWidth(_ word: String) -> String {
        let length = 14
        let padChar = "\u{200b} "
        let padCharWidth = 0.45
        let padLength = Double(max(length - word.count, 0)) / (2 * padCharWidth)
        let leftPadding = String(repeating: padChar, count: Int(padLength.rounded(.down)))
        let rightPadding = String(repeating: padChar, count: Int(padLength.rounded(.up)))
        return "\(leftPadding)\(FancyTextConverter().convert(word, to: .monospaced))\(rightPadding)"
    }
}
