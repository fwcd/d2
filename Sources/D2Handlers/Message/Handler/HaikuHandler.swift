import D2Commands
import Utils
import Logging
import D2MessageIO
import SyllableCounter

fileprivate let log = Logger(label: "D2Handlers.HaikuHandler")

public struct HaikuHandler: MessageHandler {
    private let syllableCounts: [Int]

    @Binding private var configuration: HaikuConfiguration
    private let inventoryManager: InventoryManager

    public init(
        @Binding configuration: HaikuConfiguration,
        inventoryManager: InventoryManager,
        syllableCounts: [Int] = [5, 7, 5]
    ) {
        self.syllableCounts = syllableCounts
        self._configuration = _configuration
        self.inventoryManager = inventoryManager
    }

    public func handle(message: Message, sink: any Sink) -> Bool {
        if let channelId = message.channelId,
            configuration.enabledChannelIds.contains(channelId),
            let author = message.guildMember,
            let haiku = haikuOf(message.content) {
            log.info("\(author.displayName) wrote a haiku: \(haiku.joined(separator: " - "))")

            let item = Inventory.Item(
                id: "Haiku \(message.id.map { "\($0)" } ?? "?")",
                name: "Haiku",
                attributes: [
                    "text": haiku.joined(separator: "\n")
                ]
            )
            inventoryManager[author.user].append(item: item, to: "Haikus")

            sink.sendMessage(Message(embed: Embed(
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
