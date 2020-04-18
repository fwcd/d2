import D2MessageIO

/// A central facility where commands (possibly with aliases)
/// can be registered.
public class CommandRegistry: Sequence {
	/// The registered commands and aliases. It is assumed that
	/// every alias (possibly being nested) points to a valid
	/// command and neither dangles nor cycles.
	private var entries = [String: Entry]()
	
	public init() {}
	
	public enum Entry {
		case command(Command)
		case alias(String)
		
		var asCommand: Command? {
			switch self {
				case .command(let cmd): return cmd
				default: return nil
			}
		}
	}
	
	private func resolve(_ name: String) -> String {
		switch entries[name] {
			case .alias(let a)?: return resolve(a)
			default: return name
		}
	}
	
	public subscript(_ name: String, aliases aliases: [String]) -> Command? {
		get { entries[resolve(name)]?.asCommand }
		set {
			// TODO: Support unregistration by correctly removing aliases
			// TODO: Enforce invariants when encountering overlapping aliases
			guard let value = newValue else { fatalError("Command unregistration is not yet supported") }
			entries[name] = .command(value)
			for alias in aliases {
				entries[alias] = .alias(name)
			}
		}
	}
	
	public subscript(_ name: String) -> Command? {
		get { self[name, aliases: []] }
		set { self[name, aliases: []] = newValue }
	}
	
	public struct CommandWithAlias {
		public let name: String
		public let aliases: [String]
		public let command: Command
	}
	
	public func commandsWithAliases() -> [CommandWithAlias] {
		let dict = Dictionary(grouping: entries, by: { resolve($0.0) })
		return dict.map { CommandWithAlias(
			name: $0.0,
			aliases: $0.1.map { $0.0 },
			command: $0.1.compactMap { $0.1.asCommand }.first! // Dict cannot contain aliases that point to no command
		) }
	}
	
	public func makeIterator() -> Dictionary<String, Entry>.Iterator {
		return entries.makeIterator()
	}
}
