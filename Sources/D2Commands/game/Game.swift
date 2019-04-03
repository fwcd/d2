import D2Graphics

public protocol Game {
	associatedtype State: GameState
	
	/** Actions define ways of interacting with the game. */
	var actions: [String: (ActionParameters<State>) throws -> ActionResult<State>] { get }
	/** API actions can be invoked by other applications and not just users. */
	var apiActions: Set<String> { get }
	
	var name: String { get }
	var renderFirstBoard: Bool { get }
	var onlySendHandToCurrentRole: Bool { get }
	var helpText: String { get }
	var themeColor: Color? { get }
	
	init()
}

public extension Game {
	var renderFirstBoard: Bool { return true }
	var onlySendHandToCurrentRole: Bool { return true }
	var themeColor: Color? { return nil }
	var helpText: String { return "No help text found for \(name)" }
	var apiActions: Set<String> { return [] }
}
