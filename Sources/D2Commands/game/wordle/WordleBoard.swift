import Utils

public struct WordleBoard: RichValueConvertible {
    public var solution: String
    public var guesses: [Guess] = []

    public var isWon: Bool { guesses.last?.isWon ?? false }
    public var asRichValue: RichValue {
        .text(guesses.map(\.asRichLine).joined(separator: "\n").nilIfEmpty ?? "_empty_")
    }
    public var cluesForAlphabet: [Clue: Set<Character>] {
        let clues = Dictionary(grouping: guesses.flatMap { zip($0.clues, $0.word) }, by: \.0).mapValues { Set($0.map(\.1)) }
        let remaining = "abcdefghijklmnopqrstuvwxyz".filter { c in !clues.values.contains { $0.contains(c) } }
        return clues.merging([.unknown: Set(remaining)], uniquingKeysWith: { v, _ in v })
    }

    public struct Guess {
        public var word: String
        public var clues: [Clue] = []

        public var isWon: Bool { clues.count == word.count && clues.allSatisfy { $0 == .here } }

        var asRichLine: String {
            "`\(word)` \(clues.map(\.asEmoji).joined())"
        }
    }

    public enum Clue: Int {
        case unknown = 0
        case nowhere
        case somewhere
        case here

        var asEmoji: String {
            switch self {
            case .unknown: return ":black_large_square:"
            case .nowhere: return ":white_large_square:"
            case .somewhere: return ":yellow_square:"
            case .here: return ":green_square:"
            }
        }
    }

    public func clues(for word: String) -> [Clue] {
        let solutionSet = Set(solution)

        return zip(word, solution).map { (guessedLetter, actualLetter) in
            if guessedLetter == actualLetter {
                return .here
            } else if solutionSet.contains(guessedLetter) {
                return .somewhere
            } else {
                return .nowhere
            }
        }
    }

    public mutating func guess(word: String) throws {
        guard word.count == solution.count else {
            throw WordleError.invalidLength("Word '\(word)' should have length \(solution.count)")
        }

        guesses.append(Guess(word: word, clues: clues(for: word)))
    }
}
