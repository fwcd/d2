public enum D2ScriptValue: Hashable, D2ScriptExpression, CustomStringConvertible {
	case string(String)
	case number(Double)
	case map([String: D2ScriptValue])
	case list([D2ScriptValue])
	
	public var label: String { return "Value" }
	public var description: String {
		switch self {
			case let .string(str):
				return str
			case let .number(num):
				return String(num)
			case let .map(map):
				return "\(map)"
			case let .list(list):
				return "\(list)"
		}
	}
	
	public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
		return visitor.visit(value: self)
	}
}
