public struct TicTacToeGame: Game {
	public typealias State = TicTacToeState
	
	public let name: String = "tic-tac-toe"
	public let actions: [String: (State, String) throws -> ActionResult<State>] = [
		"move": { state, args in ActionResult(nextState: try state.childState(after: try TicTacToeGame.parse(move: args))) }
	]
	public let helpText = """
		Tic-Tac-Toe moves can be written either as array indices with x and y in (0..<2) or in english:
		
		`move top left`
		`move bottom center`
		`move 1 2` (equivalent to `center right`)
		"""
	
	public init() {}
	
	private static func parse(move rawMove: String) throws -> State.Move {
		return try State.Move(fromString: rawMove)
	}
}
