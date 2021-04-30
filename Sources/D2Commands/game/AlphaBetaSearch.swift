import Logging

fileprivate let log = Logger(label: "D2Commands.AlphaBetaSearch")

/// A generic strategy for picking moves that uses
/// alpha-beta-search (a variant of min-max-search)
/// and a heuristic to determine the next move.
public struct AlphaBetaSearch<State>: GameIntelligence where State: GameState & FinitePossibleMoves {
    private let maxDepth: Int
    private let evaluator: (State) -> Double

    public init(
        maxDepth: Int = Int.max,
        evaluator: @escaping (State) -> Double = {
            // The default heuristic of checking the winner only works
            // well for games where the entire game tree can feasibly
            // be explored (e.g. in tic-tac-toe).
            switch $0.winner {
                case $0.currentRole?: return 1
                case nil: return 0
                default: return -1
            }
        }
    ) {
        self.maxDepth = maxDepth
        self.evaluator = evaluator
    }

    public func pickMove(from state: State) throws -> State.Move {
        guard let move = try negamax(state: state, alpha: -Double.infinity, beta: Double.infinity, remainingDepth: maxDepth).1 else { throw GameIntelligenceError.noMoves }
        return move
    }

    private func negamax(state: State, alpha: Double, beta: Double, remainingDepth: Int) throws -> (Double, State.Move?) {
        let possibleMoves = state.possibleMoves

        guard remainingDepth > 0 && !state.isGameOver && !possibleMoves.isEmpty else {
            return (evaluator(state), nil)
        }

        var alpha: Double = alpha
        var bestMove: State.Move? = nil

        for move in possibleMoves {
            let child = try state.childState(after: move)
            var (value, _) = try negamax(state: child, alpha: -beta, beta: -alpha, remainingDepth: remainingDepth - 1)
            value.negate()

            if value > alpha || bestMove == nil {
                alpha = value
                bestMove = move

                if value >= beta {
                    break
                }
            }

            if remainingDepth == maxDepth {
                log.info("Move \(move) has value \(value).")
            }
        }

        return (alpha, bestMove)
    }
}
