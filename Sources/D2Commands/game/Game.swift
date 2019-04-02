public protocol Game {
	associatedtype State: GameState
	
	var name: String { get }
	var actions: [String: (State, String) throws -> ActionResult<State>] { get }
	var renderFirstBoard: Bool { get }
	var onlySendHandToCurrentRole: Bool { get }
	
	init()
	
	static func parse(move rawMove: String) throws -> State.Move
}

public extension Game {
	var renderFirstBoard: Bool { return true }
	var onlySendHandToCurrentRole: Bool { return true }
}
