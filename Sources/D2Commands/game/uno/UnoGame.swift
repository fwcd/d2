public struct UnoGame: Game {
	public typealias State = UnoState
	
	public let name: String = "uno"
	public let renderFirstBoard: Bool = false
	public let actions: [String: (State, String) throws -> ActionResult<State>] = [
		"move": { state, args in
			let next = try state.childState(after: try UnoGame.parse(move: args))
			let text = next.board.topColorMatchesCard ? nil : "The top color is now \(next.board.topColor?.discordStringEncoded ?? "?")"
			return ActionResult(nextState: next, text: text)
		}
	]
	public let helpText = """
		Uno moves follow the general syntax
		```
		[card color] [card label] [optional chosen color]
		```
		
		Valid colors are: `\(UnoColor.allCases.map { $0.rawValue }.joined(separator: ", "))`
		Valid labels are: `any digit (1 through 9), skip, reverse, drawTwo, wild, wildDrawFour`
		
		Examples:
		
		`move yellow 4`
		`move red wild blue` (chooses the color blue)
		`move green wildDrawFour yellow` (chooses the color yellow)
		"""
	
	public init() {}
	
	private static func parse(move rawMove: String) throws -> State.Move {
		return try State.Move(fromString: rawMove)
	}
}
