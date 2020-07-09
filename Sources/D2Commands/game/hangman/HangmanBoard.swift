import D2Utils

public struct HangmanBoard: RichValueConvertible {
    public var slots: [CharacterSlot]
    public var asRichValue: RichValue { .text(String(slots.map { $0.hidden ? "-" : $0.character })) }

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

    public mutating func guess(character: Character) -> Bool {
        guard slots.contains(where: { $0.character == character }) else {
            return false
        }

        for i in 0..<slots.count where slots[i].character == character {
            slots[i].hidden = false
        }

        return true
    }
}
