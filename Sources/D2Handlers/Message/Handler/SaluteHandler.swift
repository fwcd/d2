import D2MessageIO
import Logging
import RegexBuilder

private let log = Logger(label: "D2Handlers.SaluteHandler")

public struct SaluteHandler: MessageHandler {
    private let pattern: Regex<Substring>

    public init(
        keywords: Set<String> = ["major", "general"],
        capitalizedWordsOnly: Bool = true
    ) {
        pattern = Regex {
            ChoiceOf(nonEmptyComponents: capitalizedWordsOnly ? keywords.map(\.capitalized) : Array(keywords))
            (capitalizedWordsOnly ? #/(?:\s+[A-ZÄÖÜ]\w+)+/# : #/\s+\w+/#)
        }
    }

    public func handle(message: Message, sink: any Sink) async -> Bool {
        if let author = message.author,
           !author.bot,
           let channelId = message.channelId,
           let match = try? pattern.firstMatch(in: message.content) {
            do {
                try await sink.sendMessage("> [\(match.output)](https://tenor.com/view/himym-salute-gif-11222467)", to: channelId)
                return true
            } catch {
                log.warning("Could not send salute message: \(error)")
            }
        }
        return false
    }
}
