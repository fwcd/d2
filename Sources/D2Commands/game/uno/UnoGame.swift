public struct UnoGame: Game {
	public typealias State = UnoState
	
	public let name: String = "uno"
	public let renderFirstBoard: Bool = false
	public let actions: [String: (State, String) throws -> ActionResult<State>] = [
		"move": { state, args in
			let next = try state.childState(after: try UnoGame.parse(move: args))
			let output = next.board.topColorMatchesCard ? nil : "The top color is now \(next.board.topColor?.discordStringEncoded ?? "?")"
			return ActionResult(nextState: next, additionalOutput: output)
		},
		"cancel": { state, _ in ActionResult(nextState: state, cancelsMatch: true) }
	]
	
	public init() {}
	
	private static func parse(move rawMove: String) throws -> State.Move {
		return try State.Move(fromString: rawMove)
	}
}
