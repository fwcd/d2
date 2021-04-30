import Foundation
import Graphics

public struct ChessGame: Game {
    public typealias State = ChessState

    public let name: String = "chess"
    public let actions: [String: (ActionParameters<State>) throws -> ActionResult<State>] = [
        "move": {
            let nextState = try $0.state.childState(after: try $0.state.unambiguouslyResolve(move: try ChessGame.parse(move: $0.args)))
            var text: String? = nil

            if let roleInCheck = nextState.roleInCheck {
                text = "\(roleInCheck.asRichValue.asText ?? "") is in check"
            }

            return ActionResult(nextState: nextState, text: text)
        },
        "possibleMoves": { ActionResult(text: "`\($0.state.possibleMoves)`") },
        "json": {
            let json = String(data: try JSONEncoder().encode($0.state.board.model.pieceTypes), encoding: .utf8)
            return ActionResult(text: json.map { "```json\n\($0)\n```" })
        }
    ]
    public let apiActions: Set<String> = ["move", "json"]
    public let themeColor: Color? = ChessTheme.defaultTheme.darkColor
    public let hasPrettyRoles = true
    public let helpText: String = """
        To create new chess moves, use short Algebraic Notation (see https://en.wikipedia.org/wiki/Algebraic_notation_(chess)). In many cases, this simply means using the letter of the piece you are moving followed by its destination. Consider the following examples:

        `move Kc4` (move king to c4)
        `move e4` (move pawn to e4)
        `move Nxf5` (move knight to f5 capturing an opponent's piece)
        `move O-O` (perform a short castling)
        `move d8=Q` (move pawn to d8 and promote it to a queen)

        Sometimes, however, it is necessary to disambiguate between moves. In that case, simply append the starting file and/or rank to your move notation:

        `move Bac4` (move bishop in file a to c4)
        `move R1d1` (move rook in rank 1 to c4)
        `move Qh1xg2` (move queen at h1 to g2 capturing a piece)

        King = `K`, Queen = `Q`, Rook = `R`, Bishop = `B`, Knight = `N`, Pawn = no letter
        """

    // TODO: Support UCI engines (e.g. Stockfish)
    public let engine: AnyGameIntelligence<State>? = AnyGameIntelligence(AlphaBetaSearch(maxDepth: 1, evaluator: \.evaluation))

    public init() {}

    private static func parse(move rawMove: String) throws -> State.Move {
        if let move = ShortAlgebraicNotationParser().parse(rawMove) {
            return move
        } else {
            throw GameError.invalidMove("`\(rawMove)` is not a valid chess move. Try using short algebraic notation.")
        }
    }
}
