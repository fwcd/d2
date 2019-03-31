public struct UnoGame: Game {
	public typealias State = UnoState
	
	public let name: String = "uno"
	public let renderFirstBoard: Bool = false
	public let actions: [String: (State, String) throws -> ActionResult<State>] = [
		"move": { state, args in ActionResult(nextState: try state.childState(after: try State.Move.init(fromString: args))) },
		"cancel": { state, _ in ActionResult(nextState: state, cancelsMatch: true) }
	]
	
	public init() {}
}
