public struct ChessGame: Game {
	public typealias State = ChessState
	
	public let name: String = "chess"
	public let actions: [String: (State, String) throws -> ActionResult<State>] = [
		"move": { state, args in ActionResult(nextState: try state.childState(after: try State.Move.init(fromString: args))) },
		"cancel": { state, _ in ActionResult(nextState: state, cancelsMatch: true) }
	]
	
	public init() {}
}
