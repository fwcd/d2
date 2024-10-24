import D2Commands
import D2Datasets
import Utils
import Logging
import D2MessageIO
import SyllableCounter

private let log = Logger(label: "D2Handlers.HaikuHandler")
nonisolated(unsafe) private let wordPattern = #/\b[a-zäöüß\d\-]+\b/#.ignoresCase()

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

    public func handle(message: Message, sink: any Sink) async -> Bool {
        if let channelId = message.channelId,
            configuration.enabledChannelIds.contains(channelId),
            let author = message.guildMember,
            let haiku = await haikuOf(message.content) {
            log.info("\(author.displayName) wrote a haiku: \(haiku.joined(separator: " - "))")

            let item = Inventory.Item(
                id: "Haiku \(message.id.map { "\($0)" } ?? "?")",
                name: "Haiku",
                attributes: [
                    "text": haiku.joined(separator: "\n")
                ]
            )
            inventoryManager[author.user].append(item: item, to: "Haikus")

            do {
                try await sink.sendMessage(Message(embed: Embed(
                    title: "A Haiku by `\(author.displayName)`",
                    description: haiku.joined(separator: "\n")
                )), to: channelId)
            } catch {
                log.warning("Could not send haiku message: \(error)")
            }
        }
        return false
    }

    private func haikuOf(_ raw: String) async -> [String]? {
        let words = raw.matches(of: wordPattern).map { String($0.output) }
        var verses = [[String]()]
        var totalSyllables = 0
        var wordIt = words.makeIterator()
        var syllableCountsIt = syllableCounts.makeIterator()

        while let expectedCount = syllableCountsIt.next() {
            var syllablesInVerse = 0

            while syllablesInVerse < expectedCount {
                guard let word = wordIt.next() else { return nil }
                verses[verses.count - 1].append(word)

                let count = await syllableCount(for: word.lowercased())
                syllablesInVerse += count
                totalSyllables += count
            }

            guard syllablesInVerse == expectedCount else { return nil }
            verses.append([])
        }

        guard wordIt.next() == nil else { return nil }

        return verses.map { $0.joined(separator: " ") }
    }

    private func syllableCount(for word: String) async -> Int {
        await Syllables.german[word] ?? word.syllables
    }
}
