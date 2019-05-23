public class D2ScriptStorage {
	public let name: String
	private let parent: D2ScriptStorage?
	private var values: [String: D2ScriptValue] = [:]
	public var count: Int { return values.count + (parent?.count ?? 0) }
	
	public init(name: String = "Anonymous storage", parent: D2ScriptStorage? = nil) {
		self.name = name
		self.parent = parent
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
	
	public func contains(_ name: String) -> Bool {
		return (parent?.contains(name) ?? false) || values[name] != nil
	}
}
