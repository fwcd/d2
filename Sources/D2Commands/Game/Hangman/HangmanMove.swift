import Utils

public struct HangmanMove: CustomStringConvertible, Hashable, Sendable {
    public let word: String
    public var description: String { word }

    public init(fromString word: String) {
        self.word = word
    }
}
