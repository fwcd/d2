public struct ChessGame: Game {
	public typealias State = ChessState
	
	public let name: String = "chess"
	public let actions: [String: (State, String) throws -> ActionResult<State>] = [
		"move": { state, args in ActionResult(
			nextState: try state.childState(after: try state.unambiguouslyResolve(move: try ChessGame.parse(move: args)))
		) },
		"possibleMoves": { state, _ in ActionResult(text: "`\(state.possibleMoves)`") }
	]
	
	public init() {}
	
	private static func parse(move rawMove: String) throws -> State.Move {
		if let move = ShortAlgebraicNotationParser().parse(rawMove) {
			return move
		} else {
			throw GameError.invalidMove("`\(rawMove)` is not a valid chess move. Try using short algebraic notation.")
		}
	}
}
