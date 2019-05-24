public class D2ScriptStorage {
	public typealias D2ScriptFunction = ([D2ScriptValue?]) -> D2ScriptValue?
	
	public let name: String
	private let parent: D2ScriptStorage?
	private var values: [String: D2ScriptValue]
	private var functions: [String: D2ScriptFunction]
	private var localCommandNames = Set<String>()
	
	public var commandNames: Set<String> { return localCommandNames.union(parent?.commandNames ?? []) }
	public var count: Int { return values.count + (parent?.count ?? 0) }
	
	public init(
		name: String = "Anonymous storage",
		parent: D2ScriptStorage? = nil,
		values: [String: D2ScriptValue] = [:],
		functions: [String: D2ScriptFunction] = [:]
	) {
		self.name = name
		self.values = values
		self.parent = parent
		self.functions = functions
	}
	
	public subscript(_ name: String) -> D2ScriptValue? {
		set(newValue) {
			if values[name] != nil || !(parent?.contains(name) ?? false) {
				values[name] = newValue
			} else {
				parent![name] = newValue
			}
		}
		get { return values[name] ?? parent?[name] }
	}
	
	public subscript(function name: String) -> D2ScriptFunction? {
		set(newValue) {
			if functions[name] != nil || !(parent?.contains(function: name) ?? false) {
				functions[name] = newValue
			} else {
				parent![function: name] = newValue
			}
		}
		get { return functions[name] ?? parent?[function: name] }
	}
	
	public subscript(string name: String) -> String? {
		set(newValue) { self[name] = newValue.map { D2ScriptValue.string($0) } }
		get {
			guard case let .string(value)? = self[name] else { return nil }
			return value
		}
	}
	
	public subscript(number name: String) -> Double? {
		set(newValue) { self[name] = newValue.map { D2ScriptValue.number($0) } }
		get {
			guard case let .number(value)? = self[name] else { return nil }
			return value
		}
	}
	
	public func register(commandName: String) {
		localCommandNames.insert(commandName)
	}
	
	public func contains(_ name: String) -> Bool {
		return (parent?.contains(name) ?? false) || values[name] != nil
	}
	
	public func contains(function name: String) -> Bool {
		return (parent?.contains(function: name) ?? false) || functions[name] != nil
	}
	
	public func hasRegistered(command name: String) -> Bool {
		return (parent?.hasRegistered(command: name) ?? false) || localCommandNames.contains(name)
	}
}
