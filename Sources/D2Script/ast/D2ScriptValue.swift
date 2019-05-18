public enum D2ScriptValue: Hashable, D2ScriptExpression {
	case string(String)
	case number(Double)
	case map([String: D2ScriptValue])
	case list([D2ScriptValue])
	
	public var label: String { return "Value" }
}
