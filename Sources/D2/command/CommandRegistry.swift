import SwiftDiscord

struct CommandRegistry: Sequence {
	private var commands = [String: Command]()
	
	subscript(name: String) -> Command? {
		get { return commands[name] }
		set(newValue) { commands[name] = newValue }
	}
	
	func makeIterator() -> Dictionary<String, Command>.Iterator {
		return commands.makeIterator()
	}
}
