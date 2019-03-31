public struct GameActionResult<State: GameState> {
	public let nextState: State
	public let additionalOutput: String?
	
	public init(nextState: State, additionalOutput: String? = nil) {
		self.nextState = nextState
		self.additionalOutput = additionalOutput
	}
}
