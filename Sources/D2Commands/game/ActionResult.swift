public struct ActionResult<State: GameState> {
	public let nextState: State
	public let additionalOutput: String?
	public let cancelsMatch: Bool
	
	public init(nextState: State, additionalOutput: String? = nil, cancelsMatch: Bool = false) {
		self.nextState = nextState
		self.additionalOutput = additionalOutput
		self.cancelsMatch = cancelsMatch
	}
}
