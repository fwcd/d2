import D2Utils

public struct HangmanMove: Hashable {
    public let word: String
    
    public init(fromString word: String) {
        self.word = word
    }
}
