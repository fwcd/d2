public protocol Game {
	associatedtype State: GameState
	
	var name: String { get }
	var actions: [String: (String, State) throws -> ActionResult<State>] { get }
	
	init()
}
