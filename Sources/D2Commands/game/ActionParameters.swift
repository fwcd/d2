public struct ActionParameters<State: GameState> {
	public let args: String
	public let state: State
	public let apiEnabled: Bool
}
