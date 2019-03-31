protocol Game {
	associatedtype State: GameState
	
	var name: String { get }
	var actions: [String: (State) -> GameActionResult] { get }
	
	init()
}
