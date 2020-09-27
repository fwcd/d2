import D2Utils

public enum CodenamesMove: Hashable, CustomStringConvertible {
    case codeword(String)
    case guess([String])

    public var description: String {
        switch self {
            case .codeword(let word): return "Codeword \(word)"
            case .guess(let words): return "Guess \(words.joined(separator: ", "))"
        }
    }
}
