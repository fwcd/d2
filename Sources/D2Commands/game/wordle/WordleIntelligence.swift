import Foundation
import Utils

public struct WordleIntelligence: GameIntelligence {
    public init() {}

    public func pickMove(from state: WordleState) throws -> WordleMove {
        guard let word = entropies(on: state.board).last?.word else {
            throw WordleError.noMoves
        }
        return WordleMove(fromString: word)
    }

    private func entropies(on board: WordleBoard) -> [(word: String, entropy: Double)] {
        return Words.wordleAllowed
            .map { (word: $0, entropy: entropy(for: $0, on: board)) }
            .sorted { $0.entropy < $1.entropy }
    }

    /// Computes the expected number of bits of information we
    /// would get from the given guess.
    /// Great explanation: https://www.youtube.com/watch?v=v68zYyaEmEA
    private func entropy(for word: String, on board: WordleBoard) -> Double {
        let possibilities = [[WordleBoard.Clue]: [String]](grouping: Words.wordleAllowed, by: { board.clues(for: word, solution: $0) })
        guard let dist = CustomDiscreteDistribution<[WordleBoard.Clue]>(normalizing: Array(possibilities.mapValues(\.count))) else { return 0 }
        return dist.entropy
    }
}
