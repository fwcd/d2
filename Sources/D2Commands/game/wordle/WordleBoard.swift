import Utils

public struct WordleBoard: RichValueConvertible {
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
    public var possibleSolutions: [String] {
        Words.wordlePossible
            .filter { solution in guesses.allSatisfy { $0.isCompatible(with: solution) } }
    }

    public struct Guess {
        public var word: String
        public var clues: [Clue] = []

        public var isWon: Bool { clues.count == word.count && clues.allSatisfy { $0 == .here } }
        public var asRichLine: String {
            "`\(word)` \(clues.map(\.asEmoji).joined())"
        }

        public func isCompatible(with solution: String) -> Bool {
            let solutionSet = Set(solution)
            return zip(zip(word, clues), solution).allSatisfy {
                let (guessedLetter, clue) = $0.0
                let actualLetter = $0.1
                switch clue {
                case .unknown: return true
                case .nowhere: return !solutionSet.contains(guessedLetter)
                case .somewhere: return guessedLetter != actualLetter && solutionSet.contains(guessedLetter)
                case .here: return guessedLetter == actualLetter
                }
            }
        }
    }

    public enum Clue: Int, CaseIterable {
        case unknown = 0
        case nowhere
        case somewhere
        case here

        public var asEmoji: String {
            switch self {
            case .unknown: return ":black_large_square:"
            case .nowhere: return ":white_large_square:"
            case .somewhere: return ":yellow_square:"
            case .here: return ":green_square:"
            }
        }

        public var abbreviated: String {
            switch self {
            case .unknown: return "u"
            case .nowhere: return "n"
            case .somewhere: return "s"
            case .here: return "h"
            }
        }

        public init?(fromString s: String) {
            guard let value = Self.allCases.first(where: { $0.asEmoji == s || $0.abbreviated == s }) else { return nil }
            self = value
        }
    }

    public func clues(for word: String, solution: String) -> [Clue] {
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

    public mutating func guess(word: String, solution: String) throws {
        guard word.count == solution.count else {
            throw WordleError.invalidLength("Word '\(word)' should have length \(solution.count)")
        }

        guesses.append(Guess(word: word, clues: clues(for: word, solution: solution)))
    }
}
