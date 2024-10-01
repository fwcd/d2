import Utils

public enum CodenamesMove: Hashable, CustomStringConvertible {
    case codeword(Int, String)
    case guess([String])

    public var description: String {
        switch self {
            case .codeword(let count, let word): "\(count) \("hint word".pluralized(with: count)) for codeword '\(word)'"
            case .guess(let words): "Guess \(words.map { "'\($0)'" }.joined(separator: ", "))"
        }
    }
}
