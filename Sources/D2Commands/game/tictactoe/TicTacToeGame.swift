public struct TicTacToeGame: Game {
	public typealias State = TicTacToeState
	
	public let name: String = "tic tac toe"
	public let actions: [String: (String, State) throws -> ActionResult<State>] = [
		"move": { ActionResult(nextState: try $1.childState(after: try State.Move.init(fromString: $0))) },
		"cancel": { ActionResult(nextState: $1, cancelsMatch: true) }
	]
	
	public init() {}
}
