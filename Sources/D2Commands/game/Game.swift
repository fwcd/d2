import D2Graphics

public protocol Game {
	associatedtype State: GameState
	
	/** Actions define ways of interacting with the game. */
	var actions: [String: (ActionParameters<State>) throws -> ActionResult<State>] { get }
	/** API actions can be invoked by other applications and not just users. */
	var apiActions: Set<String> { get }
	
	/** The game's name. By convention in lower case. */
	var name: String { get }
	/** Whether the initial board of a match should be output. */
	var renderFirstBoard: Bool { get }
	/** Whether only the player whose turn it is should receive the hand. Not used if the game is real-time. */
	var onlySendHandToCurrentRole: Bool { get }
	/** Whether all players are allowed to make moves at any point in the game. */
	var isRealTime: Bool { get }
	/** A longer, descriptive text explaining the game's syntax and providing examples. */
	var helpText: String { get }
	/** Optionally a theme color for embeds. */
	var themeColor: Color? { get }
	
	init()
}

public extension Game {
	var renderFirstBoard: Bool { true }
	var onlySendHandToCurrentRole: Bool { true }
	var themeColor: Color? { nil }
	var isRealTime: Bool { false }
	var helpText: String { "No help text found for \(name)" }
	var apiActions: Set<String> { [] }
}
