public struct UnoGame: Game {
	public typealias State = UnoState
	
	public let name: String = "uno"
	public let renderFirstBoard: Bool = false
	public let actions: [String: (State, String) throws -> ActionResult<State>] = [
		"move": { state, args in
			let next = try state.childState(after: try UnoGame.parse(move: args))
			let text = next.board.topColorMatchesCard ? nil : "The top color is now \(next.board.topColor?.discordStringEncoded ?? "?")"
			return ActionResult(nextState: next, text: text)
		},
		"cancel": { state, _ in ActionResult(cancelsMatch: true, onlyCurrentPlayer: false) }
	]
	
	public init() {}
	
	private static func parse(move rawMove: String) throws -> State.Move {
		return try State.Move(fromString: rawMove)
	}
}
