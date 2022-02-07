import Utils

public struct WordleBoard: RichValueConvertible {
    public var solution: String
    public var guesses: [Guess] = []

    public var isWon: Bool { guesses.last?.isWon ?? false }
    public var asRichValue: RichValue {
        .text(guesses.map(\.asRichLine).joined(separator: "\n").nilIfEmpty ?? "_empty_")
    }

    public struct Guess {
        public var word: String
        public var clues: [Clue] = []

        public var isWon: Bool { clues.count == word.count && clues.allSatisfy { $0 == .here } }

        var asRichLine: String {
            "`\(word)` \(clues.map(\.asEmoji).joined())"
        }
    }

    public enum Clue {
        case nowhere
        case somewhere
        case here

        var asEmoji: String {
            switch self {
            case .nowhere: return ":white_large_square:"
            case .somewhere: return ":yellow_square:"
            case .here: return ":green_square:"
            }
        }
    }

    public mutating func guess(word: String) throws {
        guard word.count == solution.count else {
            throw WordleError.invalidLength("Word '\(word)' should have length \(solution.count)")
        }

        let solutionSet = Set(solution)
        var guess = Guess(word: word)
        for (guessedLetter, actualLetter) in zip(word, solution) {
            if guessedLetter == actualLetter {
                guess.clues.append(.here)
            } else if solutionSet.contains(guessedLetter) {
                guess.clues.append(.somewhere)
            } else {
                guess.clues.append(.nowhere)
            }
        }

        guesses.append(guess)
    }
}
