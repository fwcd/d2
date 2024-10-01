import D2MessageIO
import Utils

private let customIdPrefix = "buzzwordbingo:"

public class BuzzwordBingoCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Generates a buzzword bingo matrix",
        requiredPermissionLevel: .basic
    )

    public let outputValueType: RichValueType = .components

    private let corpus: BuzzwordCorpus
    private var boards: [ChannelID: Board] = [:]

    private struct Board {
        var fields: [[Field]]

        struct Field {
            let word: String
            var isChecked = false
        }
    }

    public init(corpus: BuzzwordCorpus = .standard) {
        self.corpus = corpus
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let channelId = context.channel?.id else {
            await output.append(errorText: "No channel id")
            return
        }
        do {
            let board = try generateBoard()
            boards[channelId] = board
            context.subscribeToChannel()
            await output.append(.components(components(for: board)))
        } catch {
            await output.append(error, errorText: "Could not generate buzzwords: \(error)")
        }
    }

    public func onSubscriptionInteraction(with customId: String, by user: User, output: any CommandOutput, context: CommandContext) async {
        guard customId.hasPrefix(customIdPrefix),
              let channelId = context.channel?.id,
              let messageId = context.message.id,
              var board = boards[channelId] else { return }

        let encodedIndices = customId.dropFirst(customIdPrefix.count).split(separator: ",")
        guard let i = encodedIndices[safely: 0].flatMap({ Int($0) }) else {
            await output.append(errorText: "Could not parse row index from encoded field indices")
            return
        }
        guard let j = encodedIndices[safely: 1].flatMap({ Int($0) }) else {
            await output.append(errorText: "Could not parse column index from encoded field indices")
            return
        }

        board.fields[i][j].isChecked = true
        boards[channelId] = board

        do {
            try await context.sink?.editMessage(messageId, on: channelId, edit: .init(components: components(for: board)))
        } catch {
            await output.append(error, errorText: "Could not edit bingo message after interaction")
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
        board.fields.enumerated().map { (i, row) in
            .actionRow(.init(components: row.enumerated().map { (j, field) in
                .button(.init(
                    customId: "\(customIdPrefix)\(i),\(j)",
                    style: field.isChecked ? .secondary : .primary,
                    label: convertToFixedWidth(field.word)
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
