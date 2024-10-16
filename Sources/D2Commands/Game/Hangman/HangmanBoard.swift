import Utils

public struct HangmanBoard: RichValueConvertible, Sendable {
    public var slots: [CharacterSlot]

    public var asRichValue: RichValue { .text(String(slots.map { $0.hidden ? "-" : $0.character })) }
    public var word: String { String(slots.map(\.character)) }
    public var isUncovered: Bool { !slots.contains { $0.hidden } }

    public init(word: String) {
        slots = word.map(CharacterSlot.init(character:))
    }

    public struct CharacterSlot {
        public let character: Character
        public var hidden: Bool = true

        public init(character: Character) {
            self.character = character
        }
    }

    public mutating func guess(word: String) throws {
        if word == self.word {
            // Guess the entire word

            for i in 0..<slots.count {
                slots[i].hidden = false
            }
        } else if word.count == 1, let character = word.first, slots.contains(where: { $0.character == character }) {
            // Guess the character

            for i in 0..<slots.count where slots[i].character == character {
                slots[i].hidden = false
            }
        } else {
            throw HangmanError.invalidMove
        }
    }
}
