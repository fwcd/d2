import Foundation
import Logging
import Utils

fileprivate let log = Logger(label: "D2Commands.WordleIntelligence")

public struct WordleIntelligence: GameIntelligence {
    public init() {}

    public func pickMove(from state: WordleState) throws -> WordleMove {
        guard let word = entropies(on: state.board).last?.word else {
            throw WordleError.noMoves
        }
        return WordleMove(fromString: word)
    }

    public func entropies(on board: WordleBoard) -> [(word: String, entropy: Double)] {
        log.info("Computing entropies on board...")
        let possibleSolutions = board.possibleSolutions
        var lastProgress = 0
        return Words.wordleAllowed
            .enumerated()
            .map { (i, word) in
                let progress = (i * 100) / Words.wordleAllowed.count
                if progress % 10 == 0 && progress != lastProgress {
                    log.info("Progress: \(progress)%")
                    lastProgress = progress
                }
                return (word: word, entropy: entropy(for: word, on: board, possibleSolutions: possibleSolutions))
            }
            .sorted { $0.entropy < $1.entropy }
    }

    /// Computes the expected number of bits of information we
    /// would get from the given guess.
    /// Great explanation: https://www.youtube.com/watch?v=v68zYyaEmEA
    private func entropy(for word: String, on board: WordleBoard, possibleSolutions: [String]) -> Double {
        let possibilities = [WordleBoard.Clues: [String]](grouping: possibleSolutions, by: { board.clues(for: word, solution: $0) })
        guard let dist = CustomDiscreteDistribution<WordleBoard.Clues>(normalizing: Array(possibilities.mapValues(\.count))) else { return 0 }
        return dist.entropy
    }
}
