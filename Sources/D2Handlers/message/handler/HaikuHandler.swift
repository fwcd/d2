import D2Commands
import D2Utils
import D2MessageIO
import SyllableCounter

public struct HaikuHandler: MessageHandler {
    private let syllableCounts: [Int]
    @AutoSerializing private var configuration: HaikuConfiguration

    public init(configuration: AutoSerializing<HaikuConfiguration>, syllableCounts: [Int] = [5, 7, 5]) {
        self.syllableCounts = syllableCounts
        self._configuration = configuration
    }

    public func handle(message: Message, from client: MessageClient) -> Bool {
        if let channelId = message.channelId,
            configuration.enabledChannelIds.contains(channelId),
            let author = message.guildMember,
            let haiku = haikuOf(message.content) {
            client.sendMessage(Message(embed: Embed(
                title: "A Haiku by `\(author.displayName)`",
                description: haiku.joined(separator: "\n")
            )), to: channelId)
        }
        return false
    }

    private func haikuOf(_ raw: String) -> [String]? {
        let words = raw
            .replacingOccurrences(of: "\n", with: " ")
            .split(separator: " ").map { String($0) }
        var verses = [[String]()]
        var totalSyllables = 0
        var wordIt = words.makeIterator()
        var syllableCountsIt = syllableCounts.makeIterator()

        while let expectedCount = syllableCountsIt.next() {
            var syllablesInVerse = 0

            while syllablesInVerse < expectedCount {
                guard let word = wordIt.next() else { return nil }
                verses[verses.count - 1].append(word)

                let count = word.syllables
                syllablesInVerse += count
                totalSyllables += count
            }

            guard syllablesInVerse == expectedCount else { return nil }
            verses.append([])
        }

        guard wordIt.next() == nil else { return nil }

        return verses.map { $0.joined(separator: " ") }
    }
}
