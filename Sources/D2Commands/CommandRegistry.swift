import D2MessageIO

public class CommandRegistry: Sequence {
	private var commands = [String: Command]()
	
	public init() {}
	
	public subscript(_ name: String, aliases: [String] = []) -> Command? {
		get { commands[name] ?? aliases.compactMap { commands[$0] }.first }
		set(newValue) {
			commands[name] = newValue
			for alias in aliases {
				commands[alias] = newValue
			}
		}
	}
	
	public func makeIterator() -> Dictionary<String, Command>.Iterator {
		return commands.makeIterator()
	}
}
