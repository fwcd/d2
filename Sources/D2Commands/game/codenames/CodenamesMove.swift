import D2Utils

public enum CodenamesMove: Hashable, CustomStringConvertible {
    case codeword(Int, String)
    case guess([String])

    public var description: String {
        switch self {
            case .codeword(let count, let word): return "\(count) \("word".pluralize(with: count)) for codeword \(word)"
            case .guess(let words): return "Guess \(words.joined(separator: ", "))"
        }
    }
}
