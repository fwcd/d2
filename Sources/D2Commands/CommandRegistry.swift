import SwiftDiscord

public class CommandRegistry: Sequence {
	private var commands = [String: Command]()
	
	public init() {}
	
	public subscript(name: String) -> Command? {
		get { return commands[name] }
		set(newValue) { commands[name] = newValue }
	}
	
	public func makeIterator() -> Dictionary<String, Command>.Iterator {
		return commands.makeIterator()
	}
}
